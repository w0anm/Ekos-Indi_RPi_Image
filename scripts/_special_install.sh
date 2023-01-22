#!/bin/bash
#

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

# Special Script to install my special files outside of distribution



echo "Installing Special Files in /home/ekos/bin/"
echo -n "Do you want to install the Dew System Software? "; ANS=$(ckyorn y)
if [ "$ANS" = "y" ] ; then
install -o ekos -g ekos -m 755 special/DewConfig /home/ekos/bin/DewConfig
install -o ekos -g ekos -m 755 special/DewStatus /home/ekos/bin/Status
fi

echo
echo "Do you want to install the udev rules for serial devices?"; ANS=$(ckyorn y)
if [ "$ANS" = "y" ] ; then
install -o root -g root -m 644 special/99-ekos-serial.rules /etc/udev/rules.d/99-ekos-serial.rules
fi

echo
echo -n "Do you want to install GPS Dongle Support?"; ANS=$(ckyorn y)

if [ "$ANS" = "y" ] ; then
    # check for dependencies, nees serial rules, this will be added even though you selected no from
    # above.
    if [ ! -f /etc/udev/rules.d/99-ekos-serial.rules ] ; then
        install -o root -g root -m 644 special/99-ekos-serial.rules /etc/udev/rules.d/99-ekos-serial.rules
    fi
    # execute script to add support
    bash special/gps_module_support.sh
fi

# misc other files
install -o ekos -g ekos -m 755 -d /home/ekos/bin
install -o ekos -g ekos -m 755 ekos_job_schedule.sh /home/ekos/bin/ekos_job_schedule.sh

exit 
