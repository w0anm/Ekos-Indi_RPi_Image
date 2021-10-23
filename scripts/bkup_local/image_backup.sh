#!/bin/bash
#
# Image Backup Script image-backup
#
# image-backup version -  w0anm
#    for use with sys_imagebkup
#  $Id: image-backup.sh 14 2015-03-20 04:06:49Z w0anm $

# check config file
if [ ! -f /usr/local/etc/image_backup.conf ] ; then
    echo "Missing /usr/local/etc/image_backup.conf file"
    exit 1
fi

# source the configuration file
source /usr/local/etc/image_backup.conf


# Path to sys_imagebkup script
INSTALLDIR=/usr/local/sbin
IMAGESCRIPT=${INSTALLDIR}/sys-imagebkup

DATE=$(date '+%Y-%m-%d-%H%M')
NEWBKUPNAME="$(hostname -s)_${DATE}.img"

# get currently used size in MB (Add 2G (2000MB)
MIN_REQ_IMAGE_SIZE=$(expr $(df --output=used -m / |tail -n 1) + 2000)

# get blocksize for orginal rootfs partition
# moved from sys-imagebkup and will be part of the arguments to
# sys-imagebkup script.  (making sys-imagebkup non-interactive)
ROOT_PART=$(blkid  | grep ext | awk 'BEGIN {FS=":"} {print $1}')
ROOT_SIZE=0
SIZE_DETECTED=0
if [ ! -z "$ROOT_PART" ]
then
  ROOT_SIZE=$(sfdisk -s "$ROOT_PART")
fi
if [ $(($ROOT_SIZE)) -gt 102400 ]
then
  DEFAULT_IMAGE_SIZE=$(expr "$ROOT_SIZE" / 1024 + 65)
  SIZE_DETECTED=1
fi
echo
if [ "$SIZE_DETECTED" = "1" ] ; then
  echo "Calculated actual size of your root partition:  ${DEFAULT_IMAGE_SIZE} MB"
else
  echo "Unable to Calulate actual size of your partition." 
  echo "Minimum recommended root partition size:        ${MIN_REQ_IMAGE_SIZE} MB"
fi
echo -n "Size in MB [$DEFAULT_IMAGE_SIZE]: "

#III - image size other than default
read IMAGE_SIZE
if [ -z "$IMAGE_SIZE" ]
then
  IMAGE_SIZE=$DEFAULT_IMAGE_SIZE
fi

# if Raspbian then boot mount point is boot

if [ "$OSTYPE" = "RASPBIAN" ] ; then
    BOOTMNT=/boot
    OSFOUND=y
fi

# if Ubuntu then boot mount point is boot/firmware
if [ "$OSTYPE" = "UBUNTU" ] ; then
    BOOTMNT=/boot/firmware
    OSFOUND=y
fi

if [ -z "$OSFOUND" ] ; then
    echo "Operating System type not found."
    exit 1
fi

#make boot mount point if necessary
if [ ! -d $BOOTMNT ] ; then
    mkdir $BOOTMNT
fi

# check to see if mount boot mount is already created
CHKMOUNT="$(grep /dev/mmcblk0p1 /proc/mounts)"

###################################################################

# check if devmon is running, if not running,  start it
pgrep devmon &> /dev/null || /usr/bin/devmon &> /dev/null &

# if already mounted, skip
if [ -z "${CHKMOUNT}" ] ; then
    mount /dev/mmcblk0p1 $BOOTMNT
    echo "$BOOTMNT is mounted..."
else
    echo "$BOOTMNT is already mounted..."
fi

# Mount Filesystem
#    usb device
clear
cat << _EOF

+=========================================================================+
| Please insert an exFAT or ntfs formatted usb thumb drive for             |
| your backup.                                                            |
|                                                                         |
| Press any key when disk has been inserted, or  (Ctl-C) to abort..       |
|                                                                         |
+=========================================================================+"

_EOF

read ANS

# probe for mount point
echo
echo -n "Checking for media, please wait...  "
sleep 2

# get mount point
PREMOUNTPT=$(grep "/dev/sd" /proc/mounts |grep media | awk '{ print $2 }')

##cjk
echo "Premount-$PREMOUNTPT"

if [ -z "$PREMOUNTPT" ] ; then
    echo "ERROR media not found! Aborting."
    echo
    umount $BOOTMNT
    exit 1
fi

# fix spaces, if any,  in mount point
# MOUNTPT=$(printf "${PREMOUNTPT}" | sed 's/\\040/ /g')
MOUNTPT=$(printf "%s" "${PREMOUNTPT}" | sed 's/\\040/ /g')

echo "found media.  [$MOUNTPT] "
echo

# Select a file or provide a new file name.
cat << _EOF

+=========================================================================+
| Select an existing backup image file to update by entering the number   |
| next to the file.                                                       |
|                 -OR-                                                    |
| Select the number corresponding to "New" to create a new backup image.  |
+=========================================================================+
_EOF

# enter directory where the backup files are stored.
cd "$MOUNTPT"

prompt="=== Please select: "
options=( $(find -maxdepth 1 -print0 | xargs -0) )

PS3="$prompt "
# removed leading ./ prefix foo=${string#./}
select opt in "${options[@]#./}" "New"
do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        NEWIMAGE=$opt
        break

    elif (( REPLY > 1 && REPLY <= ${#options[@]} )) ; then
        # echo  "You picked $opt which is file $REPLY"
        echo
        break

    else
        echo "Invalid option. Try another one."
    fi
done    

if [ "$opt" = "New" ] ; then
    echo
    echo
    IMAGE_FILE=$NEWBKUPNAME
else
    IMAGE_FILE=$opt
    # rename IMAGE_FILE to NEWBCKUPNAME prior to syncing
    echo "The image file is renamed to indicate the latest date of the/update/sync.."
    echo "(${MOUNTPT}/${IMAGE_FILE} --> ${MOUNTPT}/${NEWBKUPNAME})"
   
    mv "${MOUNTPT}/${IMAGE_FILE}" "${MOUNTPT}/${NEWBKUPNAME}"
    IMAGE_FILE=$NEWBKUPNAME
fi


echo "executing --> $IMAGESCRIPT -s ${IMAGE_SIZE} -n ${MOUNTPT} -m /mnt/bkup -f ${IMAGE_FILE} -b ${BOOTMNT}"
$IMAGESCRIPT -s ${IMAGE_SIZE} -n ${MOUNTPT}  -m /mnt/bkup -f ${IMAGE_FILE} -b ${BOOTMNT}

# sync devices
sync;sync

echo
echo "    OK to remove USB drive ..."

umount $BOOTMNT

echo
echo "Completed."

