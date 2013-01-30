#!/usr/bin/ruby

require 'speech'
require 'timeout'
require 'json'
require "festivaltts4r"

"Hi, My name is Konstantin Zaliznyak".to_speech

#Name
"What is your name?".to_speech
sndfile = "tmp/name.wav" 
pid = fork do 
	exec "./record.py #{sndfile}"
end

p "recording ..."

sleep(2)
Process.kill("TERM", pid)
Process.wait pid

file = "#{sndfile}"
audio = Speech::AudioToText.new("#{file}")

name = audio.to_text

sleep(1)

#Area
"What area are you looking at?".to_speech
sndfile = "tmp/area.wav" 
pid = fork do 
	exec "./record.py #{sndfile}"
end
p "recording ..."

sleep(2)
Process.kill("TERM", pid)
Process.wait pid

file = "#{sndfile}"
audio = Speech::AudioToText.new("#{file}")

area = audio.to_text

#Bedrooms
"How Many Bedrooms?".to_speech
sndfile = "tmp/bdrm.wav" 
pid = fork do 
	exec "./record.py #{sndfile}"
end

p "recording ..."

sleep(2)
Process.kill("TERM", pid)
Process.wait pid

file = "#{sndfile}"
audio = Speech::AudioToText.new("#{file}")

bdrooms = audio.to_text

puts "Name: #{name}"
puts "Area: #{area}"
puts "Bedrooms: #{bdrooms}"
