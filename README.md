Build script

Takes a newly created image and updates the image to install kstars, indi, and PHD2 latest releases to create a new image.

Documentation is pending.

This is state of change and is being developed.

01-network-manager-all.yaml		Network netplan
50-cloud-init.yamli			Cloud netplan
51-cloud-wifi.yaml			Cloud wifi netplan (created via wifi
					    script - wifi_setup.sh)
566121.jpg				Background image 1
566122.jpg				Background image 2
999_decompress_rpi_kernel		For SSD kernel decompression**
99-disable-network-config.cfg		Part of netowrk setup
all_ekos				Sudo Entry
auto_decompress_kernel			For SSD kenernal decompression**
cleanup.sh				Clean up script to remove install files
cmdline.txt_mmblk			Boot cmdline for SD cards
cmdline.txt_sda				Boot cmdline for SSD disks
_file_installer.sh			Install script for files
image_config.sh				Selects x11vnc/greeter
Image_Update_Readme.txt			(image update readme)
indiwebmanager.service			Service file for Indi web manager
lightdm-gtk-greeter.conf		ligthdm greeter config
motd					Message of the Day, version info
_package_installer.sh			Install script for packages
_phd2_install.sh			Install script for phd2
rc.local				Local RC file for server
_run_time_setup.sh			Install script for setup
services.sh				--check--
start_hotspot.sh			Start HotSpot
_start_install.sh			Install start script 
Update.list
wifi_setup.sh				Wifi setup scrirpt
x11vnc.service				Service file for x11vnc service


