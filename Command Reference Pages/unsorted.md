# Unsorted Commands

*Put any new commands into this file and they will be sorted and linked on the main readme*

## Set Service Principal Names - Virtual System Migration

*This will need to be done on both machines in order to have a relationship*
*XXX - Name of Server(s)*

```Powershell
SETSPN -s "Microsoft Virtual System Migration Services/XXX" XXX
```

## BC Web Cache stuffs

#### How to Publish Web Content

```Powershell
Get-BCStatus
Publish-BCWebContent -Path "(Web Content Location)" -StageData
Export-BCCachePackage -Destination "(Where you want to store it)"
Import-BBCachePackage "(Whatever Location you stored the file)"
```

## How to find what groups a user account is a member of?

```PowerShell
Get-ADPrincipleGroupMembership
```

## What user accounts have access to a resource?

```PowerShell
Get-ADGroupmember -Identify -Recursive
```
