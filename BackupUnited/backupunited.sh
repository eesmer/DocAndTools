#!/bin/bash

WDIR=/usr/local/backup-united
BACKUP_SCRIPTS=$WDIR/backup-scripts
BACKUPS=$WDIR/backups
MAILRECIPIENT=$WDIR/mail-recipient
MAILMESSAGE=$WDIR/mail-message
MAILSENDER=$WDIR/mail-sender.sh

clear

#-----------------------------------------------
# check & install required packages
#-----------------------------------------------
if ! [ -x "$(command -v rsync)" ] \
	|| ! [ -x "$(command -v rdiff-backup)" ] \
	|| ! [ -x "$(command -v ssmtp)" ] \
	|| ! [ -x "$(command -v mutt)" ] \
	|| ! [ -x "$(command -v smbclient)" ] \
	|| ! [ -x "$(command -v tree)" ] \
	|| ! [ -x "$(command -v ack)" ]; then
		apt-get -y install rsync rdiff-backup ssmtp mutt
		apt-get -y install cifs-utils smbclient
		apt-get -y install tree ack

		mkdir -p /usr/local/backup-united/backup
		mkdir -p /usr/local/backup-united/backup-scripts
		mkdir -p /usr/local/backup-united/backups

		if [ ! -f $MAILSENDER ]; then
			wget https://raw.githubusercontent.com/eesmer/DocAndTools/main/BackupUnited/mail-sender.sh /usr/local/backup-united/
			chmod +x /usr/local/backup-united/mail-sender.sh
		fi
fi

function main_menu(){
MENUCHOOSE=$(whiptail --nocancel --backtitle "Backup United" --title "Main Menu" --menu "Choose an option" 25 78 16 \
"Add Backup Job" "" \
"Remove Backup Job" "" \
"Backup Job List" "" \
"" "" \
"Backup List" "" \
"" "" \
"Mail Settings" "" \
"Add Recipient" "" \
"Remove Recipient" "" \
"Recipient List" "" \
"" "" \
"Exit" "" \
3>&1 1>&2 2>&3)

if [ "$MENUCHOOSE" = "" ]; then
        clear
        main_menu
elif [ "$MENUCHOOSE" = "Exit" ]; then
	echo "See you.."
        exit 1
elif [ "$MENUCHOOSE" = "Add Backup Job" ]; then
        add_backup
elif [ "$MENUCHOOSE" = "Remove Backup Job" ]; then
	delete_backup
elif [ "$MENUCHOOSE" = "Backup Job List" ]; then
	backup_job_list
elif [ "$MENUCHOOSE" = "Backup List" ]; then
	backup_list

elif [ "$MENUCHOOSE" = "Mail Settings" ]; then
	mail_settings
elif [ "$MENUCHOOSE" = "Add Recipient" ]; then
	add_recipient
elif [ "$MENUCHOOSE" = "Remove Recipient" ]; then
	remove_recipient
elif [ "$MENUCHOOSE" = "Recipient List" ]; then
	recipient_list
fi

}

function add_backup(){
BACKUPTYPE=$(whiptail --backtitle "Backup United" --title "Select Backup Type" --radiolist "Choose" 20 40 15 \
                "Daily" "" OFF \
                "Weekly" "" OFF \
                "Monthly" "" OFF \
                3>&1 1>&2 2>&3)
		
	if [ "$BACKUPTYPE" = "Daily" ]; then
		BACKUPHOUR=$(whiptail --title "Backup Hour" --inputbox "At What Hour - For Example 10" 10 60  3>&1 1>&2 2>&3)
		BACKUPMIN=$(whiptail --title "Backup Minute" --inputbox "At What Minute - For Example 18" 10 60  3>&1 1>&2 2>&3)
		if [[ "$BACKUPHOUR" =~ ^[0-9]+$ ]] && [[ "$BACKUPMIN" =~ ^[0-9]+$ ]]; then
			if [ "$BACKUPHOUR" -gt 23 ] || [ "$BACKUPMIN" -gt 59 ]; then
				#echo "Backup hour is not bigger than 23 and Backup Minute is not bigger than 59"
				whiptail --title "At What Hour" --msgbox "Backup hour is not bigger than 23 and Backup Minute is not bigger than 59" 10 60  3>&1 1>&2 2>&3
				add_backup
			fi
		else
			#echo "Backup Hour and Minute must a numbers"
			whiptail --title "At What Hour" --msgbox "Backup Hour and Minute must a numbers" 10 60  3>&1 1>&2 2>&3
			add_backup
		fi
		BACKUPTIME=$BACKUPHOUR:$BACKUPMIN
	elif
		[ "$BACKUPTYPE" = "Weekly" ]; then
		BACKUPTIME=$(whiptail --title "Select Day" --radiolist "Choose" 20 40 15 \
			"Monday" "" OFF \
			"Tuesday" "" OFF \
                        "Wednesday" "" OFF \
                        "Thursday" "" OFF \
                        "Friday" "" OFF \
                        "Saturday" "" OFF \
                        "Sunday" "" OFF \
                        3>&1 1>&2 2>&3)
	elif
		[ "$BACKUPTYPE" = "Monthly" ]; then
		BACKUPDAY=$(whiptail --title "Backup Day" --inputbox "Which day of the month? \n Please enter numbers between 1-28 for The Backup Day" 10 60  3>&1 1>&2 2>&3)
		if [[ "$BACKUPDAY" =~ ^[0-9]+$ ]]; then
			if [ "$BACKUPDAY" -gt 28 ] || [ "$BACKUPDAY" -lt 1 ]; then
				whiptail --title "" --msgbox "Please enter a number from 1-28 for the backup day definition" 10 60  3>&1 1>&2 2>&3
				add_backup
			else
				BACKUPTIME=$BACKUPDAY
			fi
		else
			whiptail --title "" --msgbox "The backup day should be defined by the number 1-28" 10 60  3>&1 1>&2 2>&3
			add_backup
		fi
fi
	
if [ "$BACKUPTYPE" = "" ] || [ "$BACKUPTIME" = "" ]; then
	whiptail --title "Backup Name" --msgbox "Backup Type and Time is not null" 10 60  3>&1 1>&2 2>&3
else
	record_backup
fi
main_menu
}

