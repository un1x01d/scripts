#!/bin/bash

WORKSPACE="/vm"

function usage() {
echo "Usage: $0 -n [target] -i [ip] -l [lab-name] -a [action]"
  exit 1
}

if [ $# -eq "0" ] ; then usage; fi

while getopts "a:n:l:i:" opt; do
  case $opt in
    a)
       ACTION=$OPTARG
       ;;
    n)
       TARGET=$OPTARG
       ;;
    l)
       LAB=$OPTARG
       ;;
    i)
       IP=$OPTARG
       ;;
  esac
done

function generate_mac ()  {
  hexchars="0123456789abcdef"
  echo "24:df:86$(
    for i in {1..6}; do 
      echo -n ${hexchars:$(( $RANDOM % 16 )):1}
    done | sed -e 's/\(..\)/:\1/g'
  )"
}

MACADDRESS=$(generate_mac)

if [ ! -z $TARGET ] ; then
  cp -v $LAB/xml/template.xml $LAB/xml/$TARGET.xml 
  cp -v $LAB/qcow2/golden.qcow2 $LAB/qcow2/$TARGET.qcow2

sed -i "s/NAME/$TARGET/;s/DISK_ID/$TARGET/;s/LAB/$LAB/g;s/MAC_ADDRESS/$MACADDRESS/" $LAB/xml/$TARGET.xml
  virsh define $LAB/xml/$TARGET.xml 
  else echo "ERROR: Target name is empty"
     exit 1
fi

sudo -l 
sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 $LAB/qcow2/$TARGET.qcow2
mkdir -p /tmp/$TARGET
sudo mount /dev/nbd0p1 /tmp/$TARGET
sudo sh -c "echo $TARGET > /tmp/$TARGET/etc/hostname"
sudo sh -c "sed -i 's/IP_ADDRESS/$IP/' /tmp/$TARGET/etc/network/interfaces"
sleep 2
sudo umount /tmp/$TARGET
sudo qemu-nbd --disconnect /dev/nbd0
sleep 2
rm -rf /tmp/$TARGET


if [[ $ACTION = 'start' ]] ; then
   virsh start $TARGET ; exit 0 
fi
