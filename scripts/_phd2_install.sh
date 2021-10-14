#!/bin/bash

# run as eko user
# phd2 make and install

# setup build env
sudo apt-get install -y build-essential git cmake pkg-config \
	libwxgtk3.0-gtk3-dev wx-common wx3.0-i18n  \
	gettext zlib1g-dev libx11-dev libcurl4-gnutls-dev


cd /home/ekos
git clone https://github.com/OpenPHDGuiding/phd2

mkdir -p phd2/tmp
cd phd2/tmp
cmake ..
make

sudo make install

# move file away so that it will not re-build
mv ~/_phd2_install.sh ~/bin/.


