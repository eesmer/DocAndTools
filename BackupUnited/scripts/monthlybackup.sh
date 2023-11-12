#!/bin/bash

#-----------------------------------------------------------
# $1 BACKUPNAME
#-----------------------------------------------------------

WDIR="/usr/local/backupunited/backups"

JOCKER=$
mkdir -p $WDIR/monthly
tar -czf $WDIR/monthly/$1-"$(date +%Y%m%d-%H%M).tar.gz" $WDIR/sync/$1
