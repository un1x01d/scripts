#!/usr/bin/ruby
require 'speech'

file = ARGV[0]
audio = Speech::AudioToText.new("#{file}")

name = audio.to_text
puts name
