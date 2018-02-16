# Basic Commands
### Adding a machine to the Domain
```PowerShell
Add-Computer -DomainName <domain name> -DomainCredential (Get-Credential) -NewName <name>
```

E.g.
```PowerShell
Add-Computer -DomainName adatum -DomainCredential (Get-Credential) -NewName WS01
```
