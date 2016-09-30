# plugin snmp

require 'bundler/setup'
require 'net/ping'
require 'json'

class Ping
  def initialize(args)
    @testing = args[:testing]
    @verbose = args[:verbose]
    @interval = args[:interval].to_i
    @shipper_addr = args[:shipper_addr]
    @shipper_port = args[:shipper_port].to_i
    if @interval == 0 or @shipper_addr == '' or @shipper_port == 0
      puts "Configuration Error!"
      raise "ConfigurationError"
    end
    conf = File.read('conf/ping_targets.json')
    @targets = JSON.parse(conf, :symbolize_names => true)
  end

  def run
    puts "PING conf: #{@shipper_addr}:#{@shipper_port} @#{@interval}"
    puts "     mode: testing/verbose '#{@testing}/#{@verbose}'"
    sock = UDPSocket.new
    last = Time.now
    while true
      begin
        @targets.each do |target|
          t = Net::Ping::TCP.new(target[:ping_addr], target[:ping_port])

          sum = 0
          count = 0
          [1,2,3].each do
            if t.ping
              sum += t.duration
              count += 1
            end
          end
          target[:ping_rtt_ms] = sum * 1000 / count
          target[:ping_count] = count

          if not @testing
            sock.send("#{target.to_json}\n", 0, @shipper_addr, @shipper_port)
            puts "#{target.to_json}" if @verbose
          else
            puts "#{target.to_json}"
          end
        end

        # timing
        now = Time.now
        _next = [last + @interval, now].max
        sleep (_next - now)
        last = _next
      rescue => detail
        print detail.backtrace.join("\n")
        raise
      end
    end
    sock.close
    puts "CLOSED #{@shipper_addr}:#{@shipper_port} @#{@interval}"
  end
end

