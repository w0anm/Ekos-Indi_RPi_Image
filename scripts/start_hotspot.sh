#!/bin/bash

HOTSPOTNAME=EkosHotSpot
PASSWORD=Ekos4192

echo "Starting Hotspot..."
sudo nmcli d wifi hotspot ifname wlan0 ssid ${HOTSPOTNAME} password ${PASSWORD}

echo "Control-C to abort/stop..."




