#!/bin/bash

apt-get -y install rsync ssmtp mutt
apt-get -y install cifst-utils smbclient
apt-get -y install tree

mkdir -p /usr/local/backup-united
mkdir /usr/local/backup-united/backup-scripts
mkdir /usr/local/backup-united/backups
cat > /usr/local/backup-united/mail-message <<EOF
-------------------------------------------
| Backup-United Mail Notification         |
-------------------------------------------

EOF
