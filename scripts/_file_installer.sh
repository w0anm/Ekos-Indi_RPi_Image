#!/bin/bash

# This installs various files for Indi Server


## 50-cloud-init.yaml  /etc/netplan
## 566121.jpg  /usr/share/backgrounds
## 566122.jpg  /usr/share/backgrounds

# Update.list
# cleanup.sh /root
# motd       /etc
# wifi_setup.sh  /usr/local/bin

# Files  to install:

install -o root -g root -m 755 cleanup.sh /root/cleanup.sh
install -o root -g root -m 644 01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml
install -o root -g root -m 644 50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
install -o root -g root -m 644 motd /etc/motd
install -o root -g root -m 755 wifi_setup.sh /usr/local/bin/wifi_setup.sh
install -o root -g root -m 644 566121.jpg /usr/share/backgrounds/566121.jpg
install -o root -g root -m 644 566122.jpg /usr/share/backgrounds/566122.jpg
install -o root -g root -m 0440  all_ekos /etc/sudoers.d/all_ekos
install -o root -g root -m 755 vnc_greeter_control.sh /usr/local/bin/vnc_greeter_control.sh
install -o root -g root -m 644 x11vnc.service /lib/systemd/system/x11vnc.service
install -o root -g root -m 644 indiwebmanager.service /etc/systemd/system/indiwebmanager.service
install -o ekos -g ekos -m 755 -d /home/ekos/bin
install -o root -g root -m 755 start_hotspot.sh /usr/local/bin/start_hotspot.sh
install -o root -g root -m 755 stop_hotspot.sh /usr/local/bin/stop_hotspot.sh
install -o root -g root -m 644 default-wifi-powersave-on.conf /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
install -o root -g root -m 644 usbmount.rules /lib/udev/rules.d/usbmount.rules
install -o root -g root -m 755 rc.local /etc/rc.local

# /boot/firmware files
install -o root -g root -m 755 usercfg.txt /boot/firmware/usercfg.txt
install -o root -g root -m 644 lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

if [ -f /dev/sda1 ] ; then
    install -o root -g root -m 755 auto_decompress_kernel /boot/auto_decompress_kernel
    install -o root -g root -m 755 cmdline.txt_sda /boot/firmware/cmdline.txt
    install -o root -g root -m 755 999_decompress_rpi_kernel /etc/apt/apt.conf.d/999_decompress_rpi_kernel

else
    install -o root -g root -m 755 cmdline.txt_mmblk /boot/firmware/cmdline.txt
fi

# install phd2 install script
install -o ekos -g ekos -m 755 _phd2_install.sh /home/ekos/_phd2_install.sh
install -o ekos -g ekos -m 755 ekos_bashrc /home/ekos/.bashrc

# install image backup scripts
install -o root -g root -m 755 -d /usr/local/etc
install -o root -g root -m 640 bkup_local/image_backup.conf /usr/local/etc/image_backup.conf
install -o root -g root -m 750 bkup_local/image_backup.sh /usr/local/sbin/image_backup.sh
install -o root -g root -m 750 bkup_local/image_nfs_backup.sh /usr/local/sbin/image_nfs_backup.sh
install -o root -g root -m 750 bkup_local/sys-imagebkup /usr/local/sbin/sys-imagebkup

