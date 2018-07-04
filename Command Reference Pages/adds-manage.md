# Active Directory Commands

## Powershell

##### Install Domain Controller

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

##### Uninstall Domain Controller

```Powershell
Uninstall-ADDSDomainController `
-LastDomainController `
-RemoveApplicationPartitions `
-Force
```

## Command Line

##### Install Domain Controller

```bash
[DCInstall]
InstallDNS=<yes|no>
NewDomain=
NewDomainDNSName=<domain name>
SiteName=Default-First-Site-Name
ReplicaOrNewDomain=<domain|replica>
ForestLevel=<forest level>
DomainLevel=<domain level>
DatabasePath=<database path>
LogPath=<log path>
RebootOnCompletion=<yes|no>
SYSVOLPath=<sysvol path>
SafeModeAdminPassword=<safemod pass>
```

##### Uninstall Domain Controller

```bash
#n/a at this time
```
