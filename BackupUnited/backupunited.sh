#!/bin/bash

WDIR=/usr/local/backupunited
BACKUP_SCRIPTS=$WDIR/backup-scripts
BACKUPS=$WDIR/backups
SCRIPTS=$WDIR/scripts
REPORTS=$WDIR/reports
MAILRECIPIENT=$REPORTS/mail-recipient
MAILMESSAGE=$REPORTS/mail-message
MAILSENDER=$SCRIPTS/mail-sender.sh
RESTOREDIR=$WDIR/backups/restoredir
WEBSITE=www.esmerkan.com

# Check Install/Update
function checkandinstall(){
WDIREXIST=EXIST
DAILYSCRIPT=EXIST
WEEKLYSCRIPT=EXIST
MONTHLYSCRIPT=EXIST
YEARLYSCRIPT=EXIST
RUNSTATUS=RUN

if [ ! -d "$WDIR" ]; then
	WDIREXIST=NONE
	RUNSTATUS=NEWINSTALL
else
	if [ ! -f "$SCRIPTS/dailybackup.sh" ]; then
		DAILYSCRIPT=NONE
		RUNSTATUS=UPDATE
	fi
	if [ ! -f "$SCRIPTS/weeklybackup.sh" ]; then
		WEEKLYSCRIPT=NONE
		RUNSTATUS=UPDATE
	fi
	if [ ! -f "$SCRIPTS/monthlybackup.sh" ]; then
		MONTHLYSCRIPT=NONE
		RUNSTATUS=UPDATE
	fi
	if [ ! -f "$SCRIPTS/yearlybackup.sh" ]; then
		YEARLYSCRIPT=NONE
		RUNSTATUS=UPDATE
	fi
fi

echo "Run Status: $RUNSTATUS"
echo "Daily     : $DAILYSCRIPT"
echo "Weekly    : $WEEKLYSCRIPT"
echo "Monthly   : $MONTHLYSCRIPT"
echo "Yearly    : $YEARLYSCRIPT"

sleep 2

if [ ! "$RUNSTATUS" = "RUN" ];then
	whiptail --title "Installation Info" --msgbox "The installation needs to be completed.\nYou will be directed to the installation." 10 60  3>&1 1>&2 2>&3
	curl -4 $WEBSITE &>/dev/null
	if [ ! "$?" = "0" ]; then
		whiptail --title "Internet Access" --msgbox "Internet connection could not be established." 10 60  3>&1 1>&2 2>&3
		clear
		tput setaf 9
		echo -e
		echo "[ ERROR ]"
		echo "The installation or update cannot continue because there is no internet access. :("
		tput sgr0
		echo "================================================================================"
		echo -e
		exit 0;
	fi	
	if [ "$WDIREXIST" = "NONE" ]; then
		echo "Working directory not found."
		echo "Starting the installation.."
		mkdir -p $BACKUP_SCRIPTS
		mkdir -p $SCRIPTS
		mkdir -p $REPORTS
		mkdir -p $BACKUPS/daily/
		mkdir -p $BACKUPS/weekly/
		mkdir -p $BACKUPS/monthly/
		mkdir -p $BACKUPS/yearly/
		mkdir -p $BACKUPS/restoredir/
		
		#apt-get -y install rsync rdiff-backup
		#apt-get -y install cifs-utils smbclient
		#apt-get -y install tree ack
		#apt-get -y install whiptail
		#apt-get -y install ssmtp mutt
	fi
	if [ "$DAILYSCRIPT" = "NONE" ]; then
		echo -e
		echo "Daily Backup Script is downloading.."
		export DEBIAN_FRONTEND=noninteractive
		wget -qO $SCRIPTS/dailybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/dailybackup.sh
	fi
	if [ "$WEEKLYSCRIPT" = "NONE" ]; then
		echo -e
		echo "Weekly Backup Script is downloading.."
		export DEBIAN_FRONTEND=noninteractive
		wget -qO $SCRIPTS/weeklybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/weeklybackup.sh
	fi
	if [ "$MONTHLYSCRIPT" = "NONE" ]; then
		echo -e
		echo "Monthly Backup Script is downloading.."
		export DEBIAN_FRONTEND=noninteractive
		wget -qO $SCRIPTS/monthlybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/monthlybackup.sh
	fi
	if [ "$YEARLYSCRIPT" = "NONE" ]; then
		echo -e
		echo "Yearly Backup Script is downloading.."
		export DEBIAN_FRONTEND=noninteractive
		wget -qO $SCRIPTS/yearlybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/yearlybackup.sh
	fi
#else
	#clear
	#show_menu;
fi
clear
#pause
#exit 0;
}