function record_backup(){
JOCKER=$
BACKUPFROM=$(whiptail --backtit "Backup United" --title "Backup From" --radiolist "Choose:"     30 40 20 \
	"Local_Directory_Backup" "" off \
	"SMB_Share_Backup" "" off 3>&1 1>&2 2>&3)
case $BACKUPFROM in
Local_Directory_Backup)
BACKUPNAME=$(whiptail --title "Backup Name" --inputbox "Please Enter Backup Name to be Defined" 10 60  3>&1 1>&2 2>&3)
BACKUPPATH=$(whiptail --title "Path of the Area" --inputbox "Please Enter the Destination of the Backup Area (/mnt/backup1,/var/www)" 10 60  3>&1 1>&2 2>&3)
cat > "$BACKUP_SCRIPTS/$BACKUPNAME" <<EOF
#!/bin/bash
#BACKUPPATH=$BACKUPPATH
#BACKUPNAME=$BACKUPNAME

if [ -d "$BACKUPPATH" ]; then
rsync -avz "$BACKUPPATH" "$BACKUPS/$BACKUPNAME"
tar -cf /usr/local/backup-united/backups/$BACKUPNAME-"$JOCKER(date +%Y%m%d-%H%M).tar.gz" /usr/local/backup-united/backups/$BACKUPNAME
echo "$BACKUPNAME Backup Successfully Taken" > /usr/local/backup-united/mail-message
else
echo "$BACKUPNAME Backup Successfully Taken" > /usr/local/backup-united/mail-message
fi
EOF
;;
SMB_Share_Backup)
echo "SMB Share Backup Menu"
BACKUPNAME=$(whiptail --title "Backup Name" --inputbox "Please Enter Backup Name to be Defined" 10 60  3>&1 1>&2 2>&3)
BACKUPPATH=$(whiptail --title "Path of the Area" --inputbox "Please Enter the Destination of the Backup Area (//SERVER_IP/SHARE)" 10 60  3>&1 1>&2 2>&3)
BACKUPUSR=$(whiptail --title "Username" --inputbox "Please Enter Username for Access" 10 60  3>&1 1>&2 2>&3)
BACKUPPWD=$(whiptail --title "Password" --passwordbox "Please Enter Password for Access" 10 60  3>&1 1>&2 2>&3)

if [ "$BACKUPNAME" = "" ] || [ "$BACKUPPATH" = "" ] || [ "$BACKUPUSR" = "" ] || [ "$BACKUPPWD" = "" ]; then
	whiptail --title "SMB BACKUP" --msgbox "Please Fill In All Fields" 10 60  3>&1 1>&2 2>&3
else
cat > "$BACKUP_SCRIPTS/$BACKUPNAME" <<EOF
#!/bin/bash
#BACKUPPATH=$BACKUPPATH
#BACKUPNAME=$BACKUPNAME

