# Windows Configuration

## Desired State Configuration

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

After setting this script up, you can then start a DSC configuration, with the Command Below, we will be using the example to issue the command

```Powershell
Start-DscConfiguration -computername localhost -path (Path Name) . -Verbose
```

## Updating Server from Powershell

```Powershell
$sess = New-CimInstance -NameSpace root/Microsft/windows/Windowsupdate -Classname MSFT_WUOperationsSession

Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates
```

## Performing Windows Server Backup (Powershell)

```Powershell
# Create a Backup Policy
$Policy = New-WBPolicy

# Create File/Folder Specifications
$UserData = New-WBFileSpec -FileSpec "C:\Users\*"
$ProgramData = New-WBFileSpec -FileSpec "C:\ProgramData\*"

# Add Files/Folders to Policy
Add-WBFileSpec -Policy $Policy $UserData,$ProgramData

# Create Backup Target Location
$TargetLoc = New-WBBackupTarget -NetworkPath "<Network Location>"

# Add Backup Target to Policy
Add-WBBackupTarget -Policy $Policy -Target $TargetLoc

# Start Backup Policy
Start-WB -Policy $Policy
``
