#!/bin/bash

# rpi-serv
SysToChk=192.168.15.20


while :
do
    # loop check
    if ping -q -c 1 -W 1 $SysToChk  >/dev/null; then
      echo "Wifi is up" > /dev/null
      #echo "Wifi is up" 
    else
      echo "Network Monitoring Error: Wifi is down" | logger
      # reset network
      sudo /usr/sbin/netplan apply | logger
      echo "Network Monitoring netplan re-applied" | logger

    fi
    sleep 20
done

