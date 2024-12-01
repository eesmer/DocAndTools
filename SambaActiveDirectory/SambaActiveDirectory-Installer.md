## Samba Active Directory Installer

### About of Script
This script, 
- It installs the Samba package and its requirements.
- It installs and configures bind9 for DNS.
- It installs and configures the chrony service for the NTP service. <br>
<br>
Then, it performs the Domain Name Provisioning process according to the information it receives and configures the smb.conf file.
The machine on which it is run takes the PDC role and starts working as a DC for the established domain. <br>
<br>

As the `root`: <ins>perform operations as root user.!!</ins> <br>
It should be run in a Debian 11 or Debian 12 environment.

---

[Samba-Activedirectory-Installer.sh](https://raw.githubusercontent.com/eesmer/DocAndTools/main/SambaActiveDirectory/scripts/samba-activedirectory-installer.sh)

```
wget https://github.com/eesmer/DocAndTools/blob/main/SambaActiveDirectory/scripts/samba-activedirectory-installer.sh
```
```
bash  samba-activedirectory-installer.sh
```


