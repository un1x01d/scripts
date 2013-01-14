#!/bin/bash

mplayer_config() {
mplayerconf="$HOME/.mplayer/config"
echo " 
prefer-ipv4 = yes
nolirc= yes
really-quiet= 1" >> $mplayerconf 
	}

get_os() {
	. /etc/os-release
	OS=$NAME
	}

check_root() {
	if [ "$(id -u)" != "0" ] 
		then
   			echo "This script must be run as root" 1>&2
  	 			exit 1
	fi
	     }

install_mplayer() {
	#check_root
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
}

check_mplayer() {
	get_os
	MPLAYER="/bin/mplayer"
	if [ ! -e $MPLAYER ]
		then read -p "Mplayer is not installed! (y/n) [Default:y]" install_response
				case $install_response in 
					y)
						install_mplayer	
					;;
					n)
						echo "Mplayer is required, exiting."
							exit 1
					;;
					*)	
						install_mplayer	
					;;
				esac

			if [ -f $mplayerconf ]
				then echo "Configuring Mplayer."
					mplayer_config
				else echo "Mplayer Config is missing, Creating."
					mplayer_config
			fi

		 
 	fi
		rm -f .tmp_mp
		}
