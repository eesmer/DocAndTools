## Samba Active Directory Additional Domain Controller Joiner

### About of Script

This script, <br> adds an additional domain controller to a Samba AD environment set up with the [Samba Active Directory Installer](https://github.com/eesmer/SambaAD-HelperScripts/blob/master/pages/SambaActiveDirectory-Installer.md) script.

You will need to know the password for the Administrator user account to complete the installation.

With the ADC installed;
It becomes a 2nd DC machine that runs simultaneously in the domain environment and acts as a DC for all components in the Active Directory environment (dns records, ad objects, database, fsmo roles, etc.).

---

[Samba-ActiveDirectory-ADC-Joiner.sh](https://raw.githubusercontent.com/eesmer/SambaAD-HelperScripts/master/scripts/samba-activedirectory-additional-dc-joiner.sh)

---

```
wget https://raw.githubusercontent.com/eesmer/SambaAD-HelperScripts/master/scripts/samba-activedirectory-additional-dc-joiner.sh
```
```
bash  samba-activedirectory-additional-dc-joiner.sh
```
