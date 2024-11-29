#!/bin/bash

# Is the user root?
if [[ $EUID -ne 0 ]]; then
    echo "Root privileges are required to run this script."
    exit 1
fi

# Install Samba Package
apt install -y samba
