#!/bin/bash

WDIR=/usr/local/backup-united
BACKUP_SCRIPTS=$WDIR/backup-scripts
BACKUPS=$WDIR/backups
MAILRECIPIENT=$WDIR/mail-recipient
MAILMESSAGE=$WDIR/mail-message

NUMRECIPIENT=$(cat "$MAILRECIPIENT" | wc -l)
i=1
while [ "$i" -le $NUMRECIPIENT ]; do
        RECIPIENT=$(ls -l | sed -n $i{p} "$MAILRECIPIENT")
        cat $MAILMESSAGE | mutt -s "Backup United Notification" $RECIPIENT
        i=$(( i + 1 ))
done
