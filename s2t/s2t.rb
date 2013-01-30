#!/usr/bin/ruby

require 'speech'
require 'timeout'

p "Speak! it's record."
sleep(1)
pid = fork do 
	exec "./record.py"
end

sleep(5)
p pid
Process.kill("TERM", pid)
Process.wait pid

sleep(1)

file = "test.wav"
#file = ARGV[0]
audio = Speech::AudioToText.new("#{file}")
puts audio.to_text.inspect
