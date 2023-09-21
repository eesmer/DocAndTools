#!/bin/bash

WDIR=/usr/local/backupunited
BACKUP_SCRIPTS=$WDIR/backup-scripts
BACKUPS=$WDIR/backups
SCRIPTS=$WDIR/scripts
REPORTS=$WDIR/reports
MAILRECIPIENT=$REPORTS/mail-recipient
MAILMESSAGE=$REPORTS/mail-message
MAILSENDER=$SCRIPTS/mail-sender.sh
RESTOREDIR=/usr/local/backupunited/backups/restoredir

# Check Install/Update
function checkandinstall(){
WDIREXIST=EXIST
DAILYSCRIPT=NONE
WEEKLYSCRIPT=NONE
MONTHLYSCRIPT=NONE
YEARLYSCRIPT=NONE
RUNSTATUS=RUN

if [ ! -d "$WDIR" ]; then
	WDIREXIST=NONE
	RUNSTATUS=NEWINSTALL
else
	if [ -f "$SCRIPTS/dailybackup.sh" ]; then
		DAILYSCRIPT=EXIST
	else
		RUNSTATUS=UPDATE
	fi
	if [ -f "$SCRIPTS/weeklybackup.sh" ]; then
		WEEKLYSCRIPT=EXIST
	else
		RUNSTATUS=UPDATE
	fi
	if [ -f "$SCRIPTS/monthlybackup.sh" ]; then
		MONTHLYSCRIPT=EXIST
	else
		RUNSTATUS=UPDATE
	fi
	if [ -f "$SCRIPTS/yearlybackup.sh" ]; then
		YEARLYSCRIPT=EXIST
	else
		RUNSTATUS=UPDATE
	fi


fi

if [ ! "$RUNSTATUS" = "RUN" ];then
	whiptail --title "Installation Info" --msgbox "The installation needs to be completed.\nYou will be directed to the installation menu." 10 60  3>&1 1>&2 2>&3
	curl -4 www.esmerkan.com &>/dev/null
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
		exit 1
	fi
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
	
	apt-get -y install rsync rdiff-backup ssmtp mutt
	apt-get -y install cifs-utils smbclient
	apt-get -y install tree ack

elif [ "$DAILYSCRIPT" = "NONE" ]; then
	echo "Daily Backup Script is downloading.."
	export DEBIAN_FRONTEND=noninteractive
	wget -qO $SCRIPTS/dailybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/dailybackup.sh
elif [ "$WEEKLYSCRIPT" = "NONE" ]; then
	echo "Weekly Backup Script is downloading.."
	export DEBIAN_FRONTEND=noninteractive
	wget -qO $SCRIPTS/weeklybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/weeklybackup.sh
elif [ "$MONTHLYSCRIPT" = "NONE" ]; then
	echo "Monthly Backup Script is downloading.."
	export DEBIAN_FRONTEND=noninteractive
	wget -qO $SCRIPTS/monthlybackup.sh https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/scripts/monthlybackup.sh
elif [ "$YEARLYSCRIPT" = "NONE" ]; then
	echo "Yearly Script Bulunamadi. Yearly Script Yükleniyor.."
	echo "Yearly Backup Script is downloading.."
fi

pause
exit 0;
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
date
echo -e
tput setaf 5
echo "     BackupUnited                                "
tput sgr0
echo "   |--------------------------------------------|"
echo "   | Backup Management Menu                     |"
echo "   |--------------------------------------------|"
echo "   | 1.Add    Backup Job  | 6.Backup List       |"
echo "   | 2.Remove Backup Job  | 7.Backup Job List   |"
echo "   |--------------------------------------------|"
tput setaf 5
echo "                       Settings                  "
tput sgr0
echo "   |--------------------------------------------|"
echo "   | 20.Mail Sender Set.  | 30.Restore Backup   |"
echo "   | 21.Add Recipient     | 31.Show Restore Dir |"
echo "   | 22.Remove Recipient  |                     |"
echo "   | 23.Recipient List    |                     |"
echo "   |--------------------------------------------|"
tput setaf 9
echo "                     -----------                 "
echo "                     ** BOARD **                 "
echo "                     -----------                 "
tput setaf 1
tput sgr0
echo "     $BOARDMSG                                   "
echo "   ----------------------------------------------"
df -H | grep -vE 'Filesystem|tmpfs|cdrom|udev' | awk '{ print $5" "$1"("$2" "$3")" " --- "}' > /tmp/disk_usage.txt
cat /tmp/disk_usage.txt
echo "   ----------------------------------------------"
tput setaf 9
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
rsync -az "$BACKUPPATH" "$BACKUPS/$BACKUPNAME"
echo "$BACKUPNAME Backup Taken Successfully" > $MAILMESSAGE
else
echo "$BACKUPNAME Backup Failed" > $MAILMESSAGE
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
if [ ! -d "/usr/local/backupunited/backups/sync/$BACKUPNAME" ]; then
mkdir -p /usr/local/backupunited/backups/sync/$BACKUPNAME
fi
mkdir /tmp/$BACKUPNAME
mount -t cifs $BACKUPPATH /tmp/$BACKUPNAME -o username="$BACKUPUSR",password="$BACKUPPWD" && touch /tmp/$BACKUPNAME-mountok
if [ -e "/tmp/$BACKUPNAME-mountok" ]
then
rdiff-backup backup /tmp/$BACKUPNAME /usr/local/backupunited/backups/sync/$BACKUPNAME
BACKUPDATE=$JOCKER(date +%Y%m%d-%H%M)
echo "$BACKUPNAME Backup Taken Successfully" > $MAILMESSAGE
umount /tmp/$BACKUPNAME
rm -rf /tmp/$BACKUPNAME-mountok
else
echo "$BACKUPNAME Backup Failed" > $MAILMESSAGE
fi

bash $SCRIPTS/dailybackup.sh $BACKUPNAME

EOF

# WEEKLY BACKUP & MONTHLY BACKUP
echo "TODAY1=$JOCKER(date | cut -d "'" "'" -f1)" >> $BACKUP_SCRIPTS/$BACKUPNAME 
echo "TODAY2=$JOCKER(date | cut -d "'" "'" -f3)" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "if [ ""$JOCKER""TODAY1"" = ""Sun"" ]; then" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $SCRIPTS/weeklybackup.sh $BACKUPNAME" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "fi" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "if [ ""$JOCKER""TODAY2"" = ""01"" ]; then" >> $BACKUP_SCRIPTS/$BACKUPNAME
echo "bash $SCRIPTS/monthlybackup.sh $BACKUPNAME" >> $BACKUP_SCRIPTS/$BACKUPNAME
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

BOARDMSG="$BACKUPNAME Backup Job Successfully Added"
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
			systemctl daemon-reload
                        systemctl reset-failed
			BOARDMSG="$BACKUPNAME Backup Job Successfully Removed"
		else
			whiptail --msgbox "Backup Not Found!!" 10 60 3>&1 1>&2 2>&3
		fi
	fi
	pause
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
	pause
}

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

