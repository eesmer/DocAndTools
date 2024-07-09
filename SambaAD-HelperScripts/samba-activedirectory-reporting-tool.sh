#!/bin/bash

SERVERNAME=$(cat /etc/hostname)
SERVERIP=$(ip r |grep link |grep src |cut -d'/' -f2 |cut -d'c' -f3 |cut -d' ' -f2)
DOMAINNAME=$(cat /etc/samba/smb.conf | grep "realm" | cut -d "=" -f2 | xargs)
SERVERROLE=$(cat /etc/samba/smb.conf | grep "server role" | cut -d "=" -f2 | xargs)
FORESTLEVEL=$(samba-tool domain level show | grep "Forest function level:" | cut -d ":" -f2 | xargs)
DOMAINLEVEL=$(samba-tool domain level show | grep "Domain function level:" | cut -d ":" -f2 | xargs)
LOWESTLEVEL=$(samba-tool domain level show | grep "Lowest function level of a DC:" | cut -d ":" -f2 | xargs)
DBCHECKRESULT=$(samba-tool dbcheck | grep "Checked")
PASSCOMPLEX=$(samba-tool domain passwordsettings show | grep "Password complexity:" | cut -d ":" -f2 | xargs)
PASSHISTORY=$(samba-tool domain passwordsettings show | grep "Password history length:" | cut -d ":" -f2 | xargs)
MINPASSLENGTH=$(samba-tool domain passwordsettings show | grep "Minimum password length:" | cut -d ":" -f2 | xargs)
MINPASSAGE=$(samba-tool domain passwordsettings show | grep "Minimum password age (days):" | cut -d ":" -f2 | xargs)
MAXPASSAGE=$(samba-tool domain passwordsettings show | grep "Maximum password age (days):" | cut -d ":" -f2 | xargs)

whiptail --msgbox \
".:: Samba Active Directory Domain Controller Server Report ::. \
\n---------------------------------------------------------------- \
\nHostName                : $SERVERNAME \
\nServer IP Addr.         : $SERVERIP \
\n\nDomain Name           : $DOMAINNAME \
\nServer Role             : $SERVERROLE \
\nForest Level            : $FORESTLEVEL \
\nDomain Level            : $DOMAINLEVEL \
\nLowest Level            : $LOWESTLEVEL \
\nDB Check Result         : $DBCHECKRESULT \
\nPassword Complexity     : $PASSCOMPLEX \
\nPassword History        : $PASSHISTORY \
\nMinimum Password Length : $MINPASSLENGTH \
\nMinimum Password Age    : $MINPASSAGE \
\nMaximum Password Age    : $MAXPASSAGE \
\n\n---------------------------------------------------------------- \
\nhttps://github.com/eesmer/SambaAD-HelperScripts \
\nhttps://github.com/eesmer/sambadtui \
\nhttps://github.com/eesmer/DebianDC" 0 0 0
#20 90 45

exit 1

samba-tool domain level show
#samba-tool domain info $SERVER

samba-tool processes
samba-tool dbcheck
samba-tool domain passwordsettings show
samba-tool ou listobjects OU="Domain Controllers"

samba-tool fsmo show
samba-tool fsmo show |grep "DomainDnsZonesMasterRole" |cut -d "," -f2
- SchemaMasterRole
- InfrastructureMasterRole
- RidAllocationMasterRole
- PdcEmulationMasterRole
- DomainNamingMasterRole
- DomainDnsZonesMasterRole
- ForestDnsZonesMasterRole
