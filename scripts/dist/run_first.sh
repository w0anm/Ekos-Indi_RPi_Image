#!/bin/bash

echo "Extracting scripts and executing _start_install.sh..."
echo

sudo cp /boot/firmware/scripts.tar /root/scripts.tar
sudo /bin/bash -c "cd /root/scripts ; bash _start_install.sh"


