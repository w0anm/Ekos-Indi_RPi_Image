#!/bin/bash

# package adds and removals


# install misc
echo
echo "Installing Misc Packages..."
apt install -y  libraspberrypi-bin
apt install -y  exfat-fuse exfat-utils
apt install -y  nfs-common

# desktop
apt install -y ubuntu-desktop 

# automounter (desktop)
apt install -y usbmount

# Adding Indi Library Packages
# Install Stable Release of the INDI Library including all 3rd party drivers: 
echo
echo "Adding mutlaqja's Repositories for kstars/ekos/indi..."
apt-add-repository -y ppa:mutlaqja/ppa
apt -y update

# Install latest Indi Libraries:
echo
echo "Adding Indi driver packages and dependencies..."
sudo apt install -y indi-full kstars-bleeding

# Web Manager Install
# compile
echo
echo "Adding WebMager Software..."
sudo apt install -y python3-pip
sudo -H pip3 install indiweb


# install lightdm
echo
echo "Installing lightdm Greeter..."
apt install -y lightdm

# misc package adds 
echo
echo "Adding lightdm greeter settings..."
apt install -y lightdm-gtk-greeter-settings

# install x11vnc
echo
echo "Installing x11vnc Packages..."
apt install -y x11vnc

# removals
echo
echo "Removing Snap from server, not needed..."
## snap removal, not needed.
snap list
snap remove --purge lxd
snap remove --purge core18
snap remove --purge core20
snap remove --purge snapd
rm -rf /var/cache/snapd

apt autoremove -y --purge snapd gnome-software-plugin-snap
apt autoremove -y --purge snapd gnome-software-plugin-snap
apt-mark hold snapd


exit

