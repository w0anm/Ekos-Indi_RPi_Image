#!/bin/bash

# installation based upon Makfile
# this needs to be improved as this should be able to run multiple times
# without issues.  Need to add file checks. and package checks.

#sky chart install
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys
sudo sh -c "echo 'deb http://www.ap-i.net/apt unstable main' > /etc/apt/sources.list.d/skychart.list"
sudo apt update
sudo apt -y install skychart

#install ccdciel
sudo apt -y install ccdciel


##wget https://sourceforge.net/projects/astap-program/files/linux_installer/astap_armhf.deb
sudo dpkg -i astap_arm64.deb

##wget https://sourceforge.net/projects/astap-program/files/star_databases/g17_star_database_mag17_astap.deb
sudo dpkg -i h17_star_database_mag17_astap.deb

# libraries needed
# part of ~/source directory
mkdir -p ~/source
cd ~/source
git clone https://github.com/LibRaw/LibRaw.git

# LibRaw
cd LibRaw 
autoreconf --install 
./configure 
make

#libpasraw.git
cd ~/source 
git clone https://github.com/pchev/libpasraw.git

cd libpasraw/raw
make -f Makefile.dev

# copy library
cp libpasraw.so.1.1 ~/source/LibRaw/lib/.libs

# create links
cd ~/source/LibRaw/lib/.libs
ln -s libpasraw.so.1.1 libpasraw.so.1
ln -s libpasraw.so.1.1 libpasraw.so



# setup command start:
echo "export LD_LIBRARY_PATH=~/source/LibRaw/lib/.libs" > ~/bin/ccdciel_start
echo "ccdciel" >> ~/bin/ccdciel_start
chmod 755 ~/bin/ccdciel_start

sudo /bin/ccdciel /bin/ccdciel
cp /home/ekos/bin/ccdciel_start /usr/bin/ccdciel



echo "Installation Completed..."

