## BackupUnited

Backup United aims to make successful backups.<br>
Provides TUI in single script file for this.

---

## Features
- Takes backup from SMB access.
- It keeps syncing, .tar file and diffs of each defined backup in separate directories.
- The directory to be backed up;
    - syncs with **rsync**
    - Compresses with **tar**
    - It keeps incremental diffs with **rdiff-backup**
- Sends notification of backup jobs. (email)

---

### Usage of BackupUnited Script
```bash
# apt-get -y install rsync rdiff-backup
# apt-get -y install cifs-utils smbclient
# apt-get -y install tree ack
# apt-get -y install whiptail
# apt-get -y install ssmtp mutt
# wget https://raw.githubusercontent.com/eesmer/DocAndTools/master/BackupUnited/backupunited.sh
# bash backupunited
```
---

### Questions, Answers and Study Notes
#### - What is sync / Backup vs Sync <br>
First, let's define the backup process;<br>
**Backup:** It is the duplication of files from one area to another (disk, share, cloud).<br>
In general, the purpose is; The exact copy of the files is kept in a different environment and taken from this environment when necessary.<br>
**Sync:** Sync means synchronized and it is keeping the data in one area like a backup in another area.<br>
Aim; It is the absence of usage-related differences such as file version, current change status, etc. of the data in the 2 environments.<br>
That is, the files in the backup or synced area are up-to-date with the files in the source area.<br>
According to this; By synchronizing, deleting or updating files in 2 areas, the environments become the same.<br>
<br>
Backup or sync usage should be determined according to need.<br>
If you want to synchronize at least 2 fields and do not want to keep the deleted data because it is unnecessary, you can use sync.<br>
If you want to keep necessary or unnecessary deleted files, you should use backup.<br>
<br>
With the backup process, you copy the same files again and again and you guarantee that each copied file is kept.<br>
With Sync, the source and destination fields are only synchronized. File storage is not the purpose of the sync operation.<br>

#### rdiff-backup
https://rdiff-backup.net
#### rsync
https://rsync.samba.org/tech_report <br>
https://rsync.samba.org/how-rsync-works.html
#### tar
https://www.gnu.org/software/tar