if [ -d "/tmp/$BACKUPNAME" ]; then
rm -rf /tmp/$BACKUPNAME
fi
if [ -e "/tmp/$BACKUPNAME-mountok" ]; then
rm -rf /tmp/$BACKUPNAME-mountok
fi
if [ ! -d "/usr/local/backup-united/backups/$BACKUPNAME" ]; then
mkdir /usr/local/backup-united/backups/$BACKUPNAME
fi
mkdir /tmp/$BACKUPNAME
mount -t cifs $BACKUPPATH /tmp/$BACKUPNAME -o username=$BACKUPUSR,password=$BACKUPPWD && touch /tmp/$BACKUPNAME-mountok
if [ -e "/tmp/$BACKUPNAME-mountok" ]
then
rsync -avz /tmp/$BACKUPNAME /usr/local/backup-united/backups/$BACKUPNAME
tar -cf /usr/local/backup-united/backups/$BACKUPNAME-"$JOCKER(date +%Y%m%d-%H%M).tar.gz" /usr/local/backup-united/backups/$BACKUPNAME
BACKUPDATE=$JOCKER(date +%Y%m%d-%H%M)
echo "$BACKUPNAME Backup Successfully Taken - $JOCKERBACKUPDATE" > /usr/local/backup-united/mail-message
umount /tmp/$BACKUPNAME
rm -rf /tmp/$BACKUPNAME-mountok
else
echo "$BACKUPNAME Backup Failed" > /usr/local/backup-united/mail-message
fi

bash $MAILSENDER
EOF

# create service
cat > /etc/systemd/system/backupunited-$BACKUPNAME.service <<EOF
[Unit]
Description=BackupUnited $BACKUPNAME Service

[Service]
Type=simple
User=root
Group=root
ExecStart=$BACKUP_SCRIPTS/$BACKUPNAME

[Install]
WantedBy=multi-user.target
EOF

if [ "$BACKUPTYPE" = "Daily" ]; then
	DESCRIPTION="BackupUnited $BACKUPNAME Daily Timer"
	ONCALENDAR="*-*-* $BACKUPTIME:00"
fi

cat > /etc/systemd/system/backupunited-$BACKUPNAME.timer <<EOF
[Unit]
Description=$DESCRIPTION

[Timer]
OnCalendar=$ONCALENDAR
Unit=backupunited-$BACKUPNAME.service

[Install]
WantedBy=timers.target
EOF
chmod +x $BACKUP_SCRIPTS/$BACKUPNAME
systemctl start backupunited-$BACKUPNAME.timer
systemctl enable backupunited-$BACKUPNAME.timer
systemctl daemon-reload

#BOARDMSG="$BACKUPNAME Backup Job Successfully Added"
fi
;;
*)
;;
esac
main_menu
}

function delete_backup(){
	BACKUPNAME=$(whiptail --backtitle "Backup United" --title "Backup Name" --inputbox "Please Enter Backup Name to be Deleted" 10 60  3>&1 1>&2 2>&3)
	if [ "$BACKUPNAME" = "" ]; then
		whiptail --msgbox "BackupName is Empty" 10 60 3>&1 1>&2 2>&3
	else
		if [ -e "$BACKUP_SCRIPTS/$BACKUPNAME" ]; then
			rm -rf $BACKUP_SCRIPTS/$BACKUPNAME
			rm /etc/systemd/system/backupunited-$BACKUPNAME.service
			rm /etc/systemd/system/backupunited-$BACKUPNAME.timer
			systemctl daemon-reload
                        systemctl reset-failed
			BOARDMSG="$BACKUPNAME Backup Job Successfully Removed"
		else
			whiptail --msgbox "Backup Not Found!!" 10 60 3>&1 1>&2 2>&3
		fi
	fi
	main_menu
}

function clean_backup(){
	ls /usr/local/backup-united/backup/ > /tmp/folderlist
	numfolder=$(cat /tmp/folderlist | wc -l)
	i=1
	while [ "$i" -le $numfolder ]; do
		folder=$(ls -l | sed -n $i{p} /tmp/folderlist)
		cd /usr/local/backup-united/backup/$folder
		pwd
		rdiff-backup --remove-older-than 15D /usr/local/backup-united/backup/$folder
		i=$(( i + 1 ))
	done
	rm -rf /tmp/folderlist
	main_menu
}

