#!/bin/bash
WDIR=/usr/local/backupunited

numrecipient=$(cat $WDIR/reports/mail-recipient | wc -l)
i=1
while [ "$i" -le $numrecipient ]; do
recipient=$(ls -l | sed -n $i{p} $WDIR/reports/mail-recipient)
cat $WDIR/reports/mail-message | mutt -s "Backup United Notification" $recipient
i=$(( i + 1 ))
done
