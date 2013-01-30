#!/usr/bin/ruby
require 'socket'
require 'benchmark'
SIZE = 1024 * 1024 * 10

server =  TCPServer.new("127.0.0.1", 12345)
puts "Server listening..."            
client = server.accept       

time = Benchmark.realtime do
  File.open('/tmp/output', 'w') do |file|
    while chunk = client.read(SIZE)
      file.write(chunk)
    end
  end
end

file_size = File.size('/tmp/output') / 1024 / 1024
puts "Time elapsed: #{time}. Transferred #{file_size} MB. Transfer per second: #{file_size / time} MB" and exit
