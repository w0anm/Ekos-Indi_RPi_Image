#!/bin/bash

#

# update indi-lib packages

#update and upgrade OS and packages

##echo "update and then upgrade"
##sudo apt-get update && sudo apt-get upgrade

apt --upgradable list | awk '{print $1}'

# just indi packages, basic packages
sudo apt-get update
sudo apt-get install indi-full libindi1 indi-bin


