#!/bin/bash

DIST=Ekos_Indi_Rpi4_v10.2_u22

# update /etc/motd with the latest distribution version number.
sed -i "s/_DISTVERS_/Ekos\/Indi Image Version: $DIST by Christopher Kovacs/" scripts/motd

# clean up
if [ -d ./dist/$DIST ] ; then
    rm -rf ./dist/$DIST 
fi

mkdir -p ./dist/$DIST

# make the scripts tar file
echo
echo "Creating script.tar file..."
tar cf scripts.tar scripts

echo
echo "Copying files to distribution directory..."
cp scripts/run_first.sh ./dist/$DIST/.
cp scripts.tar ./dist/$DIST/.
cp Ekos_Indi_SD_Install_Ubuntu_22.04.pdf ./dist/$DIST/.

echo
echo "Creating Distribution zip file..."
cd dist
zip -r ${DIST}_dist.zip $DIST

mv ${DIST}_dist.zip ..

# cleanup
cd ..

rm -f scripts.tar 

echo "Done"

