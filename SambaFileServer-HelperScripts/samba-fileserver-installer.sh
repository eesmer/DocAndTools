#!/bin/bash

#-------------------------------------------------------------------
# This script,
# Installs the Samba package
# Defines a new share
# Creates a User Account with access permission to the share
# Runs in a Debian environment
#-------------------------------------------------------------------

SMB_CONFIG="/etc/samba/smb.conf"

# Is the user root?
if [[ $EUID -ne 0 ]]; then
    echo "Root privileges are required to run this script."
    exit 1
fi

# Install Samba Package
apt install -y whiptail
apt install -y samba
apt install vim tmux htop

SHARE_DIR=$(whiptail --inputbox "Please specify the Sharing Directory Path" 10 50 --title "Share Directory Path" --backtitle "Share Directory Path" 3>&1 1>&2 2>&3)
SHARE_NAME=$(whiptail --inputbox "Please specify the Sharing Directory Name" 10 50 --title "Share Directory Name" --backtitle "Share Directory Name" 3>&1 1>&2 2>&3)
SMB_USER=$(whiptail --inputbox "Please Enter Account Name for Samba User Account" 10 50 --title "Samba User Account Name" --backtitle "Samba User Account Name" 3>&1 1>&2 2>&3)
SMB_PASS=$(whiptail --passwordbox "Please Enter Password to be Defined to Samba User Account" 10 50 --title "Samba User Account Password" --backtitle "Samba User Account Password" 3>&1 1>&2 2>&3)

# Create Samba User Account
useradd -M -s /sbin/nologin "$SMB_USER"
(echo "$SMB_PASS"; echo "$SMB_PASS") | smbpasswd -a "$SMB_USER"
smbpasswd -e "$SMB_USER"

# Create Sharing Directory
mkdir -p "$SHARE_DIR"
chmod -R 0775 "$SHARE_DIR"
chown -R $SMB_USER:$SMB_USER "$SHARE_DIR"

# Generate Samba Configuration
cat > "$SMB_CONFIG" <<EOF

[$SHARE_NAME]
   path = $SHARE_DIR
   browseable = yes
   writable = yes
   guest ok = no
   valid users = $SMB_USER
EOF

# Config Test and Service Restart/Reload
testparm
sleep 1
systemctl restart smbd nmbd

# Show Result
echo "Share Name: $SHARE_NAME"
echo "Share Directory: $SHARE_DIR"
echo "User: $SMB_USER"
echo "Password: $SMB_PASS"

exit 0
