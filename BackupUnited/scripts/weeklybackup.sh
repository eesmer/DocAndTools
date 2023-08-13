#!/bin/bash

#-----------------------------------------------------------
# $1 BACKUPNAME
#-----------------------------------------------------------

WDIR="/usr/local/backupunited/backups"

JOCKER=$
#tar -czf /usr/local/backupunited/backups/$1-"$JOCKER(date +%Y%m%d-%H%M).tar.gz" /usr/local/backupunited/backups/weekly/$1
mkdir -p /usr/local/backupunited/backups/weekly/
tar -czf /usr/local/backupunited/backups/weekly/$1-"$(date +%Y%m%d-%H%M).tar.gz" /usr/local/backupunited/backups/sync/$1
