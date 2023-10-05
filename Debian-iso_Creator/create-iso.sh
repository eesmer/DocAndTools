#!/bin/bash

#-------------------------------------------------------------
# $1 = Source Debian .iso
# $2 = Custom-iso Name
# Usage:
# # bash create-iso.sh debian-11.7.0-amd64-netinst.iso Custom.iso
#-------------------------------------------------------------
# Debian adds preseed.cfg to the .iso file.
# Replaces the menu.cfg file.
# Adds the splash.png file.
# Creates an .iso file named $2.
# create-iso.sh, preseed.cfg, menu.cfg, splash.png must be in the same directory.
# script must be run with root user.
#------------------------------------------------- ------------
# The splash.png file must be 640x480. Otherwise, the graphic will not be displayed in the install menu.
# preseed.cfg syntax must be correct. Otherwise, preseed.cfg cannot be used in the installation.
#-------------------------------------------------------------

WORKDIR=/usr/local/isogen
CURRENTDIR=$(pwd)

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Option required. Example:bash create-iso Debian.iso Name_of_custom_iso.iso"
    exit 1
fi

# -----------------------------------------------------------------------------
# INSTALL PACKAGES
# -----------------------------------------------------------------------------
apt-get -y install bsdtar xorriso isolinux cpio

mkdir -p $WORKDIR/iso
cp preseed.cfg $WORKDIR/
cp menu.cfg $WORKDIR/
cp splash.png $WORKDIR/
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

mv $2 $CURRENTDIR
rm -r $WORKDIR
