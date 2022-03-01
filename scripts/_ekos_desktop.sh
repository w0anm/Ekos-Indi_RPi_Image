#!/bin/bash

cd /home
tar zxf /root/scripts/ekos_desktop.tgz
if [ "$?" != "0" ] ; then
    echo "Error in extracting ekos desktop files..."
    echo
fi

