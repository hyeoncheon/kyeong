# plugin snmp

require 'bundler/setup'
require 'net/ping'
require 'json'

class Ping
  def initialize(args)
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
    puts "PING #{@shipper_addr}:#{@shipper_port} @#{@interval}"
    sock = UDPSocket.new
    last = Time.now
    while true
      @targets.each do |target|
        t = Net::Ping::TCP.new(target[:addr], target[:port])

        sum = 0
        count = 0
        [1,2,3].each do
          if t.ping
            sum += t.duration
            count += 1
          end
        end
        target[:rtt_ms] = sum * 1000 / count
        target[:count] = count

        sock.send("#{target.to_json}\n", 0, @shipper_addr, @shipper_port)
        puts target.to_json
      end

      # timing
      now = Time.now
      _next = [last + @interval, now].max
      sleep (_next - now)
      last = _next
    end
    sock.close
  end
end

