#!/bin/bash
#
# Image Backup Script image-backup
#
# image-backup version -  w0anm
#    for use with sys_imagebkup
#  $Id: image-backup.sh 14 2015-03-20 04:06:49Z w0anm $

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

usage ()
{
  # current usage is called by image_backup.sh or image_nfs_backup.sh
  #  This is in interactive mode.  Can be used to call from cron
  echo "  Usage: $0 [-i] [-u] -s <size> <image_file_name> "
  echo "   image file name"
  echo
  echo "  Where:"
  echo "     -i - interactive flag"
  echo "     -u - update existing image file"
  echo "     -s - size of linux partition"
  echo "  <image_file_name> Name of image file"
}

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
  echo "Minimum recommended root partition size:        ${MIN_REQ_IMAGE_SIZE} MB"
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
CHKMOUNT="$(grep $BOOT_DISK_DEV /proc/mounts)"

# if already mounted, skip
if [ -z "${CHKMOUNT}" ] ; then
    mount $BOOT_DISK_DEV $BOOTMNT
    echo "$BOOTMNT is mounted..."
    BOOTMNTFLAG=y
else
    echo "$BOOTMNT is already mounted..."
fi

# Mount NFS Filesystem
#   Future, combine with physical mount
#    usb device

clear

# nfs server name
echo -n " Enter NFS Server Name [${NFS_SERVER_NAME}] :"
read ANS
if [ ! -z "$ANS" ] ; then
   NFS_SERVER_NAME=$ANS
fi

# nfs server mountpoint
echo -n " Enter NFS Server Mount Point [${NFS_SERVER_MOUNTPT}] :"
read ANS
if [ ! -z "$ANS" ] ; then
   NFS_SERVER_MOUNTPT=$ANS
fi

# local mount point
echo -n " Enter Local Mount Point [${LOCAL_MOUNTPT}] :"
read ANS
if [ ! -z "$ANS" ] ; then
   LOCAL_MOUNTPT=$ANS
fi

# check to see if nfs mount point is created.
if [ ! -d $LOCAL_MOUNTPT ] ; then
    mkdir -p $LOCAL_MOUNTPT
fi


# define the nfs servera and mouhnt
NFS_SERVER_MOUNT=${NFS_SERVER_NAME}:${NFS_SERVER_MOUNTPT}

mount  $NFS_SERVER_MOUNT $LOCAL_MOUNTPT
if [ "$?" != 0 ] ; then
    echo "Abort.. unable to mount NFS share."
    exit 1
fi

# display Size available
AVAILSTORAGE=$(df --output=avail -h  "$LOCAL_MOUNTPT" |tail -n 1)


# Select a file or provide a new file name.
cat << _EOF

+=========================================================================+
| Select an existing backup image file to update by entering the number   |
| next to the file.                                                       |
|                 -OR-                                                    |
| Select the number corresponding to "New" to create a new backup image.  |
|                                                                         |
| Available space on $LOCAL_MOUNTPT is $AVAILSTORAGE                      |
+=========================================================================+
_EOF

# enter directory where the backup files are stored.
cd "$LOCAL_MOUNTPT"

###################################################


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
    echo "(${LOCAL_MOUNTPT}/${IMAGE_FILE} --> ${LOCAL_MOUNTPT}/${NEWBKUPNAME})"

    mv "${LOCAL_MOUNTPT}/${IMAGE_FILE}" "${LOCAL_MOUNTPT}/${NEWBKUPNAME}"
    IMAGE_FILE=$NEWBKUPNAME
fi

echo "$IMAGESCRIPT -s ${IMAGE_SIZE} -n ${LOCAL_MOUNTPT} -m /mnt/bkup -f ${IMAGE_FILE} -b ${BOOTMNT}"
$IMAGESCRIPT -s ${IMAGE_SIZE} -n ${LOCAL_MOUNTPT} -m /mnt/bkup -f ${IMAGE_FILE} -b ${BOOTMNT}

# sync devices
sync;sync

cd /
sleep 5
echo "Unmounting NFS share..."

if [ -z BOOTMNTFLAG ] ; then
    umount $BOOTMNT
fi

umount $LOCAL_MOUNTPT

echo
echo "Completed."

