#!/bin/bash
# mac-shuffle.sh
#   assigns a random mac-address to the given network interface.
#   make sure to turn off the device before trying to change a mac address.
#
# dependencies:
#   - net-tools
#
# usage:
#   mac-shuffle.sh wlan0
#

if [ -z "$1" ] || ! ifconfig -a | grep -q $1; then
  echo "Device \"$1\" not found!"
  echo " Please run: $0 <devname>"
  echo " parameter: <devname> must be a valid device like wlan0, wlan1,..."
  exit 1
fi

while [ "$ret" != "0" ]; do
  mac=$((date; cat /proc/interrupts) | md5sum | sed -r 's/^(.{12}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;')
  echo -n "trying to assign \"$mac\" to \"$1\": "
  ifconfig $1 hw ether $mac 2> /dev/null
  if [ "$?" != "0" ]; then echo "FAIL"; else echo "OK"; exit; fi
  sleep 1
done
