#!/bin/bash

#-----------------------------------------------------------
# $1 BACKUPNAME
#-----------------------------------------------------------

WDIR="/usr/local/backupunited/backups"

JOCKER=$
mkdir -p $WDIR/weekly
tar -czf $WDIR/weekly/$1-"$(date +%Y%m%d-%H%M).tar.gz" $WDIR/sync/$1
