#!/bin/bash

#-------------------------------------------------------------
# ISOGen
# $1 = Source Debian .iso
# $2 = Custom-iso Name
# example:
# bash create-iso.sh debian-11.7.0-amd64-netinst.iso Custom.iso
#-------------------------------------------------------------

WORKDIR=/usr/local/isogen

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Option required. Example:bash create-iso Debian.iso Name_of_custom_iso.iso"
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

# Set preseed.cfg, menu.cfg and splash.png
mkdir $WORKDIR/initrd
cd $WORKDIR/initrd
gzip -d < $WORKDIR/iso/install.amd/initrd.gz | cpio --extract --verbose --make-directories --no-absolute-filenames
cp $WORKDIR/preseed.cfg $WORKDIR/initrd/
find . | cpio -H newc --create --verbose | gzip -9 > $WORKDIR/iso/install.amd/initrd.gz

cp $WORKDIR/menu.cfg $WORKDIR/iso/isolinux/
cp $WORKDIR/splash.png $WORKDIR/iso/isolinux/

# Create custom iso
cd $WORKDIR
xorriso -as mkisofs -o $2 \
	-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
	-c isolinux/boot.cat -b isolinux/isolinux.bin \
	-no-emul-boot -boot-load-size 4 -boot-info-table $WORKDIR/iso
