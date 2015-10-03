#!/bin/bash
# Bash Based Password generator and encrypter
# By ZeD

# Generate new password and hash it as sha512
PW=`tr -cd '[:alnum:]' < /dev/urandom | fold -w12 | head -n1`
NEWHASH=`python lib/hashpw.py -6 -p $PW | awk '{print $2}'` 

#Check root 
(( EUID )) && echo ‘You need to be root.’ && exit 1

echo "# Password Generator v0.1"

	read -p "Enter Username:" username
	# Check that user exists
	grep -w ^$username /etc/shadow > /dev/null 2>&1 || { echo "# User $username Does not exist, exiting" ; exit 1; }

read -p "Enter Encryption Email:" encuser


# Get current hash
CURRENT=`grep $username /etc/shadow | awk -F: '{print $2}'` 

# create a password file and encrypt it
echo $PW > pw_file ; gpg -r $encuser -e pw_file > /dev/null 2>&1 ; rm -f pw_file 

# Change the password for the user
sed -i "s#$CURRENT#$NEWHASH#" /etc/shadow

echo "# The password has been generated and is now encrypted in pw_file.gpg
# it can be decrypted ONLY by $encuser's key"

