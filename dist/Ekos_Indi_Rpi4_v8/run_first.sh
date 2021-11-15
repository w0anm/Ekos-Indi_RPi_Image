#!/bin/bash

echo "Extracting scripts and executing _start_install.sh..."
echo

cp /boot/firmware/scripts.tar /root/scripts.tar
cd /root
tar xf scripts.tar
cd scripts

bash _start_install.sh


