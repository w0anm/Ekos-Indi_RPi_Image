#!/bin/bash

echo "Cleanup script for new image..."

# /home/ekos/.cache/mozilla/firefox#
rm -rf /home/ekos/.cache/mozilla

# clean up root
rm -rf /root/scripts
rm -f /etc/netplan/51-cloud-wifi.yaml
cp /dev/null /root/.bash_history 
rm -f /root/cleanup /root/*.tar


# cleanup users (ekos/ubuntu)
cp /dev/null /home/ekos/.bash_history 
cp /dev/null /home/ubuntu/.bash_history 

# cleanup ssh files
cp /dev/null /root/.ssh/authorized_keys
cp /dev/null /root/.ssh/known_hosts

cp /dev/null /home/ekos/.ssh/authorized_keys
cp /dev/null /home/ekos/.ssh/known_hosts

cp /dev/null /home/ubuntu/.ssh/authorized_keys
cp /dev/null /home/ubuntu/.ssh/known_hosts


# remove files from /boot/firmware
rm -f /boot/firmware/run_first.sh
rm -f /boot/firmware/scripts.tar

# change the hostname to default
echo "indi-server" > /etc/hostname
