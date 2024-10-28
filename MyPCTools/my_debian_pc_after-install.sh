#!/bin/bash

#----------------------------------------------------------------
# The machine is installed with Debian netinstall iso.
# On the tasksel screen, only system-utilities is selected.
# When the installation is complete, this script is run.
#----------------------------------------------------------------

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

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | gpg --dearmor -o /usr/share/keyrings/virtualbox.gpg
echo "deb [signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" >> /etc/apt/sources.list

apt-get -y install $(apt search ^firmware- 2> /dev/null | grep ^firmware | grep -v micropython-dl | cut -d "/" -f 1)
apt-get -y install i3 xtrlock thunar zsh
apt-get -y install vim tmux openssh-server htop
apt-get -y install feathernotes atril pavucontrol unzip xfce4-terminal freerdp2-x11 vlc
apt-get -y install firefox-esr chromium
apt-get -y install libreoffice-writer libreoffice-calc
apt-get -y install git
apt-get -y install ack ack-grep wget curl rsync dnsutils whois
apt-get -y install gnupg2
apt-get -y install openvpn
apt-get -y install encfs ntfs-3g
apt-get -y install python-pip
apt-get -y install python3 bpython3
apt-get -y install python3-pip --install-recommends
apt-get -y install software-properties-common
apt-get -y install lsb-release wget apt-transport-https
