# plugin ping
#
# vim: set ts=2 sw=2 expandtab:

class Echo
  def initialize(args)
    @args = args
    @interval = args[:interval]
    @say = args[:say]
  end

  def run
    while true
      puts "Run Echo #{@say} (#{@args}, #{Time.now})"
      sleep @interval
    end
  end
end
