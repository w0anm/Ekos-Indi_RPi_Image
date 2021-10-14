#!/bin/bash
#

# Special Script to install my special files outside of distribution


echo "Installing Special Files in /home/ekos/bin/"

# install the dew controller files in ekos/bin
install -o ekos -g ekos -m 755 bin/DewConfig /home/ekos/bin/DewConfig
install -o ekos -g ekos -m 755 bin/DewStatus /home/ekos/bin/Status
install -o ekos -g ekos -m 755 bin/check_status /home/ekos/bin/check_status
install -o ekos -g ekos -m 755 bin/update_indi.sh /home/ekos/bin/update_indi.sh


exit 
