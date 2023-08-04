## BackupUnited

Backup United aims to make successful backups.<br>
Provides TUI in single script file for this.

---

## Features
- Takes backup from SMB access.
- It keeps syncing, .tar file and diffs of each defined backup in separate directories.
- Sends notification of backup jobs. (email)

---

### Usage of BackupUnited Script
```bash
# apt-get -y install rsync rdiff-backup ssmtp mutt
# apt-get -y install cifs-utils smbclient
# apt-get -y install tree ack
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

#### rsync notes
https://rsync.samba.org/tech_report/ <br>
https://rsync.samba.org/how-rsync-works.html

<br>

rsync is a tool for copying files from remote and local environments.<br>
After copying once, it can work with update behavior and creates synchronized directories.<br>
rsync performs file sync (sync) by running client-server and sender-receiver operations and roles.<br>
<br>
**client:** Represents files or directories to be synced.<br>
**server:** It is the party that initiates the remote shell or network socket connection and manages the copy process.<br>
**sender:** The process that accesses the source files or directories for the sync-copy operation.<br>
**receiver:** The process that receives the files to be synchronized and writes them to disk.<br>
**remote shell:** It is the process that provides connection between Client and Server.<br>
<br>
**When the copying process begins;**<br>
First, the file list is extracted. In this file list; Ownership, file/directory mode, permission, size information are also included.<br>
For the Backup/Synchronization process, a double-end in the role of sender and receiver, and an environment in which rsync commands can run on the remote shell connection is created.<br>
Copying between end machines taking the roles of Sender and Receiver is subject to certain checks.<br>
With these checks;<br>
File List creation and file creation are managed according to the list difference between Sender and Receiver or the parameters used in the rsync command.<br>
**Example:** Sender receives File List.<br>
In the rsync command, if the --delete parameter is used, the sender first detects local files that are not on their side and deletes them from the receiver.<br>
When copying is done after this process, both ends are synchronized.<br>
<br>
The receiver reads for each file from the sender data.<br>
According to this; it does file/directory creation-writing operations in its local environment.<br>
A copy-operated sync operation consists of the Directory List created before the copy starts, and the contents of this Directory List in the Sender and Recipient locales.<br>
In addition to these controls; The parameters in the rsync command also determine how the sync operation is completed.<br>
In rsync operation, it is the most processing role as it compares the File List in the Sender hand with the files in the Directory Tree on the Receiver side.<br>
The Receiver becomes the party that writes to its locale based on the data list it receives from the Sender.<br>
<br>
Many copy operations can be more controlled and robust than rsync.<br>
Because it can control the network traffic situation and the factors that will affect the copying process during copying.<br>
However, these controls negatively affect the performance of the process.<br>
The rsync process focuses on copy performance with Directory Listing and target-source comparison instead of these checks.<br>
It works with performance and problem-free in a smooth network traffic environment.<br>
<br>
#### rdiff notes

