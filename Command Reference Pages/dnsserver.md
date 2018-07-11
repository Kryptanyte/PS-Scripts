# DNS Server Commands

## Get all DNS Server commands

```PowerShell
Get-Command -Module dnsserver
```

## Adding a new record

```PowerShell
Add-DnsServerResourceRecord -ZoneName <zone name> -A -Name <record name> -IPv4Address <record address> -CreatePtr
```

__*Variables*__

- `<zone name>` - Existing zone name on local server
- `<record name>` - Desired name for the record in the zone file
- `<record address>` - IPv4 address of the host that is having a record created for.
- `-A` Tells the cmdlet that the record being created is an A type. Switches exist for all record types `(-Srv, -AAA, -PTR, -NS, ...)`

__*Example*__

```PowerShell
Add-DnsServerResourceRecord -ZoneName "adatum.com" -A -Name TRY2 -IPv4Address 192.168.1.202 -CreatePtr
```

## Getting all records in a zone file

```PowerShell
Get-DnsServerZone -Name <zone name> | Get-DnsServerResourceRecord
```

__*Variables*__

- `<zone name>` - Existing zone name on local server.

__*Example*__

```PowerShell
Get-DnsServerZone -Name "adatum.com" | Get-DnsServerResourceRecord
```

## Creating a secondary zone (Non Domain Joined)

```PowerShell
Add-DnsServerSecondaryZone -Name <zone name> -ZoneFile <zone file> -MasterServers <other server ip>
```

__*Variables*__

- `<zone name>` - Desired name of zone on local server
- `<zone file>` - Name of the zone on the master server/s
- `<other server ip>` - IP/s of other server/s.

__*Example*__

```PowerShell
Add-DnsServerSecondaryZone -Name "adatum.com" -ZoneFile "adatum.com" -MasterServers 172.16.0.10
```

## Creating forward lookup zone with reverse lookup zone

### Only available in AD-DS

```PowerShell
Add-DnsServerPrimaryZone -Name <zone name> -ReplicationScope <scope type> -PassThru | Add-DnsServerPrimaryZone -NetworkID <network id>
```

__*Variables*__

- `<zone name>` - Desired Zone Name on local server. (String)
- `<scope type>` - Replication Scope type. Includes:
  - Forest - The ForestDnsZone directory partition.
  - Domain - The domain directory partition.
  - Legacy - A legacy directory partition.
  - Custom - Any custom directory partition that a user creates. Specify a custom directory partition by using the ***DirectoryPartitionName*** parameter.
- `<netword id>` - Network ID of the network on `<zone name>` for reverse lookup

__*Example*__

```PowerShell
Add-DnsServerPrimaryZone -Name "contoso.com" -ReplicationScope Domain -PassThru | Add-DnsServerPrimaryZone -NetworkID 172.16.22.0/24
```
