#!/bin/bash

# Generate new password and hash it as sha512
PW=`tr -cd '[:alnum:]' < /dev/urandom | fold -w12 | head -n1`
NEWHASH=`python hashpw.py -6 -p $PW | awk '{print $2}'` 


echo "# Password Generator v0.1"
read -p "Enter Username:" username
read -p "Enter Encryption Email:" encuser

# Get current hash
CURRENT=`grep $username /etc/shadow | awk -F: '{print $2}'` 

# create a password file and encrypt it
echo $PW > pw_file ; gpg -r $encuser -e pw_file ; rm -f pw_file 

# Change the password for the user
sed -i "s#$CURRENT#$NEWHASH#" /etc/shadow
