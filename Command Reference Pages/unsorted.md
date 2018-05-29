# Unsorted Commands

*Put any new commands into this file and they will be sorted and linked on the main readme*

## Set Service Principal Names - Virtual System Migration

*This will need to be done on both machines in order to have a relationship*
*XXX - Name of Server(s)*

```Powershell
SETSPN -s "Microsoft Virtual System Migration Services/XXX" XXX
```

## Enable Echo (Ping) Requests

```Powershell
Get-NetFirewallRule *FPS-ICMP4* | Enable-NetFirewallRule
```


## BC Web Cache stuffs

#### How to Publish Web Content

```Powershell
Get-BCStatus
Publish-BCWebContent -Path "(Web Content Location)" -StageData
Export-BCCachePackage -Destination "(Where you want to store it)"
Import-BBCachePackage "(Whatever Location you stored the file)"
```
