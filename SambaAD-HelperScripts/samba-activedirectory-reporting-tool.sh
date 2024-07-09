#!/bin/bash

SERVERNAME=$(cat /etc/hostname)
SERVERIP=$(ip r |grep link |grep src |cut -d'/' -f2 |cut -d'c' -f3 |cut -d' ' -f2)
DOMAINNAME=$(cat /etc/samba/smb.conf | grep "realm" | cut -d "=" -f2 | xargs)
SERVERROLE=$(cat /etc/samba/smb.conf | grep "server role" | cut -d "=" -f2 | xargs)
FORESTLEVEL=$(samba-tool domain level show | grep "Forest function level:" | cut -d ":" -f2 | xargs)
DOMAINLEVEL=$(samba-tool domain level show | grep "Domain function level:" | cut -d ":" -f2 | xargs)
LOWESTLEVEL=$(samba-tool domain level show | grep "Lowest function level of a DC:" | cut -d ":" -f2 | xargs)
