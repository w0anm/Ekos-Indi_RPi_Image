#!/bin/bash

DIST=Ekos_Indi_Rpi4_v9

if [ ! -d ./dist/$DIST ] ; then
    mkdir -p ./dist/$DIST
fi

echo
echo "Creating script.tar file..."
tar script.tar script

echo
echo "Copying files to distribution directory..."
mv script.tar ./dist/$DIST/.
cp script/run_first.sh ./dist/$DIST/.
cp Ekos_Indi_SD_Install.pdf ./dist/$DIST/.

echo
echo "Creating Distribution zip file..."
cd dist
zip -r ${DIST}_dist.zip $DIST

mv ${DIST}_dist.zip ..

echo "Done"

