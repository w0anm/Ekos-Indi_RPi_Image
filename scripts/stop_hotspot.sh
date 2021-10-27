#!/bin/bash

echo "Disabling HotSpot..."
nmcli radio wifi off
nmcli radio wifi on

sleep 5
nmcli connection show


