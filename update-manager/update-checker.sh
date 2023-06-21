#/bin/bash

#-----------------------------------------------------------------------------
# This script; detects the distribution and performs system and update checks.
# Update Date:2023-06-21
# ChangeLog:
# - It checks for system and security updates according to the distribution.
#-----------------------------------------------------------------------------

RDIR=/tmp

#---------------------
# DETERMINE DISTRO
#---------------------
cat /etc/*-release > $RDIR/distrocheck || cat /etc/issue > $RDIR/distrocheck
rm $RDIR/distrocheck

#---------------------
# UPDATE CHECK
#---------------------
SYSUPDATE_COUNT=0
SECUPDATE_COUNT=0
if [ "$REP" = "APT" ]; then
    # for System Update
    SYSUPDATE_COUNT=$(apt-get upgrade -s | grep ^Inst | wc -l)
    # for Security Update
    SECUPDATE_COUNT=$(apt-get upgrade -s | grep ^Inst | grep -i security | wc -l)
    IMMUPDATE_COUNT=$(bash /etc/update-motd.d/90-updates-available | grep "updates can be applied immediately." | cut -d " " -f1)
fi

if [ "$REP" = YUM ]; then
# for System Update
    echo N | yum update > $RDIR/updatecheck.txt 2>/dev/null
    INSTALLPACK_COUNT=$(cat $RDIR/updatecheck.txt | grep "Install" | grep "Package" | wc -l)
    UPGRADEPACK_COUNT=$(cat $RDIR/updatecheck.txt | grep "Upgrade" | grep "Package" | wc -l)
    TOTALDOWNLOAD=$(cat $RDIR/updatecheck.txt | grep "Total download size:" | cut -d ":" -f2 | xargs)
    if [ "$INSTALLPACK_COUNT" -gt 0 ] || [ "$UPGRADEPACK_COUNT" -gt -0 ]; then
        SYSUPDATE_COUNT=1
        INSTALLPACK=$(cat $RDIR/updatecheck.txt | grep "Install" | grep "Package")
        UPGRADEPACK=$(cat $RDIR/updatecheck.txt | grep "Upgrade" | grep "Package")
    fi

    # for Security Update
    yum updateinfo list installed \
        | grep -v "Updating Subscription" | grep -v "Last metadata expiration check:" \
        | grep -v "Loaded plugins:" | grep -v "Loading mirror speeds from cached hostfile" \
        | grep -v "base:" | grep -v "epel:" | grep -v "extras:" | grep -v "updates:" \
        | grep -v "You can use subscription-manager to assign subscriptions." \
        | grep -v "updateinfo list" \
        > $RDIR/updatecheck.txt
    sed -i '/^\s*$/d' $RDIR/updatecheck.txt

    SECUPDATE_COUNT=$(cat $RDIR/updatecheck.txt | wc -l)
    if [ "$SECUPDATE_COUNT" -gt 0 ]; then
        SECUPDATE_COUNT=1
    fi
    NEWPACKAGE=$(cat $RDIR/updatecheck.txt | grep "newpackage" | wc -l)
    ENHANCEMENT=$(cat $RDIR/updatecheck.txt | grep "enhancement" | wc -l)
    BUGFIX=$(cat $RDIR/updatecheck.txt | grep "bugfix" | wc -l)
    SECPACKAGE=$(cat $RDIR/updatecheck.txt | grep "/Sec." | wc -l)

    CRITICALPACKAGE=$(cat $RDIR/updatecheck.txt | grep "Critical/Sec." | wc -l)
    IMPORTANTPACKAGE=$(cat $RDIR/updatecheck.txt | grep "Important/Sec." | wc -l)
    MODERATEPACKAGE=$(cat $RDIR/updatecheck.txt | grep "Moderate/Sec." | wc -l)
    LOWPACKAGE=$(cat $RDIR/updatecheck.txt | grep "Low/Sec." | wc -l)
    #fi
fi

#---------------------
# OUTPUT MESSAGES
#---------------------
if [ "$SYSUPDATE_COUNT" -gt "0" ]; then
        SYSUPDATE_MSG="System Update Available"
else
        SYSUPDATE_MSG="No System update - System up to date"
fi
if [ "$SECUPDATE_COUNT" -gt "0" ]; then
        SECUPDATE_MSG="Security Update Available"
else
        SECUPDATE_MSG="No Security Update"
fi

tput setaf 9
echo "-------------------------------"
echo "SYSTEM UPDATE"
echo "-------------------------------"
tput sgr 0
printf "$SYSUPDATE_MSG\n"
echo -e

tput setaf 9
echo "-------------------------------"
echo "SECURITY UPDATE"
echo "-------------------------------"
tput sgr 0
printf "$SECUPDATE_MSG\n"
echo -e
