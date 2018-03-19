# Networking Random Stuff

### Setting Server Address (Server Machine Only)
```Powershell
Set-DnsClientServerAddress -Interfacealias <Interface Name here> -serveraddress <New IP Address Here>
```

### Connect iSCSI Target

*x is the address of the iSCSI Target Server*

```Powershell
Start-Service msiscsi

Set-Service msiscsi -StartupType Automatic

New-IscsiTargetPortal -TargetPortalAddress 10.60.140.x

Connect-IscsiTarget -NodeAddress ((Get-IscsiTarget).NodeAddress)

Get-IscsiSession | Register-IscsiSession
```
