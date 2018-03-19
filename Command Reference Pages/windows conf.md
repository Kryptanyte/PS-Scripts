# Windows Configuration

### Enabling Nested Virtualization

The first command will be for finding the virtual machine name, in this example, we will be looking for DataCenter, and we will assign the name as a variable

```Powershell
$vmname = Get-VM | where {$_.name -like "LON-SVR2*"}
```

After this, we will need to set the virtual machine's processor count, we will need to cores for the child Virtual Machine

```Powershell
Set-VMProcessor -VMName $vm.name -Count 2 -ExposeVirtualizationExtentions $true
```

(Note: the $vm.name is the variable of the machine you selected before)

Next we will need to assign a set ammont of memory, for this example, we will use 8GB of Non-Dynamic Memory

```Powershell
Set-VMMemory -VMName $vm.name -DynamicMemoryEnabled $false
```
```Powershell
Set-VM -VMName $vm.name -memorystartupbytes 8GB
```

Now we will set the network adapter for the Child Virtual Machine, this will be for allowing network or internet access
```Powershell
Set-VMNetworkAdapter -VMName $vm.name -Name "(Input network adapter here)" -MacAddressSpoofing on
```

### Desired State Configuration

This will allow you to view a defined configuration on different names and Propertities

eg: DHCP server will have redundency by having a backup server, this will allow us to keep a configuration running (Mainly a service)

```Powershell
Get-DscResource | Select-Object -Property Name, Properties
```
```Powershell
Get-DscResource -Name Service -Syntax
```

This will show how the command would be setup in script format

```Powershell ISE
{
    Name = [string]
    [BuiltInAccount = [string]{ LocalService | LocalSystem | NetworkService }]
    [Credential = [PSCredential]]
    [Dependencies = [string[]]]
    [DependsOn = [string[]]]
    [Description = [string]]
    [DisplayName = [string]]
    [Ensure = [string]{ Absent | Present }]
    [Path = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [StartupType = [string]{ Automatic | Disabled | Manual }]
    [State = [string]{ Running | Stopped }]
}
```

An example of this could be making a sample configuration for Simple network Managemet Protocol

```Powershell ISE
Configuration SimpleConfiguration
{
    WindowsFeature snmp
        { 
           Name="SNMP-Service";
           Ensure="Present"
        }
}
```

After setting this, it will show in the folder that it was set in

After setting this script up, you can 5yen start a DSC configuration, with the Command Below, we will be using the example to issue the command

```Powershell
Start-DscConfiguration -computername localhost -path (Path Name) . -Verbose