
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

#### lxd init
```
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: default
Name of the storage backend to use (btrfs, dir, lvm, zfs) [default=zfs]: zfs #requires zfs or btrfs to be installed
Create a new ZFS pool? (yes/no) [default=yes]: yes                                
Would you like to use an existing block device? (yes/no) [default=no]: yes                         
Path to the existing block device: /dev/disk/by-id/scsi-0DO_Volume_volume-fra1-01
```

#### managament
```
lxc storage list
lxc network show lxdbr0
lxc image list images:
lxc image list images: | grep trixie
```
```
lxc launch images:debian/trixie/amd64 template1
lxc launch images:debian/12/amd64 webserver
lxc list
lxc list --columns ns4
lxc info template1
```
```
lxc exec template1 bash
```



---