function pause(){
local message="$@"
[ -z $message ] && message="Press [Enter] to continue ..."
read -p "$message" readEnterKey
}

rm /tmp/scheduledbackups.txt
ls $BACKUP_SCRIPTS > /tmp/backupjobname.txt
BACKUPJOBCOUNT=$(cat "/tmp/backupjobname.txt" | wc -l)
i=1
while [ "$i" -le $BACKUPJOBCOUNT ]; do
	BACKUPJOBNAME=$(ls | sed -n $i{p} "/tmp/backupjobname.txt")
	BACKUPJOBTYPE=$(cat /etc/systemd/system/*"$BACKUPJOBNAME".timer | grep "Description" | cut -d " " -f3)
	BACKUPJOBTIME=$(cat /etc/systemd/system/*"$BACKUPJOBNAME".timer | grep "OnCalendar=" | cut -d " " -f2)
	echo "$BACKUPJOBNAME : $BACKUPJOBTYPE : $BACKUPJOBTIME" >> /tmp/scheduledbackups.txt
	i=$(( i + 1 ))
done
#echo -e
rm /tmp/backupjobname.txt

function show_menu(){
# RestoreDir Share Status Check
SHARESTATUS=$(systemctl is-active smbd.service)
date
echo -e
tput setaf 5
echo "     BackupUnited                               "
tput sgr0
echo "   |-------------------------------------------|"
tput setaf 7
echo "    Backup Management                           "
tput sgr0
echo "   |-------------------------------------------|"
echo "   | 1.Add    Backup Job  | 6.Backup List      |"
echo "   | 2.Remove Backup Job  | 7.Backup Job List  |"
echo "   |-------------------------------------------|"
tput setaf 7
echo "    Restore Management                         "
tput sgr0
echo "   |-------------------------------------------|"
echo "   | 30.Restore Backup                         |"
echo "   | - RestoreDir -                            |" 
echo "   |   31.Show | 32.Share | 33.UnShare         |"
echo "   |-------------------------------------------|"
echo "   | 40.Backup Cleaner                         |"
echo "   |-------------------------------------------|"
tput setaf 7
echo "    Share Status: $SHARESTATUS                  "
tput sgr0
echo "   |-------------------------------------------|"
tput setaf 7
echo "    Mail Settings                               "
tput sgr0
echo "   |-------------------------------------------|"
echo "   | 20.Mail Sender Set.  |                    |"
echo "   | 21.Add Recipient     |                    |"
echo "   | 22.Remove Recipient  |                    |"
echo "   | 23.Recipient List    |                    |"
echo "   |-------------------------------------------|"
echo -e
tput setaf 7
echo "   ::. Disk Usage / Data Size ::.               "
tput sgr0
echo "   ---------------------------------------------"
df -H | grep -vE 'Filesystem|tmpfs|cdrom|udev' | awk '{ print $5" "$1"("$2" "$3")" " --- "}' > /tmp/disk_usage.txt
cat /tmp/disk_usage.txt | grep -v "/dev/loop"
echo "   ---------------------------------------------"
du -skh $BACKUPS/*
echo "   ---------------------------------------------"
echo -e
tput setaf 9
echo "    -----------"
echo "    | 99.Exit |"
echo "    -----------"
tput sgr0
echo -e
}

function add_backup(){

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

if [ "$BACKUPTIME" = "" ]; then
	whiptail --title "Backup Name" --msgbox "Backup Type and Time is not null" 10 60  3>&1 1>&2 2>&3
else
	record_backup
fi
}

function record_backup(){
JOCKER=$
BACKUPFROM=$(whiptail --title "Backup From" --radiolist "Choose:"     30 40 20 \
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
echo "$BACKUPNAME Backup Failed" > $MAILMESSAGE
#rdiff-backup backup "$BACKUPPATH" /usr/local/backupunited/backups/sync/$BACKUPNAME && echo "$BACKUPNAME Backup Taken Successfully" > $MAILMESSAGE
rsync -arz "$BACKUPPATH" /usr/local/backupunited/backups/sync/ && echo "$BACKUPNAME Backup Taken Successfully" > $MAILMESSAGE
BACKUPDATE=$JOCKER(date +%Y%m%d-%H%M)
else
echo "$BACKUPNAME Backup Failed" > $MAILMESSAGE
fi

bash $SCRIPTS/dailybackup.sh $BACKUPNAME

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
if [ ! -d "/usr/local/backupunited/backups/sync/$BACKUPNAME" ]; then
mkdir -p /usr/local/backupunited/backups/sync/$BACKUPNAME
fi
mkdir /tmp/$BACKUPNAME
mount -t cifs $BACKUPPATH /tmp/$BACKUPNAME -o username="$BACKUPUSR",password="$BACKUPPWD" && touch /tmp/$BACKUPNAME-mountok
if [ -e "/tmp/$BACKUPNAME-mountok" ]
then
#rdiff-backup backup /tmp/$BACKUPNAME /usr/local/backupunited/backups/sync/$BACKUPNAME
rsync -arz /tmp/$BACKUPNAME /usr/local/backupunited/backups/sync/ && echo "$BACKUPNAME Backup Taken Successfully" > $MAILMESSAGE
BACKUPDATE=$JOCKER(date +%Y%m%d-%H%M)
echo "$BACKUPNAME Backup Taken Successfully" > $MAILMESSAGE
umount /tmp/$BACKUPNAME
rm -rf /tmp/$BACKUPNAME-mountok
else
echo "$BACKUPNAME Backup Failed" > $MAILMESSAGE
fi

EOF

# WEEKLY BACKUP & MONTHLY BACKUP
echo "TODAY1=$JOCKER(date | cut -d "'" "'" -f1)" >> $BACKUP_SCRIPTS/$BACKUPNAME 
echo "TODAY2=$JOCKER(date | cut -d "'" "'" -f3)" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "TODAY3=$JOCKER(date | cut -d "'" "'" -f2)" >> $BACKUP_SCRIPTS/$BACKUPNAME

echo "if [ ! ""$JOCKER""TODAY1"" = ""Sun"" ]; then" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $SCRIPTS/dailybackup.sh $BACKUPNAME" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "fi" >> $BACKUP_SCRIPTS/$BACKUPNAME

echo "if [ ""$JOCKER""TODAY1"" = ""Sun"" ]; then" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $SCRIPTS/weeklybackup.sh $BACKUPNAME" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "fi" >> $BACKUP_SCRIPTS/$BACKUPNAME

echo "if [ ""$JOCKER""TODAY2"" = ""01"" ]; then" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $SCRIPTS/monthlybackup.sh $BACKUPNAME" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "fi" >> $BACKUP_SCRIPTS/$BACKUPNAME

echo "if [ ""$JOCKER""TODAY2"" = ""31"" ] && [ ""$JOCKER""TODAY3"" = ""Dec"" ]; then" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $SCRIPTS/yearlybackup.sh $BACKUPNAME" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "fi" >> $BACKUP_SCRIPTS/$BACKUPNAME

echo -e >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $MAILSENDER" >> $BACKUP_SCRIPTS/$BACKUPNAME

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

DESCRIPTION="BackupUnited $BACKUPNAME Daily Timer"
ONCALENDAR="*-*-* $BACKUPTIME:00"

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
pause
}

function delete_backup(){
	BACKUPNAME=$(whiptail --title "Backup Name" --inputbox "Please Enter Backup Name to be Deleted" 10 60  3>&1 1>&2 2>&3)
	if [ "$BACKUPNAME" = "" ]; then
		whiptail --msgbox "BackupName is Empty" 10 60 3>&1 1>&2 2>&3
	else
		if [ -e "$BACKUP_SCRIPTS/$BACKUPNAME" ]; then
			rm -rf $BACKUP_SCRIPTS/$BACKUPNAME
			rm /etc/systemd/system/backupunited-$BACKUPNAME.service
			rm /etc/systemd/system/backupunited-$BACKUPNAME.timer
			# rm /etc/systemd/system/timers.target.wants/backupunited-$BACKUPNAME.*
			systemctl daemon-reload
                        systemctl reset-failed
			#BOARDMSG="$BACKUPNAME Backup Job Successfully Removed"
		else
			whiptail --msgbox "Backup Not Found!!" 10 60 3>&1 1>&2 2>&3
		fi
	fi
	pause
}

#function clean_backup(){
#	ls /usr/local/backup-united/backup/ > /tmp/folderlist
#	numfolder=$(cat /tmp/folderlist | wc -l)
#	i=1
#	while [ "$i" -le $numfolder ]; do
#		folder=$(ls -l | sed -n $i{p} /tmp/folderlist)
#		cd /usr/local/backup-united/backup/$folder
#		pwd
#		rdiff-backup --remove-older-than 15D /usr/local/backup-united/backup/$folder
#		i=$(( i + 1 ))
#	done
#	rm -rf /tmp/folderlist
#	pause
#}

function mail_settings(){
	MAILADDR=$(whiptail --title "Backup Name" --inputbox "Please Enter E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	SMTP=$(whiptail --title "Path of the Area" --inputbox "Please Enter SMTP Address-SMTP Port your Mailserver (smtp.gmail.com:587)" 10 60  3>&1 1>&2 2>&3)
	MAILUSER=$(whiptail --title "Username" --inputbox "Please Enter Username for E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	MAILPASS=$(whiptail --title "Password" --passwordbox "Please Enter Password for E-Mail Address" 10 60  3>&1 1>&2 2>&3)
	MAILDOMAIN=$(whiptail --title "Domain" --inputbox "Please Enter Domain for E-Mail Address (gmail.com,xyz.net etc)" 10 60  3>&1 1>&2 2>&3)
	cat /dev/null > /etc/ssmtp/ssmtp.conf
cat > /etc/ssmtp/ssmtp.conf <<EOF
root=$MAILADDR
mailhub=$SMTP
AuthUser=$MAILUSER
AuthPass=$MAILPASS
UseTLS=YES
UseSTARTTLS=YES
rewriteDomain=$MAILDOMAIN
hostname=$HOSTNAME
FromLineOverride=YES
EOF

echo root:$MAILADDR:$SMTP
chfn -f 'backup-united' root

cp /usr/local/backupunited/notification/99-mail-sender /usr/local/backupunited/backup-scripts/
pause
}

function backup_job_list(){
	tput setaf 8
	echo -e
	echo "Backup Job List"
	echo "---------------"
	tput sgr0
	ls $BACKUP_SCRIPTS > /tmp/backupscriptlist.txt
	JOBCOUNT=$(cat /tmp/backupscriptlist.txt | wc -l)
	i=1
	while [ "$i" -le "$JOBCOUNT" ]; do
		JOB=$(ls -l |sed -n $i{p} /tmp/backupscriptlist.txt)
		RUNTIME=$(systemctl status backupunited-$JOB.timer | grep Trigger: | cut -d ";" -f2 | xargs)
		echo "$JOB - $RUNTIME" >> /tmp/backupscriptdetail.txt
		echo "----------------------------------------------" >> /tmp/backupscriptdetail.txt
		i=$(( i + 1 ))
	done
	cat /tmp/backupscriptdetail.txt
	rm /tmp/backupscriptlist.txt
	rm /tmp/backupscriptdetail.txt

	echo -e
	tput setaf 8
	echo "Backup Paths"
	echo "---------------"
	tput sgr0
	ack "BACKUPPATH=" "$BACKUP_SCRIPTS" | cut -d "=" -f2
	echo -e
	tput setaf 8
	echo "Service Status & Info"
	echo "---------------------------------------------------------------------------------------------------------------------------------------------------"
	tput setaf 7
	systemctl list-timers | grep "backupunited"
	tput sgr0
	echo -e
	pause
}

#function backup_now(){
#	chmod +x $BACKUP_SCRIPTS/*
#	run-parts $BACKUP_SCRIPTS
#
#	NUMRECIPIENT=$(cat "$MAILRECIPIENT" | wc -l)
#	i=0
#	while [ "$i" -le $NUMRECIPIENT ]; do
#		RECIPIENT=$(ls -l | sed -n $i{p} "$MAILRECIPIENT")
#		cat $MAILMESSAGE | mutt -s "Backup United Notification" $RECIPIENT
#		i=$(( i + 1 ))
#	done
#	pause
#}

function backup_list(){
	ls $BACKUPS/daily > /tmp/dailybackups.txt
	ls $BACKUPS/weekly > /tmp/weeklybackups.txt
	ls $BACKUPS/monthly > /tmp/monthlybackups.txt
	ls $BACKUPS/yearly > /tmp/yearlybackups.txt
		
	tput setaf 8
	echo "Backup List"
	echo "---------------"
	tput setaf 5
	echo "Daily Backups:"
	tput sgr0
	cat /tmp/dailybackups.txt
	echo "---------------------------------------------"
	echo -e
	tput setaf 5
	echo "Weekly Backups:"
	tput sgr0
	cat /tmp/weeklybackups.txt
	echo "---------------------------------------------"
	echo -e
	tput setaf 5
	echo "Monthly Backups:"
	tput sgr0
	cat /tmp/monthlybackups.txt
	echo "---------------------------------------------"
	echo -e
	tput setaf 5
	echo "Yearly Backups:"
	tput sgr0
	cat /tmp/yearlybackups.txt
	echo "---------------------------------------------"
	echo -e
	rm /tmp/dailybackups.txt
	rm /tmp/weeklybackups.txt
	rm /tmp/monthlybackups.txt
	rm /tmp/yearlybackups.txt
	
#	tput setaf 7
#	echo "Increment List from Backup Sync."
#	echo "---------------------------------------------"
#	tput sgr0
#	ls /usr/local/backupunited/backups/sync/ > /tmp/backupdirs.txt
#	let i=0
#	while read -r LINE; do
#		let i=$i+1
#		W+=($LINE " ")
#		echo -e
#		tput setaf 4
#		echo "Backup Name: $LINE"
#		echo "---------------------------------------------"
#		tput sgr0
#		rdiff-backup -l /usr/local/backupunited/backups/sync/$LINE
#	done < <( cat /tmp/backupdirs.txt)
#	rm /tmp/backupdirs.txt
	pause
}

function scheduled_jobs(){
	tput setaf 8
	echo "Scheduled Backup Jobs"
	echo "---------------------"
	tput sgr0
	ls $BACKUP_SCRIPTS > /tmp/backupjobname.txt
	BACKUPJOBCOUNT=$(cat "/tmp/backupjobname.txt" | wc -l)
	i=1
	while [ "$i" -le $BACKUPJOBCOUNT ]; do
		BACKUPJOBNAME=$(ls | sed -n $i{p} "/tmp/backupjobname.txt")
		BACKUPJOBTYPE=$(cat /etc/systemd/system/*"$BACKUPJOBNAME".timer | grep "Description" | cut -d " " -f3)
		BACKUPJOBTIME=$(cat /etc/systemd/system/*"$BACKUPJOBNAME".timer | grep "OnCalendar=" | cut -d " " -f2)
		echo "$BACKUPJOBNAME : $BACKUPJOBTYPE : $BACKUPJOBTIME"
		i=$(( i + 1 ))
	done
	echo -e
	rm /tmp/backupjobname.txt
	pause
}

function add_recipient(){
	read -p "E-Mail Address : " EMAILADDRESS
	echo "$EMAILADDRESS" >> $MAILRECIPIENT
	sed -i '/^$/d' $MAILRECIPIENT
	echo -e
	tput setaf 5
	echo "$EMAILADDRESS successfully added to Mail Recipient List"
	tput sgr0
	echo -e
	pause
}

function remove_recipient(){
	read -p "Recipient Mail : " EMAILADDRESS
	RESULT=FALSE
	ack "$EMAILADDRESS" $MAILRECIPIENT >/dev/null && RESULT=TRUE
	if [ "$RESULT" = "TRUE" ]; then
		sed -i "/$EMAILADDRESS/d" $MAILRECIPIENT
		sed -i '/^$/d' $MAILRECIPIENT
		echo -e
		tput setaf 5
		echo "$EMAILADDRESS successfully removed from Mail Recipient List"
		tput sgr0
		echo -e
	else
		whiptail --msgbox "Recipient Not Found!!" 10 60 3>&1 1>&2 2>&3
	fi
	pause
}

function recipient_list(){
	tput setaf 8
	echo "Mail Recipient List"
	echo "-------------------"
	tput sgr0
	cat $MAILRECIPIENT
	echo -e
	pause
}

function restore_backup(){
	BACKUPDIR=$(whiptail --title "Select Backup Dir" --radiolist "Choose" 20 40 15 \
		"current" "" OFF \
		"daily" "" OFF \
		"weekly" "" OFF \
		"monthly" "" OFF \
		"yearly" "" OFF \
		3>&1 1>&2 2>&3)
	
	# BackupDir List
	#DIRLIST=`for DL in $(ls -1 /usr/local/backupunited/backups/$BACKUPDIR/); do echo $DL "-"; done`
	#whiptail --title "Backups" --menu "Choice Backup" 20 80 10 $DIRLIST
	
	# Determining the parameter in the if condition for file or dir exist check
	PARAM="-f"
	if [ "$BACKUPDIR" = "current" ]; then PARAM="-d"; fi

	ls /usr/local/backupunited/backups/$BACKUPDIR > /tmp/backuplist.txt && LISTCOUNT=$(cat /tmp/backuplist.txt | wc -l)
	if [ ! "$LISTCOUNT" = 0 ]; then
		whiptail --title="Backups" --textbox /tmp/backuplist.txt 20 50 10
		BACKUPNAME=$(whiptail --title "Backup Name" --inputbox "Please Enter Backup Name" 10 60  3>&1 1>&2 2>&3)
		if [ $PARAM "/usr/local/backupunited/backups/$BACKUPDIR/$BACKUPNAME" ]; then
			#mkdir -p $RESTOREDIR
			cp -r /usr/local/backupunited/backups/$BACKUPDIR/$BACKUPNAME $RESTOREDIR/
		else
			whiptail --title "Select Backup" --msgbox "The specified file was not found\nUnable to restore" 10 60  3>&1 1>&2 2>&3
		fi
	else
		whiptail --title "Select Backup" --msgbox "The Backup Directory is null" 10 60  3>&1 1>&2 2>&3
	fi
	rm /tmp/backuplist.txt

	#tar -xvf $BACKUPS/$BACKUPDIR/$BACKUPNAME -C $RESTOREDIR/
	#mv $RESTOREDIR/usr/local/taliaundo/backups/sync/* $RESTOREDIR/
	#rm -r $RESTOREDIR/$RBACKUPNAME/rdiff-backup-data
	#rm -r $RESTOREDIR/usr
	
	pause
}

function show_restoredir(){
	tput setaf 8
	echo "Restore Directory"
	echo "-----------------"
	tput sgr0
	tree $RESTOREDIR
	pause
}

function share_restoredir(){
cat > /etc/samba/smb.conf << EOF
logging = file
map to guest = bad user

[restore-backup]
comment = all restored backup
browseable = yes
path = /usr/local/backupunited/backups/restoredir
guest ok = yes
read only = yes
EOF

chmod 644 /etc/samba/smb.conf

systemctl enable smbd.service &>/dev/null
systemctl start smbd.service &>/dev/null

SHARESTATUS=$(systemctl is-active smbd.service)
echo -e
tput setaf 5
echo "RestoreDir Share Status: $SHARESTATUS"
echo -e
tput sgr0

pause
}

function unshare_restoredir(){
	systemctl stop smbd.service
	systemctl is-active smbd.service
	
	SHARESTATUS=$(systemctl is-active smbd.service)
	echo -e
	tput setaf 5
	echo "RestoreDir Share Status: $SHARESTATUS"
	echo -e
	tput sgr0

	pause
}

function backup_cleaner(){
        # These processes will run as systemd service
        # ---------------------------------------------------------------------
        # -ctime 10   # exactly   10 days ago
        # -ctime +10  # more than 10 days ago
        # -ctime -10  # less than 10 days ago
        # ---------------------------------------------------------------------
        # atime -- access time = last time file opened
        # mtime -- modified time = last time file contents was modified
        # ctime -- changed time = last time file inode was modified
        echo -e
        tput setaf 4
        DAILYBACKUPS=$(find /usr/local/backupunited/backups/daily/ -maxdepth 1 -type f -ctime +1 | wc -l)
        echo "Daily backups older than 8 days: $DAILYBACKUPS"
        echo "----------------------------------------"
        find /usr/local/backupunited/backups/daily/ -maxdepth 1 -type f -ctime +8 | xargs -d '\n' rm -f
        WEEKLYBACKUPS=$(find /usr/local/backupunited/backups/weekly/ -maxdepth 1 -type f -ctime +10 | wc -l)
        echo "Weekly backups older than 10 days: $WEEKLYBACKUPS"
        echo "----------------------------------------"
        find /usr/local/backupunited/backups/weekly/ -maxdepth 1 -type f -ctime +10 | xargs -d '\n' rm -f
        MONTHLYBACKUPS=$(find /usr/local/backupunited/backups/monthly/ -maxdepth 1 -type f -ctime +40 | wc -l)
        echo "Monthly backups older than 40 days: $MONTHLYBACKUPS"
        echo "----------------------------------------"
        find /usr/local/backupunited/backups/monthly/ -maxdepth 1 -type f -ctime +40 | xargs -d '\n' rm -f
        YEARLYBACKUPS=$(find /usr/local/backupunited/backups/yearly/ -maxdepth 1 -type f -ctime +370 | wc -l)
        echo "Yearly backups older than 370 days: $YEARLYBACKUPS"
        echo "----------------------------------------"
        find /usr/local/backupunited/backups/yearly/ -maxdepth 1 -type f -ctime +370 | xargs -d '\n' rm -f
        tput sgr0

        pause
}

function read_input(){
local c
read -p "Please choose from Menu numbers " c
case $c in
1)	add_backup;;
2)	delete_backup;;
6)	backup_list;;
7)	backup_job_list;;
20)	mail_settings;;
21)	add_recipient;;
22)	remove_recipient;;
23)	recipient_list;;
30)	restore_backup;;
31)	show_restoredir;;
32)	share_restoredir;;
33)	unshare_restoredir;;
40)	backup_cleaner;;
99)	exit 0 ;;
*)	
echo "Please choose from Menu numbers"
pause
esac
}

# CTRL+C, CTRL+Z
trap '' SIGINT SIGQUIT SIGTSTP

while true
do
clear
checkandinstall
show_menu
read_input
done
