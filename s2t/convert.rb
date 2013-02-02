#!/usr/bin/ruby
require 'speech'

file = "zaya.wav"
audio = Speech::AudioToText.new("#{file}")

name = audio.to_text
puts name
