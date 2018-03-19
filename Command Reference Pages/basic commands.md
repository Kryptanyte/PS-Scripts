# Basic Commands
### Adding a machine to the Domain
```PowerShell
Add-Computer -DomainName <domain name> -DomainCredential (Get-Credential) -NewName <name>

Add-Computer -DomainName adatum -DomainCredential (Get-Credential) -NewName WS01
```


### Setting Server Address (Server Machine Only)
```Powershell
Set-DnsClientServerAddress -Interfacealias <Interface Name here> -serveraddress <New IP Address Here>
```

### New NAT Switch

(Replace Your Router With This, Also Don't Pipe all this, just an example)

*x is your assigned subnet*

```Powershell
New-VMSwitch -SwitchName "NAT" -SwitchType Internal 

New-NetIpAddress -IPAddress 10.60.x.1 -PrefixLength 24 -InterfaceIndex ((Get-NetAdapter *NAT*).IfIndex) 

New-NetNat -Name Nat -InternalIPInterfaceAddressPrefix "10.60.x.0/24"
```
### Setting Network Adapters On Multiple Machines

(If you have multiple machines on one router, this is handy)

```Powershell
Get-VM -Name "Project*" | Connect-NMNetworkAdapter -Switchname Nat 
```

### Remove Computer From Non-Existant Domain

```Powershell
netdom remove <computer name> /Domain:<domain name> /UserD:<admin name> /PasswordD:* /Force
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

### Updating Server from Powershell

```Powershell
$sess = New-CimInstance -NameSpace root/Microsft/windows/Windowsupdate -Classname MSFT_WUOperationsSession

Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates
```