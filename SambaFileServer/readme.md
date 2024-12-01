### Samba File Server - HelperScripts
---


- **Samba FileServer Installer** <br>
This script; Installs the Sambsa package, Defines a new share, Creates a User Account with access permission to the share <br>
Runs in a Debian environment
##### [Samba FileServer Installer and Create Share Directory](https://github.com/eesmer/DocAndTools/blob/main/SambaFileServer-HelperScripts/samba-fileserver-installer.sh)
---
- **Recovering deleted files in a share with vfs recycle module configuration** <br>
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
