#!/bin/bash

. lib/ascii.sh
. lib/config.sh

printf "\033c"

OZ=28
tracklist="lib/tracks.txt"

readlinks() {
	if [ -e $tracklist ]
		then 
			cat $tracklist
			read -p "Select Song, Select R for Random:" tracknum
				if [ $tracknum = "R" ]
					then 	
						tracknum=$(shuf -n 1 $tracklist | awk '{print $1}' | sed 's/\.//')
						
				fi
		else
			echo "ERROR: Tracks File missing \"$tracklist\""
	fi
	    }

play() {
	
		$MPLAYER -x 640 -y 360 -nocache -cookies -cookies-file /tmp/cookie.txt $(youtube-dl -g --cookies /tmp/cookie.txt "$selectedurl") > /dev/null &
	}



check_mplayer


read -p "How much do you have (in OZ)? " totalw
totalw_gr=$(echo "$totalw * $OZ" | bc) 
total_hits=`awk 'BEGIN{printf("%0.2f", '$totalw_gr' * '2')}'`

echo "You have $totalw Oz of weed, This should be enough for $total_hits Hits!" 
		if [ $totalw -gt 3 ]
			then echo "Damn! you got a lot of weed, this will require some background music!!"
				sleep 2
					readlinks
					selectedurl=$(awk "NR==$tracknum" $tracklist | awk '{print $2}')
					selectedtrack=$(awk "NR==$tracknum" $tracklist | awk -F' - ' '{print $2" - "$3}')
							echo "Playing: $selectedtrack" 
						play
		fi
	sleep 2
echo "Spark" ; sleep 1 ; clear
echo "$lighter            $spark"
	sleep 2 

printf "\033c"
COUNTER=0
while [ ! $COUNTER = $totalw_gr ] ; do 
	echo "$smoke1"
	echo "Hit Count $COUNTER"
		sleep 1
		printf "\033c"
	COUNTER=$(($COUNTER + 1))
	echo "$smoke2"
	echo "Hit Count $COUNTER"
		sleep 1
		printf "\033c"
done 

