#!/usr/bin/ruby

require 'digest/sha2'
require 'ruby_gpg'

raise 'Must run as root' unless Process.uid == 0

print "Username:"
$user = gets.chomp

print "Password Length:"
$pwlength = gets.chomp.to_i


def ver_int()
	if ! $pwlength.is_a? Integer
		puts "ERROR: Password length has to be an integer."
			exit 1
	end
end


def ver_length() 
	$pwmin = 8
	if $pwlength < $pwmin
		puts "ERROR: Minimum password length is #{$pwmin}."
			exit 1
	end
end

def generate_passwd(length=$pwlength)
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
  Array.new(length) { chars[rand(chars.length)].chr }.join
end

# Generate new hash
def gen_hash 
	$pw = generate_passwd
	$salt = rand(36**8).to_s(36)
	$newhash = $pw.crypt("$6$" + $salt)
end

# Get oldhash hash
def get_hash
	getline = File.foreach('/etc/shadow').grep(/^#{$user}/)
	rootline = "#{getline}"
	$oldhash = rootline.split(':')[1]
end

# Replace hash
def rep_hash
	shadowfile = "/etc/shadow"
	shadow = File.read(shadowfile)
	puts = shadow.gsub("#{$oldhash}", "#{$newhash}")
	File.open(shadowfile, "w") { |file| file << puts }
end

def enc_pass 
	outfile = "pw" 
	open("#{outfile}", 'w') { |f|
	  f.puts "#{$pw}"
	}

	RubyGpg.encrypt("#{outfile}", "zedchel@gmail.com")
		File.delete("#{outfile}")
		File.rename "#{outfile}.gpg", "#{$user}_#{outfile}.gpg"
end




ver_int
ver_length
gen_hash
get_hash
rep_hash

# Output file to password and encrypt
#$outfile = "pw_list" 
#open("#{$outfile}", 'w') { |f|
#  f.puts "#{$pw}"
#}

enc_pass


puts "User: #{$user}"
puts "Password: #{$pw}"
puts "Old Hash: #{$oldhash}"
puts "New Hash: #{$newhash}"


puts "DEBUG - Password Length: #{$pwlength}"
puts "DEBUG - Password Min Length: #{$pwmin}"