function backup_now(){
	chmod +x $BACKUP_SCRIPTS/*
	run-parts $BACKUP_SCRIPTS

	NUMRECIPIENT=$(cat "$MAILRECIPIENT" | wc -l)
	i=0
	while [ "$i" -le $NUMRECIPIENT ]; do
		RECIPIENT=$(ls -l | sed -n $i{p} "$MAILRECIPIENT")
		cat $MAILMESSAGE | mutt -s "Backup United Notification" $RECIPIENT
		i=$(( i + 1 ))
	done
	pause
}

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
	rm /tmp/dailybackups.txt
	rm /tmp/weeklybackups.txt
	rm /tmp/monthlybackups.txt
	rm /tmp/yearlybackups.txt
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
		"daily" "" OFF \
		"weekly" "" OFF \
		"monthly" "" OFF \
		"yearly" "" OFF \
		3>&1 1>&2 2>&3)
	
	BACKUPNAME=$(whiptail --title "Backup Name" --inputbox "Please Enter Backup Name" 10 60  3>&1 1>&2 2>&3)
	RBACKUPNAME=$(echo $BACKUPNAME | cut -d "-" -f1)
			
	tar -xvf $BACKUPS/$BACKUPDIR/$BACKUPNAME -C $RESTOREDIR/
	mv $RESTOREDIR/usr/local/taliaundo/backups/sync/* $RESTOREDIR/
	rm -r $RESTOREDIR/$RBACKUPNAME/rdiff-backup-data
	rm -r $RESTOREDIR/usr
	pause
}

function show_restoredir(){
	tput setaf 8
	echo "Restore Directory"
	echo "-----------------"
	tput sgr0
	tree -d $RESTOREDIR
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
