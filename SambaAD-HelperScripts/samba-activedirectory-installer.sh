#!/bin/bash

#-------------------------------------------------------------------
# This script has been tested in Debian environment.
# It is compatible with Debian.
#-------------------------------------------------------------------

# Color Codes
MAGENTA="tput setaf 1"
GREEN="tput setaf 2"
YELLOW="tput setaf 3"
DGREEN="tput setaf 4"
CYAN="tput setaf 6"
WHITE="tput setaf 7"
GRAY="tput setaf 8"
RED="tput setaf 9"
BLUE="tput setaf 12"
NOCOL="tput sgr0"
BOLD="tput bold"

whiptail --msgbox \
        ".:: Samba Active Directory Domain Controller Installer ::. \
        \n---------------------------------------------------------------- \
        \nThis program is distributed for the purpose of being useful. \
        \nThis program installs Samba Active Directory. \
        \nIt will ask you questions about the domain and it will install and will install it according to the information it receives. \
        \n\nWhen the installation is completed;\na Domain is created and this machine is configured as a Domain Controller. \
        \n---------------------------------------------------------------- \
        \n\nhttps://github.com/eesmer/SambaAD-HelperScripts \
        \nhttps://github.com/eesmer/sambadtui \
        \nhttps://github.com/eesmer/DebianDC" 20 90 45

CHECK_DISTRO() {
cat /etc/*-release /etc/issue > "/tmp/distrocheck"
if grep -qi "debian\|ubuntu" "/tmp/distrocheck"; then
REP=APT
elif grep -qi "centos\|rocky\|red hat" "/tmp/distrocheck"; then
REP=YUM
fi
rm /tmp/distrocheck
# Not support message
if [ ! "$REP" = "APT" ]; then
$RED
echo -e
echo "-------------------------------------------------------------------------------------"
echo -e "This script has been tested in Debian environment.\nIt is compatible with Debian. "
echo "-------------------------------------------------------------------------------------"
echo -e
$NOCOL
exit 1
fi
}

SAMBAAD_INSTALL() {
        HOSTNAME=$(whiptail --inputbox "Enter DC Machine Hostname" 8 39 --title "DC Hostname" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ ! $exitstatus = 0 ]; then
                echo "User canceled input."
        fi
        REALM=$(whiptail --inputbox "Enter Domain Name" 8 39 --title "DomainName" 3>&1 1>&2 2>&3)
        PASSWORD=$(whiptail --passwordbox "Enter Administrator Password" 8 39 3>&1 1>&2 2>&3)

        echo $HOSTNAME
        echo $REALM
        echo $PASSWORD
}
