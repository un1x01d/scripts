#!/bin/bash
# Script that creates ssh tunnels
# By ZeD
# The license is simple - enjoy the script and modify as you wish, feedback is appriciated.

SEARCH=""

usage() {
	echo "Usage: $0 -j [jumphost] -t [target] -p [remote port] -l [localport] -u [username] || Use $0 -x for interactive"
}

while getopts “hu:j:l:p:t:x” OPTION
do
	case $OPTION in
		h) usage
			exit 1
		;;
		j) JUMP=$OPTARG
		;;
		l) LPORT=$OPTARG
		;;
		p) RPORT=$OPTARG
		;;
		t) TARGET=$OPTARG
		;;
		u) USERNAME=$OPTARG
		;;
		x)
			read -p "JumpHost to use ?:" JUMP
			read -p "Host to connect to ?:" TARGET
			read -p "Remote port to connect to ?:" RPORT
			read -p "Local port to bind to ?:" LPORT
			read -p "Uusername to use ?: " USERNAME
		;;
	esac
done

if [[ -z $JUMP ]] || [[ -z $TARGET ]] || [[ -z $LPORT ]]
	then
		usage
		exit 1
fi

if [ ! -z $SEARCH ]
	then 
		TARGET="$TARGET.$SEARCH"
fi

ssh -l $USERNAME -L$LPORT:$TARGET:$RPORT $JUMP -NCf

echo "TUNNEL: to $TARGET over $JUMP now listening on local port $PORT"
