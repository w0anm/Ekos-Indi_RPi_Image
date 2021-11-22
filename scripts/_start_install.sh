#!/bin/bash

# Start installation

echo "Interactive script to be executed as root..."
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# first update system
echo
echo "Updating OS level files..."
apt -y update
apt -y upgrade
apt -y autoremove

echo
echo "Adding htpdate Package..."
apt -y install htpdate
dpkg-reconfigure tzdata

# change hostname
HOSTNAME_DEF="indi-server"
echo
echo "Hostname must be alphanumeric and only use  dash '-' for the symbol."
echo -n "Enter the new hostname for this server [$HOSTNAME_DEF]" ; read HOSTNAME
if [ -z "$HOSTNAME" ] ; then
    HOSTNAME=$HOSTNAME_DEF
fi
echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

# install ekos user
useradd -c "Ekos User" -s /bin/bash -m -G admin,dialout,video ekos
echo
echo "Enter the password for Ekos..."
passwd ekos

# install packages
echo
echo "Install the required system Packages..."
bash _package_installer.sh

# install files
echo
echo "Install various files for services and executables..."
bash _file_installer.sh

echo
echo "Starting Services"
bash _services.sh

# disable sleep
echo
echo "Disable Power Sleep Function..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo
echo "Cleanup..."
bash /root/cleanup.sh

# reboot
shutdown -r now

