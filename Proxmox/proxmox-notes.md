
## First things to do after installation
After installation, repo settings must be made first. <br>
There are two types of repos available: membership-based or community-maintained.

##### /etc/apt/sources.list.d/pve-enterprise.list
```
#deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

```
vim /etc/apt/sources.list.d/ceph.list
```

---
