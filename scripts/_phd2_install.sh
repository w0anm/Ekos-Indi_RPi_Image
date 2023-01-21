#!/bin/bash

# run as eko user
user=ekos
if [ ! "$(whoami)" = "$user" ]; then
   echo "This script must be run as $user" 
   exit 1
fi

echo
echo "This scripts builds the phd2 software from source.  For more"
echo "information, visit:"
echo "     https://github.com/OpenPHDGuiding/phd2"
echo
echo "You can build the PHD2 Guiding software now, or later."

while true 
do
    echo
    echo -n "Do you wish to build PHD2 Guiding software now [y,n]: " ; read answer

    case $answer in

      n)  ## do it later
            mv ~/_phd2_install.sh ~/bin/_phd2_install.sh
            echo
            echo "You can re-execute this script if you would like to install PHD2 at a later time."
            echo "Just enter _phd2_install.sh and the command line prompt."
            echo
            exit 0
            ;;
      y) ## do it now
           echo
           echo "Starting PHD2 build please wait until completed..."
           break
           ;;

      *)   echo "Error: enter 'y' or 'n' "
           ;;
     esac
done

# phd2 make and install

# setup build env
sudo apt-get install -y build-essential git cmake pkg-config \
	libwxgtk3.0-gtk3-dev wx-common wx3.0-i18n  \
	gettext zlib1g-dev libx11-dev libcurl4-gnutls-dev

# if phd2 directory is already present, then mv the old directory before
# cloning
if [ -d /home/ekos/phd2 ] ; then
    mv /home/ekos/phd2 /home/ekos/phd2_$(date '+%Y%m%d%M.%S')
fi

cd /home/ekos
git clone https://github.com/OpenPHDGuiding/phd2

mkdir -p phd2/tmp
cd phd2/tmp
cmake ..
make

sudo make install

# move file away so that it will not re-build
if [ -f ~/_phd2_install.sh ] ; then
    mv ~/_phd2_install.sh ~/bin/.
fi

echo
echo "Build and installation is completed..."
echo

# update /etc/motd with version information
PHD_VERS=$(grep "#define PHDVERSION" /home/ekos/phd2/phd.h | awk 'BEGIN {FS = "\""} ; {print $2}')
PHD_SUBVERS=$(grep "#define PHDSUBVER" /home/ekos/phd2/phd.h | awk 'BEGIN {FS = "\""} ; {print $2}')
PHDVERSION={PHD_VER}${PHD_SUBVER}

sudo sed -i "s/_PHDVERS_/phd2-version: $PHDVERSION/" /etc/motd

exit
