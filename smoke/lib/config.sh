#!/bin/bash

mplayer_config() {
mplayerconf="~/.mplayer/config"
	echo "
prefer-ipv4 = yes
nolirc= yes
really-quiet= 1
" >> $mplayerconf
	}

get_os() {
	. /etc/os-release
	OS=$NAME
	}


check_mplayer() {
	get_os
	MPLAYER="/bin/mplayer"
	if [ ! -e $MPLAYER ]
		then echo "Mplayer is not installed!"
			sleep 1
			echo "Installing"
				sleep 1
				case $OS in 
			
					Fedora) 
						sudo yum install mplayer -y > /dev/null
						;;	
					Ubuntu)
						sudo apt-get install mplayer -y > /dev/null
		 				;;
				esac

			if [  $? = "0" ] 
				then echo "SUCCESS: Installed"
				else echo "ERROR: Install Failed"
			fi

			if [ -f $mplayerconf ]
				then echo "Configuring Mplayer."
					mplayer_config
				else echo "Mplayer Config is missing, Creating."
					mplayer_config
			fi

		 
 	fi
		rm -f .tmp_mp
		}
