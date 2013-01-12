#!/bin/bash

JUMP="ash.functionxinc.net"
PORT=9091

if [ -z $1  ] 
	then 
		read -p "Which Host to connect to ?:" TARGET 
		read -p "Which local port to use ? :" PORT

	else 
		TARGET=$1
		PORT=$2
fi

echo "TUNNEL: to $TARGET over $JUMP on local port $PORT"

<<<<<<< HEAD
ssh -vv -L9091:$TARGET.mgmt:9090 $JUMP -NCf
=======
ssh -L9091:$TARGET.mgmt:9090 $JUMP -NCf
>>>>>>> 6d7258e22faa4b02bc1504cef99a2247394081a2

