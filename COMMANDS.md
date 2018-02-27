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

### Making A New Virtual Hard Disk 
```Powershell
new-vhd -Path <Input File Path Here> -SizeBytes <Size of drive> -Dynamic <Can be Fixed, Differential>
```

### New NAT Switch

(Replace Your Router With This, Also Don't Pipe all this, just an example)
```Powershell
New-VMSwitch -switchname "NAT" -SwitchType Internal | New-NetIpAddress -IPAddress 10.60.10.1 New-VMSwitch -switchname "NAT" -SwitchType Internal | New-NetIpAddress -IPAddress 10.60.10.1 
```

