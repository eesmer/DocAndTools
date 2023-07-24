#/bin/bash

#------------------------------
# $1 = BACKUPNAME
#------------------------------

rdiff-backup /usr/local/backup-united/backups/sync/$1/ /usr/local/backup-united/backups/incremental/$1
