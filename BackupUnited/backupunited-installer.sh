#!/bin/bash

apt-get -y install git
apt-get -y install rsync rdiff-backup ssmtp mutt
apt-get -y install cifs-utils smbclient
apt-get -y install tree ack

mv /usr/local/backupunited /usr/local/backupunited.old
cd /tmp
git clone https://github.com/eesmer/DocAndTools.git
mv /tmp/DocAndTools/BackupUnited /usr/local/backupunited/
rm -r /tmp/DocAndTools/
cp /usr/local/backupunited/backupunited.sh /usr/sbin/backupunited
chmod +x /usr/sbin/backupunited
# delete readme file
rm /usr/local/backupunited/backups/*
rm /usr/local/backupunited/backup-scripts/*

mv /usr/local/backupunited.old/backups /usr/local/backupunited/ && \
	rm -rf /usr/local/backupunited.old
echo -e

echo -e
echo "::::::::::::::::::::::::::::::::::::"
echo "Backup United Installation completed"
echo "::::::::::::::::::::::::::::::::::::"
echo -e
