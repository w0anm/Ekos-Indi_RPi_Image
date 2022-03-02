#!/bin/bash

# This script will download to a directory all of the index fits files for astrometry.
# 
# This can be used as an alternative to downloading from the kstars/ekos application
# This requries at least 34Gb of storage.

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


#

echo "This script will download all of the index fits files for astromety."
echo "You must have at least 34Gb of storage available."
echo
echo "This script is be executed from directory where the files will be"
echo "saved, such as /astrometry. For example:"
echo
echo "    cd /astrometry"
echo "    get_astrometry_index.sh "
echo
echo "Remember, you may have to change owner/directory permissions of the"
echo "installation directory for the files to be downloaded, or you will"
echo "get a permission denied when downloading."
echo
echo -n "Do you want to Continue? "; ANS=$(ckyorn n)

if [ "$ANS" = "n" ] ; then
    echo "Exiting Script..."
    echo
    exit 
fi

# Astrometric URL Site
URL="http://broiler.astrometry.net/~dstn/4200"
INDEX_FILES="
index-4219.fits index-4218.fits index-4217.fits index-4216.fits index-4215.fits index-4214.fits \
index-4213.fits index-4212.fits index-4211.fits index-4210.fits index-4209.fits index-4208.fits \
index-4207-11.fits index-4207-10.fits index-4207-09.fits index-4207-08.fits index-4207-07.fits \
index-4207-06.fits index-4207-05.fits index-4207-04.fits index-4207-03.fits index-4207-02.fits \
index-4207-01.fits index-4207-00.fits index-4206-11.fits index-4206-10.fits index-4206-09.fits \
index-4206-08.fits index-4206-07.fits index-4206-06.fits index-4206-05.fits index-4206-04.fits \
index-4206-03.fits index-4206-02.fits index-4206-01.fits index-4206-00.fits index-4205-11.fits \
index-4205-10.fits index-4205-09.fits index-4205-08.fits index-4205-07.fits index-4205-06.fits \
index-4205-05.fits index-4205-04.fits index-4205-03.fits index-4205-02.fits index-4205-01.fits \
index-4205-00.fits index-4204-47.fits index-4204-46.fits index-4204-45.fits index-4204-44.fits \
index-4204-43.fits index-4204-42.fits index-4204-41.fits index-4204-40.fits index-4204-39.fits \
index-4204-38.fits index-4204-37.fits index-4204-36.fits index-4204-35.fits index-4204-34.fits \
index-4204-33.fits index-4204-32.fits index-4204-31.fits index-4204-30.fits index-4204-29.fits \
index-4204-28.fits index-4204-27.fits index-4204-26.fits index-4204-25.fits index-4204-24.fits \
index-4204-23.fits index-4204-22.fits index-4204-21.fits index-4204-20.fits index-4204-19.fits \
index-4204-18.fits index-4204-17.fits index-4204-16.fits index-4204-15.fits index-4204-14.fits \
index-4204-13.fits index-4204-12.fits index-4204-11.fits index-4204-10.fits index-4204-09.fits \
index-4204-08.fits index-4204-07.fits index-4204-06.fits index-4204-05.fits index-4204-04.fits \
index-4204-03.fits index-4204-02.fits index-4204-01.fits index-4204-00.fits index-4203-47.fits \
index-4203-46.fits index-4203-45.fits index-4203-44.fits index-4203-43.fits index-4203-42.fits \
index-4203-41.fits index-4203-40.fits index-4203-39.fits index-4203-38.fits index-4203-37.fits \
index-4203-36.fits index-4203-35.fits index-4203-34.fits index-4203-33.fits index-4203-32.fits \
index-4203-31.fits index-4203-30.fits index-4203-29.fits index-4203-28.fits index-4203-27.fits \
index-4203-26.fits index-4203-25.fits index-4203-24.fits index-4203-23.fits index-4203-22.fits \
index-4203-21.fits index-4203-20.fits index-4203-19.fits index-4203-18.fits index-4203-17.fits \
index-4203-16.fits index-4203-15.fits index-4203-14.fits index-4203-13.fits index-4203-12.fits \
index-4203-11.fits index-4203-10.fits index-4203-09.fits index-4203-08.fits index-4203-07.fits \
index-4203-06.fits index-4203-05.fits index-4203-04.fits index-4203-03.fits index-4203-02.fits \
index-4203-01.fits index-4203-00.fits index-4202-47.fits index-4202-46.fits index-4202-45.fits \
index-4202-44.fits index-4202-43.fits index-4202-42.fits index-4202-41.fits index-4202-40.fits \
index-4202-39.fits index-4202-38.fits index-4202-37.fits index-4202-36.fits index-4202-35.fits \
index-4202-34.fits index-4202-33.fits index-4202-32.fits index-4202-31.fits index-4202-30.fits \
index-4202-29.fits index-4202-28.fits index-4202-27.fits index-4202-26.fits index-4202-25.fits \
index-4202-24.fits index-4202-23.fits index-4202-22.fits index-4202-21.fits index-4202-20.fits \
index-4202-19.fits index-4202-18.fits index-4202-17.fits index-4202-16.fits index-4202-15.fits \
index-4202-14.fits index-4202-13.fits index-4202-12.fits index-4202-11.fits index-4202-10.fits \
index-4202-09.fits index-4202-08.fits index-4202-07.fits index-4202-06.fits index-4202-05.fits \
index-4202-04.fits index-4202-03.fits index-4202-02.fits index-4202-01.fits index-4202-00.fits"

for FILE in $INDEX_FILES
do
    echo "Downloading $FILE.."
    wget --continue --quiet $URL/$FILE
    echo
done
    

echo
echo "Downloading is now completed..."

exit
