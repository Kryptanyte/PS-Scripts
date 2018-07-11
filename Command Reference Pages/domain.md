# Domain Commands

## Adding a machine to a Domain

```PowerShell
Add-Computer -DomainName <domain name> -DomainCredential (Get-Credential) -NewName <name>

Add-Computer -DomainName adatum -DomainCredential (Get-Credential) -NewName WS01
```

## Remove Computer From Non-Existant Domain

```Powershell
netdom remove <computer name> /Domain:<domain name> /UserD:<admin name> /PasswordD:* /Force
```
