#!/usr/bin/ruby

require 'speech'

file = ARGV[0]
audio = Speech::AudioToText.new("#{file}")
puts audio.to_text
