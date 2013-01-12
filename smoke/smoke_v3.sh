#!/bin/bash

. lib/ascii.sh

printf "\033c"

OZ=28
bgmusic="http://www.youtube.com/watch?v=m2QoJqBdfGE"

read -p "How much do you have (in OZ)? " totalw
totalw_gr=$(echo "$totalw * $OZ" | bc) 
total_hits=`awk 'BEGIN{printf("%0.2f", '$totalw_gr' * '2')}'`

echo "You have $totalw Oz of weed, This should be enough for $total_hits Hits!" 
		if [ $totalw -gt 3 ]
			then echo "Damn! you got a lot of weed, this will require some background music!!"
				sleep 2
				google-chrome $bgmusic
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