function mail_settings(){
	MAILADDR=$(whiptail --backtitle "Backup United" --title "Email Address" --inputbox "Please Enter E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	if [ "$?" = "1" ]; then main_menu; fi
	SMTP=$(whiptail --title "SMTP Address" --inputbox "Please Enter SMTP Address - SMTP Port\n\nExample:\nsmtps://example@domain.com@mail.domain.com:465/" 10 60  3>&1 1>&2 2>&3)
	if [ "$?" = "1" ]; then main_menu; fi
	MAILUSER=$(whiptail --backtitle "Backup United" --title "Username" --inputbox "Please Enter Username for E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	if [ "$?" = "1" ]; then main_menu; fi
	MAILPASS=$(whiptail --backtitle "Backup United" --title "Password" --passwordbox "Please Enter Password for E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	if [ "$?" = "1" ]; then main_menu; fi
	#MAILDOMAIN=$(whiptail --title "Domain" --inputbox "Please Enter Domain for E-Mail Address (For Example: domain.com,example.net)" 10 60  3>&1 1>&2 2>&3)
	#cat /dev/null > /etc/ssmtp/ssmtp.conf
	if [ "$MAILADDR" = "" ] || [ "$SMTP" = "" ] || [ "$MAILUSER" = "" ] || [ "$MAILPASS" = "" ]; then
		whiptail --backtitle "Backup United" --title "Mail Settings" --msgbox "Please fill in all fields" 10 60  3>&1 1>&2 2>&3
		mail_settings
	fi
cat > ~/.muttrc <<EOF
# SMTP
set from = "$MAILADDR"
set realname = "Backup United"
set smtp_url = "$SMTP"
set smtp_pass = "$MAILPASS"
set ssl_force_tls = yes
unset ssl_starttls
EOF
#echo root:$MAILADDR:$SMTP
#chfn -f 'backup-united' root
pause
}

function backup_job_list(){
	echo "Backup Job List" > /tmp/backup_job_list.txt
	echo "--------------------------------------------" >> /tmp/backup_job_list.txt
	
	ls $BACKUP_SCRIPTS > /tmp/backupjobname.txt
	BACKUPJOBCOUNT=$(cat "/tmp/backupjobname.txt" | wc -l)
	i=1
	while [ "$i" -le $BACKUPJOBCOUNT ]; do
		BACKUPJOBNAME=$(ls | sed -n $i{p} "/tmp/backupjobname.txt")
		BACKUPJOBTYPE=$(cat /etc/systemd/system/*"$BACKUPJOBNAME".timer | grep "Description" | cut -d " " -f3)
		BACKUPJOBTIME=$(cat /etc/systemd/system/*"$BACKUPJOBNAME".timer | grep "OnCalendar=" | cut -d " " -f2)
		BACKUPJOBPATH=$(ack "BACKUPPATH=" "$BACKUP_SCRIPTS/$BACKUPJOBNAME" | cut -d "=" -f2)
		echo "$BACKUPJOBNAME : $BACKUPJOBTYPE : $BACKUPJOBTIME - $BACKUPJOBPATH" >> /tmp/backup_job_list.txt
		i=$(( i + 1 ))
	done
	
	whiptail --backtitle "Backup United" --title "Backup Job List" --textbox --scrolltext "/tmp/backup_job_list.txt"  40 80  3>&1 1>&2 2>&3
	rm /tmp/backup_job_list.txt
	main_menu
}

function backup_list(){
	echo "Backups" > /tmp/backup_dir.txt
	echo "--------------------------------------------" >> /tmp/backup_dir.txt
	tree $BACKUPS >> /tmp/backup_dir.txt
	whiptail --backtitle "Backup United" --title "Backup Directory" --textbox --scrolltext "/tmp/backup_dir.txt"  40 80  3>&1 1>&2 2>&3
	main_menu
}

function add_recipient(){
	EMAILADDRESS=$(whiptail --title "Email Address" --inputbox "Please enter a E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	if [ "$?" = "1" ]; then main_menu; fi
	echo "$EMAILADDRESS" >> $MAILRECIPIENT && whiptail --title "Add Recipient" --msgbox "Email Address added to Recipient List" 10 60  3>&1 1>&2 2>&3 
	main_menu
}

function remove_recipient(){
        EMAILADDRESS=$(whiptail --title "Email Address" --inputbox "Please enter a E-Mail Address" 10 60  3>&1 1>&2 2>&3)
        EXIST=FALSE && ack "$EMAILADDRESS" $MAILRECIPIENT >/dev/null && EXIST=TRUE
        if [ "$EXIST" = TRUE ]; then
                sed -i '/'$EMAILADDRESS'/d' $MAILRECIPIENT
                sed -i '/^$/d' $MAILRECIPIENT
                whiptail --title "Remove Recipient" --msgbox "Email Address removed in Recipient List" 10 60  3>&1 1>&2 2>&3
        else
                whiptail --title "Remove Recipient" --msgbox "Email Address Not Found in Recipient List" 10 60  3>&1 1>&2 2>&3
                main_menu
        fi
        main_menu      
}

function recipient_list(){
	echo "Mail Recipient List" > /tmp/recipient_list.txt
	echo "--------------------------------------------" >> /tmp/recipient_list.txt
	cat $MAILRECIPIENT >> /tmp/recipient_list.txt
	whiptail --backtitle "Backup United" --title "Recipient List" --textbox --scrolltext "/tmp/recipient_list.txt"  40 80  3>&1 1>&2 2>&3
	rm /tmp/recipient_list.txt
	main_menu
}

# CTRL+C, CTRL+Z
trap '' SIGINT SIGQUIT SIGTSTP

main_menu
