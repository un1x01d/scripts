#!/bin/bash


smoke1="
		.,;
              ';,.'      ';.,'
                      ;,.;'

                  ;.,:   '.,;,
               ',.  .',;;.',;
             ____________
             \oooooooooo/
              \________/
              {________}
               \______/
                ',__,'
                 |oo|
                 |oo|    _____
                 |==|   / ___()
                 |==|  / /
                 |oo| / /
                 |oo|/ /
                 |==/ /
                 |='./
                 |oo|
                 |==|
                 |__|
               ,'____',
             /_________\\

"

smoke2="
		.,;
         ';,.'      ';.,'
               ;,.;'

                ;.,:   '.,;,
             ',.  .',;;.',;
             ____________
             \oooooooooo/
              \________/
              {________}
               \______/
                ',__,'
                 |oo|
                 |oo|    _____
                 |==|   / ___()
                 |==|  / /
                 |oo| / /
                 |oo|/ /
                 |==/ /
                 |='./
                 |oo|
                 |==|
                 |__|
               ,'____',
             /_________\\

"
lighter="
          )
         (
          ))
         ( )
        (( )
         \/_ _
        .()  |_).
        |'-...-'|
        |       |
        |'-...-'|
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        '-.._..-'

"
printf "\033c"

OZ=28

read -p "How much do you have (in OZ)? " totalw
scale=0
totalw_gr=$(echo "$totalw * $OZ" | bc) 
total_hits=`awk 'BEGIN{printf("%0.2f", '$totalw_gr' * '2')}'`

echo "You have $totalw of weed, This should be enough for $total_hits Hits!" 
	sleep 2
echo "Spark" ; sleep 1 ; clear
echo "$lighter"
	sleep 1 

printf "\033c"
COUNTER=0
while [ ! $COUNTER = $totalw_gr ] ; do 
	echo "$smoke1"
	sleep 1
	printf "\033c"
	COUNTER=$(($COUNTER + 1))
	echo "$smoke2"
	sleep 1
	printf "\033c"
done 
