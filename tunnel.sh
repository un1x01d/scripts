#!/bin/bash

JUMP=""
PORT=9092

if [ -z $JUMP ]
	then 
		echo "ERROR: Jump host is not set"
fi

if [ -z $1  ] 
	then 
		read -p "Which Host to connect to ?:" TARGET 
		read -p "Which local port to use ? :" PORT

	else 
		TARGET=$1
		PORT=$2
fi

echo "TUNNEL: to $TARGET over $JUMP on local port $PORT"

ssh -L9092:$TARGET.mgmt:9090 $JUMP -NCf
ssh -L9091:$TARGET.mgmt:9090 $JUMP -NCf
