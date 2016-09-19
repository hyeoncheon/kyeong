#!/usr/bin/ruby
# vim: set ts=2 sw=2 expandtab:

require 'bundler/setup'
require 'json'
require 'daemons'

$pid_dir = '/tmp'
$app_name = 'kyeong'

class Kyeong
  def initialize
    puts "Loading configuration from config.json..."
    @workers = []
    config = JSON.parse(File.read('config.json'), :symbolize_names => true)
    config.each do |c|
      print_and_flush "  - Loading plugin #{c[:plugin]}... "
      begin
        require_relative "plugins/#{c[:plugin]}"
        @workers.push Object.const_get(klass(c[:plugin])).new(c[:arguments])
        puts "OK."
      rescue LoadError
        puts "Failed!"
        puts "Error: Plugin '#{c[:plugin]}' cannot be loaded. Abort!"
        raise
      rescue RuntimeError
        puts "Plugin configuration error. Abort!"
        raise
      end
    end
    puts "  #{@workers.length} workers are configured."
  end

  def run
    puts "Starting Kyeong workers..."
    Daemons.daemonize({
      :app_name => $app_name,
      :dir_mode => :normal,
      :dir => $pid_dir,
      :log_output => true
    })
    #  :ontop => true,

    threads = []
    @workers.each do |worker|
      puts "  - Enabling plugin #{worker.class.name}..."
      thread = Thread.new{ worker.run }
      threads.push(thread)
    end


    threads.each do |t|
      t.join
    end
    puts "All workers are finished!"
  end

  def stop
  end
end

def print_and_flush(str)
  print str
  $stdout.flush
end

def klass(str)
  r = ''
  str.split('_').each do |s|
    r.concat s.capitalize
  end
  return r
end

if ARGV[0] == "start"
  begin
    pid = File.read("#{$pid_dir}/#{$app_name}.pid")
    print_and_flush "Warning: Another process(#{pid.to_i}) is running."
    begin
      Process.kill(0, pid.to_i)
      puts " Abort!"
    rescue Errno::ESRCH
      puts "Anyway, It seems that the process already gone!"
      puts "I will remove the pid file for you."
      File.delete("#{$pid_dir}/#{$app_name}.pid")
    end
    exit
  rescue Errno::ENOENT
  end
  k = Kyeong.new
  k.run
elsif ARGV[0] == "stop"
  begin
    pid = File.read("#{$pid_dir}/#{$app_name}.pid")
  rescue Errno::ENOENT
    puts "Pid file is not found. Abort!"
    exit
  end

  begin
    print_and_flush "Terminate the process... "
    Process.kill("TERM", pid.to_i)
    puts "done!"
  rescue Errno::ESRCH
    puts ""
    puts "Oops! It seems that the process already gone!"
    puts "I will remove the pid file for you."
    File.delete("#{$pid_dir}/#{$app_name}.pid")
  end
else
  puts "usage: #{$app_name} start|stop"
end
