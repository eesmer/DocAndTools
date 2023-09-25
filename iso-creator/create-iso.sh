#!/bin/bash

#-------------------------------------------------------------
# ISOGen
# $1 = Source Debian .iso
# $2 = preseed.cfg file
# $3 = menu.cfg file
# $4 = Custom-iso Name
# $5 = splash.png file
# $1 parameter is must. Other parameters is optional
# example:
# bash create-iso.sh debian-11.7.0-amd64-netinst.iso preseed.cfg menu.cfg DebianDC.iso
#-------------------------------------------------------------

WORKDIR=/usr/local/isogen

if [ -z "${$1}" ]; then
	echo "Option required. Example:bash create-iso Debian.iso preseed.cfg menu.cfg"
	exit 1
fi

# -----------------------------------------------------------------------------
# INSTALL PACKAGES
# -----------------------------------------------------------------------------
apt-get -y install bsdtar xorriso isolinux cpio

if [[ ! -f "$1" ]]; then
	echo "the source ISO file is missing"
	exit 1
fi

#if [ -d "$WORKDIR" ]; then
#	rm -rf $WORKDIR
#	mkdir -p $WORKDIR/iso
#fi
#cp {$1,$2,$3} $WORKDIR/

mkdir -p $WORKDIR/iso
bsdtar -C $WORKDIR/iso -xf $1

# Set preseed.cfg
mkdir $WORKDIR/initrd
cd $WORKDIR/initrd
gzip -d < $WORKDIR/iso/install.amd/initrd.gz | cpio --extract --verbose --make-directories --no-absolute-filenames
cp $WORKDIR/preseed.cfg $WORKDIR/initrd/
find . | cpio -H newc --create --verbose | gzip -9 > $WORKDIR/iso/install.amd/initrd.gz

cp $WORKDIR/menu.cfg $WORKDIR/iso/isolinux/
cp $WORKDIR/splash.png $WORKDIR/iso/isolinux/

# Create custom iso
cd $WORKDIR
xorriso -as mkisofs -o $4 \
	-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
	-c isolinux/boot.cat -b isolinux/isolinux.bin \
	-no-emul-boot -boot-load-size 4 -boot-info-table $WORKDIR/iso
