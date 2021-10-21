#!/bin/bash

# This script will create the "50-cloud-init.yaml" file using the users wifi name
# and password.


# Verify internet access is available
# if offline, then will allow re-configuration

##if [ $(ping -q -w1 -c1 google.com &>/dev/null && echo online || echo offline) == offline ] ; then

    clear
    sleep 1
    # get wifi module
    module=$(ls /sys/class/net)
    module_list=($module)
    wlan_module=${module_list[-1]}
    echo "Wifi Module: $wlan_module"

    # get wifi configuration file
    config_filename=51-cloud-wifi.yaml
    config_filepath="/etc/netplan/$config_filename"
    

    # ask  wifi pwd ssid
    read -p "What is the wifi ssid you want to connect to (Case sensitive)? " ssid

    # ask wifi pwd
    read -p "What is the wifi password? " pwd

    # null out old config
    if [ -f $config_filepath ] ; then
        sudo rm -f $config_filepath
    fi

    cat << _EOF >> /tmp/w_temp
# This file is generated from information provided by the wifi_setup.sh.  
# Changes to it will not persist across an instance reboot.  To disable 
# cloud-init's
network:
    renderer: NetworkManager
    version: 2
_EOF

    sudo cp /tmp/w_temp $config_filepath 
    sudo rm -f /tmp/w_temp
    echo "Creating new file using:"
    # append content
    echo "    wifis:" | sudo tee -a $config_filepath 
    echo "        wlan0:" | sudo tee -a $config_filepath
    echo "            dhcp4: true" | sudo tee -a $config_filepath
    echo "            optional: true" | sudo tee -a $config_filepath
    echo "            access-points:" | sudo tee -a $config_filepath
    echo "                \"$ssid\":" | sudo tee -a $config_filepath
    echo "                    password: \"$pwd\"" | sudo tee -a $config_filepath

    # generate a config file
    sudo netplan generate

    echo "Applying the new net plan..."
    # apply the config file
    sudo netplan apply
        
##fi
