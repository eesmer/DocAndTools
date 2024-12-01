## Samba Active Directory Hardening

### About of Script
This script, disables or removes non-essential Active Directory settings in Samba configuration. <br>
Contains AD related and best practices. <br>

**Please take a backup and trying do not apply without understanding the configuration in each line.**

---

[Samba-ActiveDirectory-Hardening.sh](https://github.com/eesmer/DocAndTools/blob/main/SambaActiveDirectory/scripts/samba-activedirectory-hardening.sh)

---

```
wget https://raw.githubusercontent.com/eesmer/SambaAD-HelperScripts/master/scripts/samba-activedirectory-hardening.sh
```
```
bash  samba-activedirectory-hardening.sh
```
---

```
# Disable printer
sed -i '/global/a\ \tprinting = bsd' /etc/samba/smb.conf
sed -i '/global/a\ \tdisable spoolss = yes' /etc/samba/smb.conf
sed -i '/global/a\ \tload printers = no' /etc/samba/smb.conf
sed -i '/global/a\ \tprintcap name = /dev/null' /etc/samba/smb.conf

# Turn off NTLMv1
sed -i '/global/a\ \tntlm auth = mschapv2-and-ntlmv2-only' /etc/samba/smb.conf
```
