#!/bin/bash

# Script converts SD to SSD for booting

##set -x
# mount points
SSD=/ssd
SSD_DEV=/dev/sda
RSYNCLOG=/tmp/rsync_log

# ckyorn function with defaults
ckyorn () {
    return=0
    if [ "$1" = "y" ] ; then
        def="y"
        sec="n"
    else
        def="n"
        sec="y"
    fi

    while [ $return -eq 0 ]
    do
        read -e -p "([$def],$sec): ? " answer
        case "$answer" in
                "" )    # default
                        printf "$def"
                        return=1 ;;
        [Yy])   # yes
                        printf "y"
                        return=1
                        ;;
        [Nn] )   # no
                        printf "n"
                        return=1
                        ;;
                   *)   printf "    ERROR: Please enter y, n or return.  " >&2
                        printf ""
                        return=0 ;;
        esac
    done

}


# Run as sudo
if [ $(id -u) != 0 ]; then
   echo "Please run using sudo ./.sd_to_ssd_conv.sh  Exiting..."
   exit 1
fi

echo
echo "This script converts the Ekos/Ubuntu SD contents to an SSD device.."
echo
echo "Hit any key to continue, or control-C to abort!"
read $ANS



# check for device, it should be /dev/sda
if (! fdisk -l ${SSD_DEV} &> /dev/null) ; then
    echo "${SSD_DEV} device is not found..."
    echo
    exit
fi

# remove autousb package, if present
# (may be able to work around using filters)
##if (apt list --installed | grep usbmount) ; then
##    echo "Package usbmount was found, Removing it (interferes with script)..."
##    apt remove usbmount
##fi

# Create the SSD disk partition.
# below may need to be edited. I may want to see if I can automate this
# better.


# below is not optimized
#old
##P1_START=2048
##P1_END=1050623

#new
P1_START=65535
P1_END=1114094
#new
P2_START=$(expr $P1_END + 1)

# calculate last sector
LASTS=$(fdisk -l /dev/sda | grep /dev/sda | grep sector | awk '{print $7}')
LASTSECTOR=$(expr $LASTS - 1)

echo "Creating Partiions..."
echo

parted $SSD_DEV << EOF
rm 1
rm 2
mktable msdos
unit s
mkpart primary fat32 $P1_START $P1_END
mkpart primary ext4 $P2_START $LASTSECTOR
quit
EOF

if [ $? -ne 0 ]
then
  echo "Error creating partitions."
  exit 1
fi

echo "Creating File systems..."
echo
# now partprobe the loop device
partprobe $SSD_DEV
mkfs.vfat -I ${SSD_DEV}1
# added -I option
if [ $? -ne 0 ]
then
  echo "Error creating FAT Filesystem."
  exit 1
fi

mkfs.ext4 "${SSD_DEV}2"
if [ $? -ne 0 ]
then
  echo "Error creating ext4 Filesystem."
  exit 1
fi

#label the disk partitions
echo "Labeling new partitions..."
echo

fatlabel ${SSD_DEV}1 ssd-sysboot
e2label  ${SSD_DEV}2 ssd-writable

echo "Creating mount points and mounting newly created filesystems..."
echo
# mount the new filesystems
# make mount point and mount
mkdir $SSD
mount ${SSD_DEV}2 $SSD
mkdir -p ${SSD}/boot/firmware
mount ${SSD_DEV}1 ${SSD}/boot/firmware

# create the directories needed on ssd
mkdir ${SSD}/dev ${SSD}/media ${SSD}/mnt ${SSD}/proc ${SSD}/run ${SSD}/sys ${SSD}/tmp
if [ $? -ne 0 ]
then
  echo "Error creating directories."
  exit 1
fi

# change permissions
chmod 755   ${SSD}/dev ${SSD}/media ${SSD}/mnt ${SSD}/proc ${SSD}/run ${SSD}/sys
chmod a+rwxt ${SSD}/tmp

# now to transfer files
echo "Starting Rsync..."
echo

rsync -alDH  --force --exclude '/dev' --exclude '/media' --exclude '/mnt' \
    --exclude '/proc' --exclude '/run' --exclude '/sys' --exclude '/tmp' --exclude '/ssd' \
    --exclude '/lost\+found' --exclude '/etc/udev/rules.d/70-persistent-net.rules' \
    /   ${SSD}/ | tee -a $RSYNCLOG


echo "Rsync completed..."

# Change /etc/fstab to reflect new labels.

echo "updating /etc/fstab..."
echo

if [ ! -f $SSD/etc/fstab_save ] ; then
    cp $SSD/etc/fstab $SSD/etc/fstab_save
fi

sed -i 's/system-boot/ssd-sysboot/' $SSD/etc/fstab
sed -i 's/writable/ssd-writable/' $SSD/etc/fstab

echo "Updating cmdline.txt with new label..."
echo
# change cmdline.txt
sed -i 's/root=LABEL=writable/root=LABEL=ssd-writable/' $SSD/boot/firmware/cmdline.txt

echo "Setup Boot files which includes kernal uncompression..."
echo
# setup boot
bash ./BootFix.sh

#Hash the new kernel for checking
BTPATH=$SSD/boot/firmware
CKPATH=$BTPATH/vmlinuz
DKPATH=$BTPATH/vmlinux

md5sum $CKPATH $DKPATH > $BTPATH/check.md5
if [ ! $? == 0 ]; then
   echo -e "\e[31mMD5 GENERATION FAILED!\e[0m"
else
   echo -e "\e[32mMD5 generated Succesfully\e[0m"
fi

# installation of astrometic files

echo    "Do you want to install astrometric fits files (for local plate solving)"
echo -n "on our ssd device?" ; ANS=$(ckyorn n)

if [ "$ANS" = "y" ] ; then
    if [ ! -d $SSD/astrometry ] ; then
        mkdir $SSD/astrometry
        chown ekos.ekos $SSD/astrometry
        chmod 755 $SSD/astrometry
    fi
    cd $SSD/astrometry
    /usr/local/bin/get_astrometry_index.sh

    # set permissions
    chown ekos.ekos $SSD/astrometry/*
    chmod 644 $SSE/astrometry/*
fi

echo "Unmounting $SSD directory and cleaning up..."
echo

# umount filesystems
sync; sync
umount $SSD/boot/firmware
umount $SSD
# e2label /dev/sda2 ssd-writable # already done 

# clean up mount directory
if [ -d /$SSD ] ; then
   rmdir "/$SSD"
fi

echo "========================================================================"
echo "Completed..."
echo "  Now shutdown Rpi4 and remove SD card from Rpi4. Turn on Rpi4 and start"
echo "  the boot process using the SSD"
echo "========================================================================"

exit

