# Active Directory Commands

## Distinguished Name

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
| - | - | -|
| CN | Common Name |
| OU | Organizational Unit |
| DC | Domain Component |
| O | Orgnization Name |
| STREET | Street Address |
| L | Locality Name |
| ST | State or Province Name |
| C | Country Name |
| UID | User ID |

## Powershell

#### Install Domain Controller

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

`<$true|$false>` Can be either $true or $false.
`<database path>` The desired file location of the AD Database.
`<domain mode>` Domain functional level, see [Domain Mode](#Domain-Mode) table for usable values.
`<forest mode>` As with `<domain mode>`, specifies functional level of the Forest. See [Domain Mode](#Domain-Mode) table for usable values.
`<domain name>` Desired name for the domain being created.
`<netbios name>` Shortened version of the `<domain name>`.
`<log path>` Desired file location of the AD log path.
`<sysvol path>` Desired file location of the AD sysvol path.


#### Uninstall Domain Controller

```Powershell
Uninstall-ADDSDomainController `
-LastDomainController `
-RemoveApplicationPartitions `
-Force
```

## Command Line

#### Install Domain Controller

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

#### Uninstall Domain Controller

```bash
# n/a at this time
```

## Group and User Management

#### Redirect Add-Computer to OU

```
redircmp "<dn>"
```

__*Variables*__

- `<dn>` is the Distinguished Name of container to put computers joining the domain into.

__*E.G.*__

```
redircmp "OU=Servers,DC=adatum,DC=com"
```

#### Adding OU

##### Command Prompt

```
dsadd ou "ou=<name>,<dn>"
```

__*Variables*__

- `ou=<name>` is the name of the OU being created.
- `<dn>` is the Distinguished Name of where the OU is to be placed.

__*E.G.*__

```
dsadd ou "ou=shipping,dc=adatum,dc=com"
```

##### Powershell

```Powershell
New-ADOrganizationalUnit -Name <name> -Path <dn>
```

__*Variables*__

- `<name>` Name of the new OU.
- `<dn>` Distinguished Name location to store new OU.

__*E.G.*__

```Powershell
New-ADOrganizationalUnit -Name "Cleaners" -Path "DC=Adatum,DC=com"
```

#### Adding Group

##### Command Prompt

```
dsadd group "cn=<name>,<dn>"
```

__*Variables*__

- `cn=<name>` is the name of the group being created.
- `<dn>` is the Distinguished Name of where the group is to be placed.

__*E.G.*__

```
dsadd group cn=accounts,ou=accounts,dc=adatum,dc=com
```

#### Adding User

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

__*E.G.*__

```
dsadd "cn=Michael Russells,ou=Managers,dc=adatum,dc=com" -disabled no -pwd Pa$$w0rd -memberof "cn=Managers,dc=adatum,dc=com" -samid Michael -upn Michael@adatum.com -fn Michael -ln Russells -display "Michael Russells" -pwdneverexpires yes
```
