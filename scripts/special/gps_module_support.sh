#!/bin/bash

#install packages
apt install -y pps-tools gpsd gpsd-clients python3-gps chrony
# setup gps device:
if [ ! -f /etc/default/gpsd_original ] ; then
    # make backup of original file
    cp /etc/default/gpsd /etc/default/gpsd_original
fi

cat << _EOF >> /tmp/gpsd
# Devices gpsd should collect to at boot time.
# They need to be read/writeable, either by user gpsd or the group dialout.
 
# start the gpsd daemon automatically at boot time
START_DAEMON="true"

#Use USB hotplugging to add new USB devices automatically to the daemon
USBAUTO="true"

# Devices gpsd should collect to at boot time.
# They need to be read/writeable, either by user gpsd or the group dialout.
#DEVICES="/dev/ttyS0 /dev/pps0"
# DEVICES="/dev/ttyS0"
DEVICES="/dev/ttyGPS"

# Other options you want to pass to gpsd
GPSD_OPTIONS="-n -s 38400"
_EOF

# replace complete file
mv /tmp/gpsd /etc/default/gpsd

# setup udev rules
# add to /etc/udev/rules.d/99-ekos-serial.rules
if [ ! -f /etc/udev/rules.d/99-ekos-serial.rules ] ; then
    # make backup if not present and Append
    cp /etc/udev/rules.d/99-ekos-serial.rules /etc/udev/rules.d/99-ekos-serial.rules_original
fi
if ( ! grep 'SYMLINK+=\"ttyGPS\"' /etc/udev/rules.d/99-ekos-serial.rules ) ; then
    echo
    echo "Adding gps modules to udev.  This is very specific to your device and the file "
    echo "may need to be edited to reflect your current device."
    echo >> /etc/udev/rules.d/99-ekos-serial.rules
    echo "# Bus 001 Device 012: ID 1546:01a7 U-Blox AG [u-blox 7]" >> /etc/udev/rules.d/99-ekos-serial.rules
    echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"1546\", ATTRS{idProduct}==\"01a7\", SYMLINK+=\"ttyGPS\"" >> /etc/udev/rules.d/99-ekos-serial.rules
fi

# Add ref clock and NMEA to chrony.conf
if [ ! -f /etc/chrony/chrony.conf_original ] ; then
    # make a backup of the original
    cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf_original
fi

if ( ! grep 'refclock SHM' /etc/chrony/chrony.conf ) ; then
    echo
    echo "Adding 'refclock' to /etc/chrony/chrony.conf file..."

    echo >> /etc/chrony/chrony.conf
    echo "# 0.325 means the NMEA time sentence arrives 325 milliseconds after the PPS" >> /etc/chrony/chrony.conf
    echo "# pulse  the delay adjusts it forward" >> /etc/chrony/chrony.conf
    echo "refclock SHM 0 delay 0.325 refid NMEA" >> /etc/chrony/chrony.conf
fi

exit 0