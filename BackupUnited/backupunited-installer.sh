#!/bin/bash

apt-get -y install git
apt-get -y install rsync rdiff-backup ssmtp mutt
apt-get -y install cifs-utils smbclient
apt-get -y install tree ack

cd /tmp
git clone https://github.com/eesmer/DocAndTools.git
mv /tmp/DocAndTools/BackupUnited /usr/local/backupunited
rm -r /tmp/DocAndTools/
cp /usr/local/backupunited/backupunited.sh /usr/sbin/backupunited
chmod +x /usr/sbin/backupunited
# delete readme file
rm /usr/local/backupunited/backups/*
rm /usr/local/backupunited/backup-scripts/*
echo -e

echo -e
echo "::::::::::::::::::::::::::::::::::::"
echo "Backup United Installation completed"
echo "::::::::::::::::::::::::::::::::::::"
echo -e
