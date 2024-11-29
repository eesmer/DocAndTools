#!/bin/bash

# Is the user root?
if [[ $EUID -ne 0 ]]; then
    echo "Root privileges are required to run this script."
    exit 1
fi

# Install Samba Package
apt install -y samba

SHARE_DIR=$(whiptail --inputbox "Please specify the Sharing Directory Path" 10 50 --title "Share Directory Path" --backtitle "Share Directory Path" 3>&1 1>&2 2>&3)
SHARE_NAME=$(whiptail --inputbox "Please specify the Sharing Directory Name" 10 50 --title "Share Directory Name" --backtitle "Share Directory Name" 3>&1 1>&2 2>&3)

