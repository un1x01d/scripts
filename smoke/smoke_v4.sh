#!/bin/bash

. lib/ascii.sh
. lib/config.sh


printf "\033c"

OZ=28
tracklist="lib/tracks.txt"


#function check_livestreamer() {
#	get_os
#	LIVESTREAMER="/usr/bin/livestreamer"
#	if [ ! -a $LIVESTREAMER ]
#		then read -p "Livestreamer is not installed! (y/n) [Default:y]" install_response
#				case $install_response in 
#					y)
#						install_livestreamer	
#					;;
#					n)
#						echo "Livestreamer is required, exiting."
#							exit 1
#					;;
#					*)	
#						install_livestreamer	
#					;;
#				esac
#
# 	fi
#}
check_livestreamer

readlinks() {
	if [ -e $tracklist ]
		then 
			cat $tracklist
			read -p "Select Song, Select R for Random: " tracknum
				if [ -n $tracknum ]
					then echo "No track selected, Defaulting to Random"
						tracknum="R"
				fi 
				
				if [ $tracknum = "R" ]
					then 	
						track=$(shuf -n 1 $tracklist | awk '{print $1}' | sed 's/\.//')
					else 
						track=$tracknum
				fi
		else
			red "ERROR: Tracks File missing \"$tracklist\""
	fi
	    }

play() {
		/usr/bin/livestreamer "$selectedurl" best > /dev/null &
	}

read -p "How much do you have (in OZ)? " totalw
totalw_gr=$(echo "$totalw * $OZ" | bc) 
total_hits=`awk 'BEGIN{printf("%0.2f", '$totalw_gr' * '2')}'`

echo "You have $totalw Oz of weed, This should be enough for $total_hits Hits!" 
		if [ $totalw -gt 3 ]
			then echo "Damn! you got a lot of weed, this will require some background music!!"
				sleep 2
					readlinks
					selectedurl=$(awk "NR==$track" $tracklist | awk '{print $2}')
					selectedtrack=$(awk "NR==$track" $tracklist | awk -F' - ' '{print $2" - "$3}')
							echo "Playing: $selectedtrack" 
					play
		fi
	sleep 2
echo "$lighter            $spark"
	sleep 2 

counter_increment() {
		green "Hit Count $COUNTER"
		sleep 2
		COUNTER=$(($COUNTER + 1))
		printf "\033c"
	}

printf "\033c"
COUNTER=0
while [ ! $COUNTER = $totalw_gr ] ; do 
	yellow "$smoke1"
		counter_increment
	green "$smoke2"
		counter_increment
	red "$smoke1"
		counter_increment
	green "$leaf"
done 
