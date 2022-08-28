#!/bin/bash

# This script takes the standard configuration for networking and 
# converts it to allow static IP address without internet dependencies.
# The confiuration also  allow allows  cross over cable (local w/o 
# internet connectivity)
# The script does the following:
#       Disables system-resolved services 
#       Sets static address
#       Disable auto network configuration
#       set's up resolv.conf (dns resolving)
#       Adds host information to /etc/hosts
#

# Variables
LocalIP="192.168.15.61"
NetMask="/24"
GateWay="192.168.15.1"
NameServers="192.168.15.20"
ServerName=indi-server-test
SearchDNS=w0anm.com

# Must be executed as root
if [ "$(id -u)" != "0" ] ; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

echo "Following are defined in script:"
echo
echo "  LocalIP     = $LocalIP"
echo "  NetMask     = $NetMask"
echo "  GateWay     = $GateWay"
echo "  NameServers = $NameServers"
echo "  ServerName  = $ServerName"
echo "  SearchDNS   = $SearchDNS"
echo
echo "If this is correct, press any key, else use ^C to abort and edit this file." ; read $ANS

# disable system-resolved services
echo "Disabling systemd-resolved..."
systemctl disable systemd-resolved
systemctl stop systemd-resolved

# remove cloud configuration
echo "Disabling cloud network automation config..."

if [ ! -f etc/cloud/cloud.cfg.d/99-disable-network-config.cfg ] ; then
    echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
fi

# adds new static configration
#       - setups up static IP and DNS resolution
# install new file: /etc/netplan/40-eth0-static.yaml
echo "Adding new netplan if necessary..."
if [ -f /etc/netplan/40-eth0-static.yaml ] ; then
    rm -f /etc/netplan/40-eth0-static.yaml
fi

cat << _EOF >> /etc/netplan/40-eth0-static.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses: [ "${LocalIP}${NetMask}" ]
      gateway4: ${GateWay}
      dhcp4: no
      nameservers: 
        addresses: [ ${NameServers} ]
        search: [ ${SearchDNS} ]
_EOF

chmod 644 /etc/netplan/40-eth0-static.yaml

# remove old:
echo "Removing old cloud init network plan..."
if [ -f /etc/netplan/50-cloud-init.yaml ] ; then
    rm /etc/netplan/50-cloud-init.yaml
fi

# This is customized for my own local network.
# add IP to local /etc/hosts file
echo "Adding local IP to /etc/hosts..."
if ( ! grep ${LocalIP} /etc/hosts > /dev/null) ; then
    echo "${LocalIP}       ${ServerName}" >> /etc/hosts
else
    echo "Already present in /etc/hosts"
fi

# /etc/NetworkManager/NetworkManager.conf - Add after [main]:
#    dns=none
if ( ! grep "dns=none" /etc/NetworkManager/NetworkManager.conf > /dev/null) ; then
    sed -i '/\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
fi

# create /etc/resolv.conf if not present
#    netplan never created this one, or it's due to a link.
echo "Creating /etc/resolv.conf"
rm -f /etc/resolv.conf
echo "search ${SearchDNS}" > /etc/resolv.conf
echo "nameserver ${NameServers}" >> /etc/resolv.conf

#  Reboot?
echo
echo "Do you want to reboot now (yes/no)? " ; read ANS

if [ "$ANS" = "yes" ] ; then
    echo "Rebooting..."
    shutdown -r now
fi 


# convert back?

