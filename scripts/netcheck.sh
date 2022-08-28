#!/bin/bash

# netcheck.sh

# This script checks for connectivity every 6 seconds, until 60 seconds.
# This uses a sime nmcli check for network status and if a connection is 
# made prior to the timeout, the hotstop will not be started.
#
# This is called from rc.local script

TimeOut=0

# check if timeout as not expired
until [ $TimeOut -gt 10 ]   
do

    # check network status
    NetStatus=$(nmcli networking connectivity check)
    if [ "$NetStatus" = "none" ] ; then
        sleep 6
    else
        echo "Network Connected..."
        exit 0
    fi
    ((TimeOut=TimeOut+1))

done

# if nothing, and timed out, then start hotspot.
/usr/local/bin/start_hotspot.sh

exit 0

