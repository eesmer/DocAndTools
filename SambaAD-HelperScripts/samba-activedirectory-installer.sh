#!/bin/bash

#-------------------------------------------------------------------
# This script has been tested in Debian environment.
# It is compatible with Debian.
#-------------------------------------------------------------------

# Color Codes
MAGENTA="tput setaf 1"
GREEN="tput setaf 2"
YELLOW="tput setaf 3"
DGREEN="tput setaf 4"
CYAN="tput setaf 6"
WHITE="tput setaf 7"
GRAY="tput setaf 8"
RED="tput setaf 9"
BLUE="tput setaf 12"
NOCOL="tput sgr0"
BOLD="tput bold"

whiptail --msgbox \
        ".:: Samba Active Directory Domain Controller Installer ::. \
        \n---------------------------------------------------------------- \
        \nThis program is distributed for the purpose of being useful. \
        \nThis program installs Samba Active Directory. \
        \nIt will ask you questions about the domain and it will install and will install it according to the information it receives. \
        \n\nWhen the installation is completed;\na Domain is created and this machine is configured as a Domain Controller. \
        \n---------------------------------------------------------------- \
        \n\nhttps://github.com/eesmer/SambaAD-HelperScripts \
        \nhttps://github.com/eesmer/sambadtui \
        \nhttps://github.com/eesmer/DebianDC" 20 90 45

CHECK_DISTRO() {
cat /etc/*-release /etc/issue > "/tmp/distrocheck"
if grep -qi "debian\|ubuntu" "/tmp/distrocheck"; then
REP=APT
elif grep -qi "centos\|rocky\|red hat" "/tmp/distrocheck"; then
REP=YUM
fi
rm /tmp/distrocheck
# Not support message
if [ ! "$REP" = "APT" ]; then
$RED
echo -e
echo "-------------------------------------------------------------------------------------"
echo -e "This script has been tested in Debian environment.\nIt is compatible with Debian. "
echo "-------------------------------------------------------------------------------------"
echo -e
$NOCOL
exit 1
fi
}

SAMBAAD_INSTALL() {
        HOSTNAME=$(whiptail --inputbox "Enter DC Machine Hostname" 8 39 --title "DC Hostname" 3>&1 1>&2 2>&3)
        ANSWER=$?
        if [ ! $ANSWER = 0 ]; then
                echo "User canceled"
		exit 1
        fi
        REALM=$(whiptail --inputbox "Enter Domain Name" 8 39 --title "DomainName" 3>&1 1>&2 2>&3)
	ANSWER=$?
	if [ ! $ANSWER = 0 ]; then
		echo "User canceled"
		exit 1
	fi
        PASSWORD=$(whiptail --passwordbox "Enter Administrator Password" 8 39 3>&1 1>&2 2>&3)
	ANSWER=$?
	if [ ! $ANSWER = 0 ]; then
		echo "User canceled"
		exit 1
	fi
	if [ -z "$HOSTNAME" ] || [ -z "$REALM" ] || [ -z "$PASSWORD" ]; then
		whiptail --msgbox "Please fill in all fields.." --title "SambaAD Install" --backtitle "Samba Active Directory Installation" 0 0 0
		SAMBAAD_INSTALL
	fi

	whiptail --yesno "Domain Name: $REALM\n Start Installation?" 0 0 0
	ANSWER=$?
	if [ ! $ANSWER = 0 ]; then
		echo "User canceled"
		exit 1
	fi

	SERVER_IP=$(ip r | grep link | grep src | cut -d '/' -f2 | cut -d'c' -f3 | cut -d ' ' -f2)
	DOMAIN=$(echo $REALM | cut -d "." -f1)
	sed -i "/127.0.1.1/ c 127.0.1.1 $HOSTNAME.$REALM $HOSTNAME" /etc/hosts
	hostnamectl set-hostname $HOSTNAME.$REALM
	
	export DEBIAN_FRONTEND=noninteractive
	apt-get -y update && apt-get -y upgrade && apt-get -y autoremove
	apt-get -y install bind9 bind9utils dnsutils
	apt-get -y install samba --install-recommends
	apt-get -y install winbind
	apt-get -y install krb5-config krb5-user
	
	systemctl stop smbd nmbd winbind
	systemctl disable smbd nmbd winbind
	systemctl mask smbd nmbd winbind

	apt-get -y install chrony ntpdate
	apt-get -y install dnsutils net-tools
	apt-get -y install openssh-server 
	#apt-get -y install ack expect krb5-user krb5-config
	#apt-get -y install curl wget
	
	#Domain Provision
	rm /etc/samba/smb.conf
	samba-tool domain provision --server-role=dc --use-rfc2307 --realm="$REALM" --domain="$DOMAIN" --adminpass="$PASSWORD"
	
	#Log Config
	sed -i '/server services =/a log level = 4' /etc/samba/smb.conf
	sed -i '/log level =/a log file = /var/log/samba/$REALM.log' /etc/samba/smb.conf
	sed -i '/log file =/a debug timestamp = yes' /etc/samba/smb.conf
	
	#Time/Sync Config
	ntpdate -bu pool.ntp.org
	echo "allow 0.0.0.0/0" >> /etc/chrony/chrony.conf
	echo "ntpsigndsocket  /var/lib/samba/ntp_signd" >> /etc/chrony/chrony.conf
	chown root:_chrony /var/lib/samba/ntp_signd/
	chmod 750 /var/lib/samba/ntp_signd/
	systemctl restart chrony
	systemctl enable chrony
	#sed -i "s/\$IP/$SERVER_IP/" /var/lib/samba/private/dns_update_list
	
	rm /etc/krb5.conf
	cp /var/lib/samba/private/krb5.conf /etc/
	echo "search $REALM" > /etc/resolv.conf
	echo "nameserver 127.0.0.1" >> /etc/resolv.conf

# named.conf.options
cat > /etc/bind/named.conf.options << EOF
options {
directory "/var/cache/bind";

forwarders {
8.8.8.8;
};

allow-query {  any;};
dnssec-validation no;

auth-nxdomain no; #RFC1035
listen-on-v6 { any; };

tkey-gssapi-keytab "/var/lib/samba/bind-dns/dns.keytab";
minimal-responses yes;
};
EOF

# named.conf.local
cat > /etc/bind/named.conf.local << EOF
dlz "$REALM" {
database "dlopen /usr/lib/x86_64-linux-gnu/samba/bind9/dlz_bind9_10.so";
};
EOF

cat > /etc/default/bind << EOF
RESOLVCONF=no
OPTIONS="-4 -u bind"
EOF
chmod 644 /etc/default/bind9

sed -i 's/dns forwarder = .*/server services = -dns/' /etc/samba/smb.conf
mkdir -p /var/lib/samba/bind-dns
mkdir -p /var/lib/samba/bind-dns/dns

samba_upgradedns --dns-backend=BIND9_DLZ

systemctl unmask samba-ad-dc.service
systemctl enable samba-ad-dc.service
systemctl restart samba-ad-dc
systemctl restart bind9
}

CHECK_DISTRO
SAMBAAD_INSTALL
