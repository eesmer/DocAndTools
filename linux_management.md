
## Assigning specific command execution permissions to user accounts
#### Assign permission to use fdisk command to user account User 2 on ubuntuserver1 machine
```
visudo -f /etc/sudoers.d/user
```
user2 ubuntuserver1 = /sbin/fdisk

#### usage
```
sudo fdisk -l
```

---
