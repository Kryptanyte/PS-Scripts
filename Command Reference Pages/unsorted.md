# Unsorted Commands

*Put any new commands into this file and they will be sorted and linked on the main readme*

## Set Service Principal Names - Virtual System Migration

*This will need to be done on both machines in order to have a relationship* 
*XXX - Name of Server(s)*

```Powershell
SETSPN -s "Microsoft Virtural System Migration Services/XXX" XXX
```



## Enabling Migration Between Hyper-V Hosts


```Powershell
SETSPN -s "Microsoft Virtural System Migration Services/<host 1>" <host 1>
SETSPN -s "Microsoft Virtural System Migration Services/<host 1>.<domain>" <host 1>

SETSPN -s "Microsoft Virtural System Migration Services/<host 2>" <host 2>
SETSPN -s "Microsoft Virtural System Migration Services/<host 2>.<domain>" <host 2>
```
