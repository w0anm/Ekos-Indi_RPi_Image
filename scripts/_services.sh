#!/bin/bash


# services will enable/disable services that are either required or not.

# add vnc password in order to start xllvnc service via image_control.sh
echo
echo "Setting x11vnc password..."
x11vnc -storepasswd

# indiwebmanager
echo
echo "Enable indiwebmanager service..."
systemctl daemon-reload
systemctl enable indiwebmanager.service

echo
echo "Stop upower Services, not needed..."
# stop and disable upower.service - not really needed
systemctl stop upower.service
systemctl disable upower.service


