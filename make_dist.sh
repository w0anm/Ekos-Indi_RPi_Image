#!/bin/bash

DIST=Ekos_Indi_Rpi4_v9.1

if [ ! -d ./dist/$DIST ] ; then
    mkdir -p ./dist/$DIST
fi

echo
echo "Creating script.tar file..."
tar cf scripts.tar scripts

echo
echo "Copying files to distribution directory..."
mv scripts.tar ./dist/$DIST/.
cp scripts/run_first.sh ./dist/$DIST/.
cp scripts.tar ./dist/$DIST/.
cp Ekos_Indi_SD_Install_Ubuntu_22.04.pdf ./dist/$DIST/.

echo
echo "Creating Distribution zip file..."
cd dist
zip -r ${DIST}_dist.zip $DIST

mv ${DIST}_dist.zip ..

echo "Done"

