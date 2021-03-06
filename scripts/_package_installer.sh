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

echo
echo "Adding Guide Star Catalogue (for simulator)..."
sudo apt install -y gsc

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

# Misc Programs
echo
echo "Installing ftools-fv (fits editor)..."
apt install -y ftools-fv

# file manager
echo
echo "Installing Nautis File Manager..."
apt install -y nautilus

#####################################################
# removals
#####################################################

## snap removal, not needed.
echo
echo "Removing Snap from server, not needed..."
snap list
snap remove --purge lxd
snap remove --purge core18
snap remove --purge core20
snap remove --purge snapd
rm -rf /var/cache/snapd

apt autoremove -y --purge snapd gnome-software-plugin-snap
apt autoremove -y --purge snapd gnome-software-plugin-snap
apt-mark hold snapd

# Auto remove any files not needed
echo
echo "Remove an files not needed..."
apt autoremove -y

exit

