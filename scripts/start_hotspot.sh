#!/bin/bash

HOTSPOTNAME=EkosHotSpot
PASSWORD=Ekos4192

nmcli radio wifi on

echo "Starting Hotspot..."
sudo nmcli d wifi hotspot ifname wlan0 ssid ${HOTSPOTNAME} password ${PASSWORD}


sudo nmcli device wifi show-password

nmcli connection show


