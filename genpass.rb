#!/usr/bin/ruby

require 'digest/sha2'

user = "zed1"


def generate_passwd(length=20)
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
  Array.new(length) { chars[rand(chars.length)].chr }.join
end

# Generate new hash
pw = generate_passwd
salt = rand(36**8).to_s(36)
newhash = pw.crypt("$6$" + salt)

# Generate new hash
getline = File.foreach('/etc/shadow').grep(/^#{user}/)
rootline = "#{getline}"
oldhash = rootline.split(':')[1]

# Replace hash
shadowfile = "/etc/shadow"
shadow = File.read(shadowfile)
puts = shadow.gsub("#{oldhash}", "#{newhash}")
File.open(shadowfile, "w") { |file| file << puts }

# Output file to password and encrypt
outfile = "pw_list" 
open("#{outfile}", 'w') { |f|
  f.puts "#{salt}"
}

puts "User: #{user}"
puts "Password: #{pw}"
puts "Old Hash: #{oldhash}"
puts "New Hash: #{newhash}"
