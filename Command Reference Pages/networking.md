# Networking Random Stuff

## Enable IPv4 Echo (Ping) Requests

```Powershell
Get-NetFirewallRule *FPS-ICMP4* | Enable-NetFirewallRule
```

## Setting Server Address

```Powershell
Set-DnsClientServerAddress -InterfaceAlias <interface name> -ServerAddresses "<ip address/es>"
```

__*Variables*__

- `<interface name>` Name of the Interface to set DNS Server/es on.
- `<ip address/es>` IP or IPs of the DNS Server/es. If multiple are being set, separate with ','.

__*Example*__

```Powershell
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses "192.168.1.10,192.168.1.11"
```

## Connect iSCSI Target

```Powershell
Start-Service msiscsi

Set-Service msiscsi -StartupType Automatic

New-IscsiTargetPortal -TargetPortalAddress <target address>

Connect-IscsiTarget -NodeAddress ((Get-IscsiTarget).NodeAddress)

Get-IscsiSession | Register-IscsiSession
```

__*Variables*__

- `<target address>` IPv4 Address of the iSCSI Target Server

__*Example*__

```Powershell
New-IscsiTargetPortal -TargetPortalAddress 10.1.1.15
```
