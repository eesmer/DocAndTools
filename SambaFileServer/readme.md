# Samba File Server - HelperScripts
---

### Install and Configiuration
- [Samba FileServer Installer and Create Share Directory](https://github.com/eesmer/DocAndTools/blob/main/SambaFileServer/scripts/samba-fileserver-installer.sh)
- [Recovering deleted files in a share with vfs recycle module](#vfs-recycle-module-configuration)
- [Full Audit share with vfs full_audit module](#vfs-full_audit-module-configuration)

---

<br>
<br>

### vfs recycle module configuration
This configuration, uses a recycle area for the share with the vfs recycle module configuration.
Deleted files in the share are stored in this area. <br>
```
/etc/samba/smb.conf
```
```
[ShareName]
   path = /mnt/shares
   read only = no
   browsable = yes
   vfs objects = recycle
   recycle:repository = .Trash/
   recycle:keeptree = yes
   recycle:versions = yes
   recycle:touch = yes
   recycle:exclude = *.tmp,*.bak,~$*
   recycle:exclude_dir = /tmp,/cache
   recycle:maxsize = 0
```

- **vfs objects = recycle**  : Enables the recycle module.
- **recycle:repository**     : Specifies the directory to which deleted files will be moved.
- **recycle:keeptree = yes** : Maintains the directory structure where deleted files are located.
- **recycle:versions = yes** : If multiple files with the same name are deleted, they are stored as different versions.
- **recycle:touch = yes**    : Updates the last access time after files are deleted.
- **recycle:exclude**        : Excludes certain file types from recycling (e.g. temporary files).
- **recycle:exclude_dir**    : Excludes certain directories.
- **recycle:maxsize**        : Specifies the maximum file size that can be moved to recycling. 0 means unlimited.

<br>

**note**                   : recycle:repository = **.Trash/%U** - You can create a separate subfolder for each user using **%U**

---

### vfs full_audit module configuration
```
[antivirus_share]
path = /srv/samba/antivirus
read only = no
writable = yes
browsable = yes
valid users = user1
vfs objects = full_audit
full_audit:success = mkdir rmdir write pwrite rename unlink
full_audit:failure = none
full_audit:prefix = %u|%I|%S
```
