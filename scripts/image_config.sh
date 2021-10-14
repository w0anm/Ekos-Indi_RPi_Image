#!/bin/bash
#


# Script to enable/disable services for ekos/indi server

#Functions:
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


clear
echo
echo
while [ true ] ; do
    # menu for selection

    echo "Window Management Utility"
    echo
    echo "1 - Start/Stop X11vnc Service (with Window Manager)"
    echo "2 - Start/Stop Window Manager Greeter"
    echo "3 - Exit"
    echo
    echo -n "Enter selection: " ; read Answer


    # x11vnc Service
    case $Answer in
        1)  # start/stop xllvnc service
	    if (ps -ef | grep vnc  | grep -v grep 2> /dev/null) ; then
                echo  -n "Do you want to stop x11vnc service " ; ANS=$(ckyorn y)
                if [ "$ANS" = "y" ] ; then
                    sudo systemctl stop lightdm
                    sudo systemctl stop x11vnc
		    Start_x11vnc=N
                fi
            else
                echo -n "Do you want to start x11vnc service "; ANS=$(ckyorn y)
                if [ "$ANS" = "y" ] ; then
                    sudo systemctl start lightdm
                    sudo systemctl start x11vnc
		    Start_x11vnc=Y
                fi
            fi

            if [ -h /etc/systemd/system/multi-user.target.wants/x11vnc.service ] ; then
                echo -n "Do you want to disable x11vnc service on server boot "
		ANS=$(ckyorn y)
                if [ "$ANS" = "y" ] ; then
                    sudo systemctl disable x11vnc
                fi
            else
                echo -n  "Do you want to enable x11vnc service on server boot "; ANS=$(ckyorn y)
                if [ "$ANS" = "y" ] ; then
                    sudo systemctl enable x11vnc
		fi
            fi
	    ;;

        2)  # start/stop window greeter lightdm  service
	     if (ps -ef | grep lightdm  | grep -v grep 2> /dev/null) ; then
                echo  -n "Do you want to stop lightdm service " ; ANS=$(ckyorn y)
                if [ "$ANS" = "y" ] ; then
                    sudo systemctl stop x11vnc
                    sudo systemctl stop lightdm
		    Start_lightdm=N
                fi
            else
                echo -n "Do you want to start lightdm service "; ANS=$(ckyorn y)
                if [ "$ANS" = "y" ] ; then
                    sudo systemctl start lightdm
		    Start_lightdm=Y
                fi
            fi

            if [ "$Start_lightdm" = "Y" ] ; then
                echo -n "Do you want to enable lightdm service at boot "; ANS=$(ckyorn y)
                    if [ "$ANS" = "y" ] ; then
	                sudo dpkg-reconfigure lightdm
		        sudo /lib/systemd/systemd-sysv-install enable lightdm
	            ##else
	            ##    sudo systemctl disable lightdm
		    ##    sudo /lib/systemd/systemd-sysv-install disable lightdm
		    fi
	    else
	      echo -n "Do you want to disable lightdm service at boot "; ANS=$(ckyorn y)
                    if [ "$ANS" = "y" ] ; then
	                sudo systemctl disable lightdm
		        sudo /lib/systemd/systemd-sysv-install disable lightdm
		    fi
            fi
	    ;;
        3) 
            break;
	    ;;
    esac

echo "Done"

done

# Window Manager Greeter

## sudo systemctl disable lightdm
## sudo systemctl stop lightdm

# root@ekos-server:/usr/local/bin# systemctl disable lightdm
# Synchronizing state of lightdm.service with SysV service script with /lib/systemd/systemd-sysv-install.
# Executing: /lib/systemd/systemd-sysv-install disable lightdm
# Removed /etc/systemd/system/display-manager.service.

