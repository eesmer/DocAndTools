#!/bin/bash

WDIR=/usr/local/isogen

apt-get -y install wget

mkdir -p $WDIR
wget https://raw.githubusercontent.com/eesmer/DocAndTools/master/Debian-iso_Creator/create-iso.sh -O $WDIR/create-iso.sh -q
wget https://raw.githubusercontent.com/eesmer/DocAndTools/master/Debian-iso_Creator/preseed.cfg -O $WDIR/preseed.cfg -q
wget https://raw.githubusercontent.com/eesmer/DocAndTools/master/Debian-iso_Creator/menu.cfg -O $WDIR/menu.cfg -q
wget https://raw.githubusercontent.com/eesmer/DocAndTools/master/Debian-iso_Creator/splash.png -O $WDIR/splash.png -q

echo "iso-creator app installation completed.."
echo -e
echo "[ for usage ]"
echo "cd $WDIR"
echo "bash create-iso.sh ISOFILEPATH/ISOFILENAME.iso NEW_NAME-Custom.iso"
