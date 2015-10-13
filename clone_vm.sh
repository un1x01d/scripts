#!/bin/bash
# KVM Cloning Tool
# Version: v0.2
# By ZeD
#
# Usage: ./clone_vm.sh -n [target/hostname] -i [ip] -l [lab-name] -a [action] -h [help]
#
# Prerequisites:
# - Set the VARIABLES below to fit your environment 
#
# TODO:
# - Parameter to create lab
# - Automatically create paths
# - Remove hardcoded xml/qcow2 directories

WORKSPACE="/vm" # Path to the workspace 
GOLDEN_IMG="golden.qcow2" # Image filename, the file needs to exist in $WORKSPACE/qcow2/
TEMPLATE_XML="template.xml" # XML template filename, the file needs to exist in $WORKSPACE/xml/

echo "
######## KVM Cloning tool ########
 "

function usage() {
echo "Usage: $0 -n [target/hostname] -i [ip] -l [lab-name] -a [action] -h [help]"
  exit 1
}

if [ $# -eq "0" ] ; then usage; fi

while getopts "a:n:l:i:h:" opt; do
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
    h)
       usage 
       ;;
    *)
       usage 
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
  echo '# Clone XML template' ; cp -v $LAB/xml/$TEMPLATE_XML $LAB/xml/$TARGET.xml >> /dev/null
  echo '# Clone Golden image' ; cp -v $LAB/qcow2/$GOLDEN_IMG $LAB/qcow2/$TARGET.qcow2 >> /dev/null
  echo "# Applying parameters to new template ($TARGET.xml)"

  sed -i "s/NAME/$TARGET/;s/DISK_ID/$TARGET/;s/LAB/$LAB/g;s/MAC_ADDRESS/$MACADDRESS/" $LAB/xml/$TARGET.xml
  virsh define $LAB/xml/$TARGET.xml >> /dev/null 

  else echo "ERROR: Target name is empty"
     exit 1
fi

echo "# Applying changes to image ($TARGET.qcow2)"

# Verify root privilages 
(( EUID )) || echo "# Root privilages are required to mount image #" ; sudo -l >> /dev/null 

echo '# - Connecting image to NBD' ;
  sudo modprobe nbd max_part=8
  sudo qemu-nbd --connect=/dev/nbd0 $LAB/qcow2/$TARGET.qcow2 >> /dev/null

echo "# - Mounting image"  
mkdir -p /tmp/$TARGET
sudo mount /dev/nbd0p1 /tmp/$TARGET

echo "# - Applying network changes ( IP: $IP - Hostname: $TARGET )"
sudo sh -c "echo $TARGET > /tmp/$TARGET/etc/hostname"
sudo sh -c "sed -i 's/IP_ADDRESS/$IP/' /tmp/$TARGET/etc/network/interfaces"
sleep 1

echo "# - Unmounting image"
sudo umount /tmp/$TARGET
sudo qemu-nbd --disconnect /dev/nbd0 >>/dev/null

sleep 1
rm -rf /tmp/$TARGET

if [[ $ACTION = 'start' ]] ; then
   echo "# Action '$ACTION' provided, starting instance"
   virsh start $TARGET >> /dev/null ; [ $? -eq 0 ] && echo "# Instance start"
 exit 0  
fi
