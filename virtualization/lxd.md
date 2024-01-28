
## LXD install and configuration notes

#### vim /etc/apt/sources.list
```
deb http://ftp.de.debian.org/debian/ bookworm main contrib non-free-firmware
deb-src http://ftp.de.debian.org/debian/ bookworm main contrib non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb http://ftp.de.debian.org/debian/ bookworm-updates main contrib non-free-firmware
deb-src http://ftp.de.debian.org/debian/ bookworm-updates main contrib non-free-firmware
```

#### install
```
apt-get install vim tmux openssh-server htop
apt-get install lxd
```

---
