#!/usr/bin/ruby

require 'yaml'
yamlfile = YAML.load_file('test.yml')
puts yamlfile["test1"]
puts yamlfile["test2"]
