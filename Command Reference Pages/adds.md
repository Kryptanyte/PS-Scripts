# Active Directory Management
---
## Navigation

##### Terminology

- [Distinguished Name](#distinguished-name)
- [Domain Mode](#domain-mode)

##### Service

- [Install Active Directory](#install-domain-controller-1)
- [Uninstall Active Directory](#uninstall-domain-controller)
- [Install Domain Controller](#install-domain-controller)

##### Group and User Management

- [Get all Computers in OU](#listing-all-computers-in-ou)
- [Remove AD-DS Password Complexity](#removing-default-password-complexity-requirements)
- [Redirect New Computers to OU](#redirect-add-computer-to-ou)
- [Create New OU](#adding-orgnizational-unit)
- [Create New Group](#adding-group)
- [Create New User](#adding-user)
- [Add User to Group](#add-user-to-group)

##### Database Maintenance

- [Database Defragmentation](#database-defragmentation)
- [Create Snapshop](#create-snapshot)
- [Mounting and Navigating Snapshot](#mounting-and-navigating-snapshot)
---
## Terminology

### Distinguished Name

The Distinguished Name, or DN, is the full path of an object within the domain.

For example, the user 'Gavin Davies' is located in an Organizational Unit (OU) called 'Shipping' in the root of the domain. Therefor the DN would be as follows:

```
"cn=Gavin Davies,ou=Shipping,dc=adatum,dc=com"
```

Each object of the domain must be declared individually within the DN. E.G. if the domain name was tor.adatum.com the 'tor' section must be added to the DN

```
"cn=Gavin Davies,ou=Shipping,dc=tor,dc=adatum,dc=com"
```

| DN Notation | Full Name |
| - | - |
| CN | Common Name |
| OU | Organizational Unit |
| DC | Domain Component |
| O | Orgnization Name |
| STREET | Street Address |
| L | Locality Name |
| ST | State or Province Name |
| C | Country Name |
| UID | User ID |

### Domain Mode

Functional Levels of domain and forests.

| Mode Name | Mode ID | Windows Version |
| - | - | - |
| Win2003 | 2 | Windows Server 2003 |
| Win2008 | 3 | Windows Server 2008 |
| Win2008R2 | 4 | Windows Server 2008 R2 |
| Win2012 | 5 | Windows Server 2012 |
| Win2012R2 | 6 | Windows Server 2012 R2 |
| WinThreshold | 7 | Windows Server 2016 |

## Service

### Install Active Directory

##### Powershell

```Powershell
Install-WindowsFeature ad-domain-services `
-IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
-CreateDnsDelegation:<$true|$false> `
-DatabasePath "<database path>" `
-DomainMode "<domain mode>" `
-DomainName <domain name> `
-DomainNetbiosName <netbios name> `
-ForestMode "<forest mode>" `
-InstallDns:<$true|$false> `
-LogPath "<log path>" `
-NoRebootOnCompletion:<$true|$false> `
-SysvolPath "<sysvol path>" `
-Force:<$true|$false>
```

__*Variables*__

- `<$true|$false>` Can be either $true or $false.
- `<database path>` The desired file location of the AD Database.
- `<domain mode>` Domain functional level, see [Domain Mode](#domain-mode) table for usable values.
- `<forest mode>` As with `<domain mode>`, specifies functional level of the Forest. See [Domain Mode](#domain-mode) table for usable values.
- `<domain name>` Desired name for the domain being created.
- `<netbios name>` Shortened version of the `<domain name>`.
- `<log path>` Desired file location of the AD log path.
- `<sysvol path>` Desired file location of the AD sysvol path.

### Install Domain Controller

##### Command Line

```bash
[DCInstall]
InstallDNS=<yes|no>
NewDomain=<tree|child|forest>
NewDomainDNSName=<domain name>
SiteName=Default-First-Site-Name
ReplicaOrNewDomain=<domain|readonlyreplica|replica>
ForestLevel=<forest mode>
DomainLevel=<domain mode>
DatabasePath=<database path>
LogPath=<log path>
RebootOnCompletion=<yes|no>
SYSVOLPath=<sysvol path>
SafeModeAdminPassword=<safemode pass>
```

__*Variables*__

- `<yes|no>` Can be either yes or no.
- `<tree|child|forest>` Function level of the new domain. `tree` indicates domain is root of a new tree, `child` indicates domain is a child of another domain, `forest` indicates domain is first domain in a new forest.
- `<domain name>` Desired name for the domain being created.
- `<domain|readonlyreplica|replica>` Type of new domain controller. `domain` indicates this server is the first domain controller of a new domain, `readonlyreplica` indicates this server is to be a Read Only Domain Controller, `replica` indicates this server is a secondary domain controller.
- `<forest mode>` As with `<domain mode>`, specifies functional level of the Forest (As number). See [Domain Mode](#Domain-Mode) table for usable values.
- `<domain mode>` Domain functional level (As number). See [Domain Mode](#Domain-Mode) table for usable values.
- `<database path>` The desired file location of the AD Database.
- `<log path>` Desired file location of the AD log path.
- `<sysvol path>` Desired file location of the AD sysvol path.
- `<safemode pass>` Safemode password for database recovery.

### Uninstall Domain Controller

##### Powershell

```Powershell
Uninstall-ADDSDomainController `
-LastDomainController `
-RemoveApplicationPartitions `
-Force
```

### Install Domain Controller

##### Powershell

```Powershell
Install-ADDSDomainController `
-CreateDnsDelegation:<$true|$false> `
-DatabasePath "<database path>" `
-DomainName <domain name> `
-InstallDns:<$true|$false> `
-LogPath "<log path>" `
-NoRebootOnCompletion:<$true|$false> `
-SysvolPath "<sysvol path>" `
-Force:<$true|$false>
```

__*Variables*__

- `<$true|$false>` Can be either $true or $false.
- `<database path>` The desired file location of the AD Database.
- `<domain name>` Desired name for the domain being created.
- `<log path>` Desired file location of the AD log path.
- `<sysvol path>` Desired file location of the AD sysvol path.

---

## Group and User Management

### Listing all Computers in OU

#### Powershell

```powershell
Get-ADComputer -SearchBase "OU=Computers, DC=contosso,DC=com" -Filter * | Select Name | Format-Table
```

Generally speaking in a production environment there would be multiple OU paths, for example:

```powershell
Get-ADComputer -SearchBase "OU=Laptops,OU=Windows 10,OU=Computers, DC=contosso,DC=com" -Filter * | Select Name | Format-Table
```

### Removing Default Password Complexity Requirements

#### Powershell

```powershell
# Script Sourced from: 
# https://www.avoiderrors.com/remove-password-complexity-windows-server-2016/
#
# Export the system security setting database to .cfg file
secedit /export /cfg c:\secpol.cfg

# Get system security .cfg file, replace PasswordComplexity and save file
(gc C:\secpol.cfg).replace(“PasswordComplexity = 1”, “PasswordComplexity = 0”) | Out-File C:\secpol.cfg

# Load the .cfg file back into windows system security database
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY

# Remove the .cfg file 
rm -force c:\secpol.cfg -confirm:$false
```

### Redirect Add-Computer to OU

##### Command Line

```
redircmp "<dn>"
```

__*Variables*__

- `<dn>` is the Distinguished Name of container to put computers joining the domain into.

__*Example*__

```
redircmp "OU=Servers,DC=adatum,DC=com"
```

### Adding Orgnizational Unit

##### Command Prompt

```
dsadd ou "ou=<name>,<dn>"
```

__*Variables*__

- `ou=<name>` is the name of the OU being created.
- `<dn>` is the Distinguished Name of where the OU is to be placed.

__*Example*__

```
dsadd ou "ou=shipping,dc=adatum,dc=com"
```

##### Powershell

```Powershell
New-ADOrganizationalUnit -Name <name> -Path <dn> -ProtectedFromAccidentalDeletion <$true|$false>
```

__*Variables*__

- `<name>` Name of the new OU.
- `<dn>` Distinguished Name location to store new OU.
- `<$true|$false>` Can be either $true or $false.

__*Example*__

```Powershell
New-ADOrganizationalUnit -Name "Cleaners" -Path "DC=Adatum,DC=com"
```

### Adding Group

##### Command Prompt

```
dsadd group "cn=<name>,<dn>"
```

__*Variables*__

- `cn=<name>` is the name of the group being created.
- `<dn>` is the Distinguished Name of where the group is to be placed.

__*Example*__

```
dsadd group cn=accounts,ou=accounts,dc=adatum,dc=com
```

##### Powershell

```Powershell
New-ADGroup <name> -Path <dn> -GroupScope <group scope> -GroupCategory <group category>
```

__*Variables*__

- `<name>` is the name of the group being created.
- `<dn>` is the Distinguished Name of where the group is to be placed.
- `<group scope>` is the scope of the group within the domain. Can be `DomainLocal`, `Global` or `Universal`.
- `<group category>` is the category of the group. Can be `Security` or `Distribution`.

__*Example*__

```Powershell
New-ADGroup accounts -Path "ou=accounts,dc=adatum,dc=com" -GroupScope Global -GroupCategory Security
```

### Adding User

##### Command Prompt

```
dsadd "cn=<name>,<dn>" -disabled <yes|no> -pwd <password> -memberof <group dn> -samid <sam id> -upn <upn> -fn <first name> -ln <last name> -display <display name> -pwdneverexpires <yes|no>
```

__*Variables*__

- `cn=<name>` is the name of the user being created.
- `<dn>` is the Distinguished Name of where the user is to be placed.
- `<yes|no>` Can be either yes or no.
- `<password>` Desired password for user. Recommended that user changes password.
- `<group dn>` Distinguished Name of Group/s that the user should be added to.
- `<sam id>` Sam ID of the user. (logon using: `<domain>\<user>`)
- `<upn>` User Principal Name of the user. (logon using: `<user>@<domain>`)
- `<first name>` First name of the user.
- `<last name>` Last name of the user.
- `<display name>` Display name of the user.

__*Example*__

```
dsadd "cn=Michael Russells,ou=Managers,dc=adatum,dc=com" -disabled no -pwd Pa$$w0rd -memberof "cn=Managers,dc=adatum,dc=com" -samid Michael -upn Michael@adatum.com -fn Michael -ln Russells -display "Michael Russells" -pwdneverexpires yes
```

##### Powershell

```Powershell
New-ADUser -Name "<name>" -GivenName <first name> -Surname <last name> -SamAccountName <sam id> -UserPrincipalName <upn> -path "<dn>" -AccountPassword (ConvertTo-SecureString "<password>" -AsPlainText) -Enabled <$true|$false>
```

__*Variables*__

- `<name>` is the name of the user being created.
- `<first name>` First name of the user.
- `<last name>` Last name of the user.
- `<sam id>` Sam ID of the user. (logon using: `<domain>\<user>`)
- `<upn>` User Principal Name of the user. (logon using: `<user>@<domain>`)
- `<dn>` is the Distinguished Name of where the user is to be placed.
- `<password>` Desired password for user. Recommended that user changes password.
- `<$true|$false>` Can be either `$true` or `$false`

__*Example*__

```Powershell
New-ADUser -Name "Michael Russells" -GivenName Michael -Surname Russells -SamAccountName Michael -UserPrincipalName Michael@adatum.com -Path "ou=Managers,dc=adatum,dc=com" -AccountPassword (ConvertTo-SecureString "Pa$$w0rd" -AsPlainText) -Enabled $true
```

### Add User to Group

##### Powershell

```Powershell
Add-ADGroupMember <group> <user>
```

__*Variables*__

- `<group>` Group name to add user to.
- `<user>` Name of user. Can be a Distinguished Name, GUID, Security Identifier or SAM Account Name.

__*Example*__

```Powershell
Add-ADGroupMember Managers Michael
```
---
## Database Maintenance

### Database Defragmentation

**The following process is to be performed in an elevated (Administrative) command prompt**

*Stop the AD DS Service before defragmentation*

```
net stop ntds
```

*Open __ntdsutil__ and activate the NTDS instance*

```
ntdsutil

activate instance ntds
```

*Enter the __files__ shell*

```
files
```

*Run the defragmentation of the database. `{location}` is the output location for the defragmented database*

```
compact to {location}
```

__*Example*__

```
compact to C:\Compacted
```

*Verify the __integrity__ of the database*

```
integrity
```

*Quit out of the ntdsutil*

```
quit

quit
```

*__copy__ the defragmented database to the AD DS directory and remove the __.log__ files. {adds location} is the directory of the active directory database*

```
copy "{location}\ntds.dit" "{adds location}\ntds.dit"

del "{adds location}\*.log"
```

__*Example*__

```
copy "C:\Compacted\ntds.dit" "C:\Windows\NTDS\ntds.dit"

del "C:\Windows\NTDS\*.log"
```

*Restart the ADDS Service*

```
net start ntds
```

##### *Optional*
*Delete the folder that was created by the Defragmentation Process*

```
del {location}
```

__*Example*__

```
del C:\Compacted
```

### Create Snapshot

*Requires Elevated Command Prompt*

```
ntdsutil

activate instance ntds

snapshot

create
```

### Mounting and Navigating Snapshot

*Requires Elevated Command Prompt*

```Powershell
ntdsutil

snapshot

list all

# {guid} will be output from list all

mount {guid}

# {path} will be output from mount

quit

quit

dsamain -dbpath {path}\windows\ntds\ntds.dit -ldapport 50000
```

*Open ADUC*

*Right click on Active __Directory Users and Computers__ within the directory tree on the left and select __Change Domain Controller__*

*Double click on __<Type a Directory Server name:[port] here>__ and type in the domain controller followed by :50000*

```Powershell
# ctrl+c to cancel the dsamain

ntdsutil

activate instance ntds

quit

snapshot

unmount {guid}
```

### Delete Snapshot

```
ntdsutil

activate instance ntds

snapshot

list all

# {guid} will be output from list all

delete {guid}

quit

quit
```
