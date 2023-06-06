#!/bin/bash

apt -y install rdiff-backup ssmtp mutt

mkdir -p /usr/local/backup-united/backup
mkdir /usr/local/backup-united/backup-scripts
mkdir /usr/local/backup-united/notification

wget https://raw.githubusercontent.com/eesmer/backup-united/master/files/backup-united -O /usr/local/backup-united/backup-united
wget https://raw.githubusercontent.com/eesmer/backup-united/master/files/mail-message -O /usr/local/backup-united/notification/mail-message
wget https://raw.githubusercontent.com/eesmer/backup-united/master/files/mail-recipients -O /usr/local/backup-united/notification/mail-recipients
wget https://raw.githubusercontent.com/eesmer/backup-united/master/files/mail-sender -O /usr/local/backup-united/notification/99-mail-sender

chmod +x /usr/local/backup-united/backup-united
ln -s /usr/local/backup-united/backup-united /bin/

echo "       backup-united is installed
>           *********************************************
>            For use in terminal command -> backup-united                                                                                
>           *********************************************"
sleep 2
