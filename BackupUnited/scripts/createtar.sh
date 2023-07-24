#!/bin/bash

#------------------------------
# $1 = BACKUPNAME
#------------------------------

mkdir -p /usr/local/backup-united/backups/createtar/$1
tar -cf /usr/local/backup-united/backups/createtar/$1/$1-"$(date +%Y%m%d-%H%M).tar.gz" /usr/local/backup-united/backups/sync/$1
