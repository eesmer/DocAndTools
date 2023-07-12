#!/bin/bash

if [ -x "$(command -v rsync)" ] || [ -x "$(command -v ssmtp)" ] || [ -x "$(command -v mutt)" ] || \
    [ -x "$(command -v cifs-utils)" ] || [ -x "$(command -v smbclient)" ] || [ -x "$(command -v tree)" ]; then

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
fi
