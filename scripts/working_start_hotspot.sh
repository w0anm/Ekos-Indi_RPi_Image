#!/bin/bash

# change pw, select band, select channel

HOTSPOTNAME=EkosHotSpot
PASSWORD=Ekos4192

# Rpi4 uses 20 Mhz Band with for 5Ghz wifi

# uncomment desired Band (2.4/5 Ghz), only one should be commented out
BAND=bg   #2.4Ghz
#BAND=a    #5Ghz

# Select Channel, again, only 1 should be commented out
CHNL=2    #2.4Ghz
#CHNL=60   #5Ghz

usage() 

# parse command line into arguments
while getopts "h:c:b:sp:" arg
do
   case ${arg} in
    h )   # Usage
          usage
          exit 1
          ;;
    c )   # Channel
          CHNL=${OPTARG}
          ;;
    b )   # Band
          BAND=${OPTARG}
          ;;
    s )   # show password
          SHOWPW=yes
          ;;
    p )   # password
            PASSCHG=${OPTARG}
          ;;
    \? )  #invalid
         echo "invalid option "
          usage
          exit 1
          ;;
   esac
done

echo "nmcli radio wifi on"

echo
echo "       Band:  $BAND  "
echo "    Channel:  $CHNL  "
echo "       SSID:  $HOTSPOTNAME"
echo "   PASSWORD:  $PASSWORD"
echo
echo "     SHOWPW:  $SHOWPW"
echo "    PASSCHG:  $PASSCHG"


echo "sudo nmcli d wifi hotspot ifname wlan0 band ${BAND} channel ${CHNL} ssid ${HOTSPOTNAME} password ${PASSWORD}"

if [ -n "$SHOWPW" ] ; then
    echo "sudo nmcli device wifi show-password"
fi

# show status
echo "nmcli connection show"




