#!/bin/bash

# change pw, select band, select channel

HOTSPOTNAME=EkosHotSpot
PASSWORD=Ekos4192

# Rpi4 uses 20 Mhz Band with for 5Ghz wifi

# uncomment desired Band (2.4/5 Ghz), only one should be commented out
#BAND=bg   #2.4Ghz
BAND=a    #5Ghz

# Select Channel, again, only 1 should be commented out
#CHNL=2    #2.4Ghz
CHNL=44   #5Ghz

nmcli radio wifi on

echo "Starting Hotspot..."
echo
echo "       Band:  $BAND  "
echo "    Channel:  $CHNL  "
echo "       SSID:  $HOTSPOTNAME"
echo "   PASSWORD:  $PASSWORD"
echo

sudo nmcli d wifi hotspot ifname wlan0 band ${BAND} channel ${CHNL} ssid ${HOTSPOTNAME} password ${PASSWORD}


sudo nmcli device wifi show-password

nmcli connection show




