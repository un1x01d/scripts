#!/bin/bash


export TERM="xterm-256color"
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

function red() {
    echo -e "$RED$*$NORMAL"
}

function green() {
    echo -e "$GREEN$*$NORMAL"
}

function yellow() {
    echo -e "$YELLOW$*$NORMAL"
}


get_os() {
	. /etc/os-release
	OS=$NAME
	}


function check_livestreamer() {
	get_os
	LIVESTREAMER="/usr/bin/livestreamer"
	if [ ! -e $LIVESTREAMER ]
		then read -p "Livestreamer is not installed! (y/n) [Default:y]" install_response
				case $install_response in 
					y)
						install_livestreamer	
					;;
					n)
						echo "Livestreamer is required, exiting."
							exit 1
					;;
					*)	
						install_livestreamer	
					;;
				esac

 	fi
		}

function install_livestreamer {
	get_os
		if [ $OS = "Ubuntu" ]
			then sudo apt-get install livestreamer
			elif [ $OS = "Fedora" || -e "/etc/redhat-release" ]
				then 
					if [ -x /usr/bin/pip ]
						then pip install livestreamer
						else sudo yum  install python-pip && pip install livestreamer
					fi
			fi
	}
