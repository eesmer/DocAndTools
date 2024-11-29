
## Assigning specific command execution permissions to user accounts
#### Assign permission to use fdisk command to user account User 2 on ubuntuserver1 machine
#### ubuntu or debian
```
visudo -f /etc/sudoers.d/user2
```
user2 ubuntuserver1 = /sbin/fdisk

#### usage
```
sudo fdisk -l
```
<br>

#### rhel
```
visudo -f /etc/sudoers.d/user2
```
user2 ubuntuserver1 = /sbin/fdisk

#### usage
```
sudo fdisk -l
```
---
