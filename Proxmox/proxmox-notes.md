
## First things to do after installation
After installation, repo settings must be made first. <br>
There are two types of repos available: membership-based or community-maintained. <br>
<br>
If membership will not be used;<br>
The repositories are updated with the addresses below.

##### /etc/apt/sources.list.d/pve-enterprise.list
```
#deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

##### /etc/apt/sources.list.d/ceph.list
```
#deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise
deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription
```

<br>

```
apt update && apt upgrade
```

---
