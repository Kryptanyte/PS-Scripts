# DNS Server Commands

### Adding a new record
```PowerShell
Add-DnsServerResourceRecord -ZoneName <zone name> -A -Name <record name> -IPv4Address <record address> -CreatePtr
```

Where `<zone name>` is existing zone name on local server, `<record name>`, is desired name for the record in the zone file and `<record address>` is the IPv4 address of the host that is having a record created for.

`-A` Tells the cmdlet that the record being created is an A type.

E.g.
```PowerShell
Add-DnsServerResourceRecord -ZoneName "adatum.com" -A -Name TRY2 -IPv4Address 192.168.1.202 -CreatePtr
```

### Getting all records in a zone file

```PowerShell
Get-DnsServerZone -Name <zone name> | Get-DnsServerResourceRecord
```

Where `<zone name>` is existing zone name on local server.

E.g.
```PowerShell
Get-DnsServerZone -Name "adatum.com" | Get-DnsServerResourceRecord
```

### Creating a secondary zone (Non Domain Joined)

```PowerShell
Add-DnsServerSecondaryZone -Name <zone name> -ZoneFile <zone file> -MasterServers <other server ip>
```

Where `<zone name>` is the desired name on local server, `<zone file>` is the name of the zone on the master server/s and `<other server ip>` is ip/s of other server/s.

E.g.
```PowerShell
Add-DnsServerSecondaryZone -Name "adatum.com" -ZoneFile "adatum.com" -MasterServers 172.16.0.10
```
