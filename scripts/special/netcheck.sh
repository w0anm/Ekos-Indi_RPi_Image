#!/bin/bash

# Max downtime in seconds.
# If we exceed this, we will start our internal hotspot.
max_downtime=360

# First touch a file in /run/ with our current status.
touch "/run/NetCheck.$(nmcli networking connectivity check)"

# The rest is somewhat hacky.  :)
# We will look at the most recent two /run/NetCheck.* files.
# If the most recent is "none", we will compare the status time to the previous status.

declare -a net_status net_status_time

index=0
while read filetime filename
do

  net_status[$index]=${filename#*.}
  net_status_time[$index]=${filetime%.*}
  (( index++ ))

done < <(find /run -maxdepth 1 -type f -name "NetCheck.*" -printf "%T@ %f\n" | sort -rn | head -n 2)

if [ "${net_status[0]}" = "none" ] && [ -n "${net_status[1]}" ]
then # We are currently down.

  downtime=$((net_status_time[0] - net_status_time[1]))

  if [ $downtime -ge $max_downtime ]
  then # We have been down for more than $max_downtime seconds.

    # Start our hotspot... 
    nmcli connection up id "Astroberry HotSpot Internal"

  fi

fi
