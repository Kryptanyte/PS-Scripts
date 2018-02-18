# Basic Commands
### Adding a machine to the Domain
```PowerShell
Add-Computer -DomainName <domain name> -DomainCredential (Get-Credential) -NewName <name>
```

E.g.
```PowerShell
Add-Computer -DomainName adatum -DomainCredential (Get-Credential) -NewName WS01
```


### Setting Server Address (Server Machine Only)
```Powershell
Set-DnsClientServerAddress -Interfacealias <Interface Name here> -serveraddress <New IP Address Here>
```

### Making A New Virtural Hard Disk 
```Powershell
new-vhd -Path <Input File Path Here> -SizeBytes <Size of drive> -Dynamic <Can be Fixed, Differential>
```


