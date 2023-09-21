#!/bin/bash

#-----------------------------------------------------------
# $1 BACKUPNAME
#-----------------------------------------------------------

WDIR="/usr/local/backupunited/backups"

JOCKER=$
mkdir -p /usr/local/backupunited/backups/monthly/
tar -czf /usr/local/backupunited/backups/monthly/$1-"$(date +%Y%m%d-%H%M).tar.gz" /usr/local/backupunited/backups/sync/$1
