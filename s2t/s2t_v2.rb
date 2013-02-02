#!/usr/bin/ruby

require 'speech'
require 'timeout'
require "festivaltts4r"

def record_s(filename)
	$sndfile = "tmp/#{filename}.wav"
	pid = fork do 
		puts "recording #{$sndfile}"
		exec "./record.py #{$sndfile}"
	end
		sleep(2)
	Process.kill("TERM", pid)
	Process.wait pid
end

puts "Realtors Best friend, Prototype 1"
puts "NOTE: Speak 1 second after the question"
	
"Hi, My name is Konstantin Zaliznyak".to_speech

puts "What is your name?"
"What is your name?".to_speech
record_s "name"

puts "What area are you looking at?"
"What area are you looking at?".to_speech
record_s "area"

puts "How many bedrooms?"
"How many bedrooms?".to_speech
record_s "rooms"

def convert_to_text(s2tfile)
	sfile = "tmp/#{s2tfile}.wav"
		puts "processing #{sfile}"
	audio = Speech::AudioToText.new("#{sfile}")
	output = audio.to_text
end

tname = convert_to_text("name")
tarea = convert_to_text("area")
trooms = convert_to_text("rooms")

puts "Name: #{tname}"
puts "Area: #{tarea}"
puts "Bedrooms: #{trooms}"
