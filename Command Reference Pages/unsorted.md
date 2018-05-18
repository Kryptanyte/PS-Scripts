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
