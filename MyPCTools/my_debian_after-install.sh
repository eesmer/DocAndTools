#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

cat > /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware
deb-src https://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware
deb https://deb.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware
deb-src https://deb.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware
deb https://security.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware
deb-src https://security.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware
deb http://deb.debian.org/debian/ bookworm-backports main non-free contrib
deb-src http://deb.debian.org/debian/ bookworm-backports main non-free contrib
EOF

apt update

apt-get -y install $(apt search ^firmware- 2> /dev/null | grep ^firmware | grep -v micropython-dl | cut -d "/" -f 1)
apt-get -y install i3 xtrlock thunar zsh
apt-get -y install vim tmux openssh-server htop
apt-get -y install feathernotes atril pavucontrol unzip xfce4-terminal freerdp2-x11 vlc
apt-get -y install firefox-esr chromium
apt-get -y install libreoffice-writer libreoffice-calc
apt-get -y install git
apt-get -y install ack wget curl rsync dnsutils whois
apt-get -y install gnupg2
apt-get -y install openvpn
apt-get -y install encfs ntfs-3g
apt-get -y install python-pip
apt-get -y install python3 bpython3
apt-get -y install python3-pip --install-recommends
apt-get -y install software-properties-common
apt-get -y install lsb-release apt-transport-https
apt-get -y install net-tools

# Virtualbox Install
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | gpg --dearmor -o /usr/share/keyrings/virtualbox.gpg
echo "deb [signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" >> /etc/apt/sources.list

apt update
apt-get -y install "virtualbox-7.1"

#-------------------------------------
# LAB and TOOLS
#-------------------------------------
# LXC and Virtual Network
apt-get -y install --install-recommends lxc debootstrap bridge-utils

# Network1 and Bridge1 Virtual Network Configured
cat > /etc/network/interfaces.d/bridge1.cfg << EOF
auto network1
iface network1 inet manual
pre-up /sbin/ip link add network1 type dummy
up /sbin/ip link set network1 address 52:54:56:00:00:01

auto bridge1
iface bridge1 inet static
address 10.1.1.1
netmask 255.255.255.0
bridge_ports bridge1
bridge_stp off
bridge_fd 0
bridge_maxwait 0
EOF

ip a
brctl show
ifup network1
ifup bridge1

sleep 2

# Create Template Container (Debian Stable)
#lxc-create -n template-bullseye -t download -P /var/lib/lxc/ -- -d debian -r bullseye -a amd64
lxc-create -n template-bullseye -t debian -- -r bullseye
