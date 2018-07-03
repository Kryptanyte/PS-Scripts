#
# Creating New VMs - Because Labs are bloody annoying
#

# Default Locations

Set-VMHost -VirtualHardDiskPath "F:\VHDX's\" -VirtualMachinePath "F:\Virtual Machines\"
$VHDPath = "F:\VHDX's\"

#Varables

$Diff_DTC_Desktop = "F:\Differencing Disks\Lab-DTC (Desktop) (OOBE).vhdx"
$Diff_DTC_NonDesktop = "F:\Differencing Disks\Lab-DTC (Non-Desktop) (OOBE).vhdx"
$Drive_Tools = "F:\Differencing Disks\Tools.vhdx"
$Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "Administrator",(ConvertTo-SecureString -String "Theman232" -AsPlainText -Force)
$DomainCred = New-Object -TypeName "System.Management.Atuomation.PSCredential" -ArgumentList "adatum\Administrator",(ConvertTo-SecureString -String "Theman232" -AsPlainText -Force) 

# Functions

### Make This Script Wait for VM to start
Function WaitForVM($VMName)
{
 $Running = $True

 While ($Running)
  {
  Start-Sleep -Seconds 60
  $Running = $false

  Try
  {
   Test-Connection -ComputerName $VMName
  } Catch { $Running = $True }
  }
}

### Creating A New VHDX 

Function CreateVHD($ParentPath, $DiskPath)
{
#New-VHD -Path "$VHDPath$DiskPath" -Differencing -ParentPath $ParentPath  
}

### Create a new Disk

Function CreateDisk($DiskPath,$SizeBytes)
{
#New-VHD -Path "$VHDPath$DiskPath" -Dynamic -SizeBytes $SizeBytes
}

### Create A New Virtual Machine

Function CreateVM($Name)
{
#New-VM -Name $Name -MemoryStartupBytes 2GB -VHDPath "$VHDPath$Name.vhdx" -Generation 2 -SwitchName "Private"
}

### Modifying Configuration of Virtual Machines

Function ModifyConfig($Name)
{
Set-VM -Name $Name -CheckpointType Disabled -AutomaticStartAction Nothing
Set-VMMemory -VMName $Name -DynamicMemoryEnabled $True -MinimumBytes 1GB -StartupBytes 2GB -MaximumBytes 4GB
Connect-VMNetworkAdapter -SwitchName Private -VMName $Name 
}

### Invoking Commands Into Virtual Machines

Function InvokeCommand($VMName ,$IPAddress,$DNSAddresses)
{
Invoke-Command -VMName $VMName -Credential $Cred {New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "$IPAddress" -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "$DNSAddresses"; Add-Computer -DomainName adatum.com -DomainCredential $DomainCred; Rename-Computer -NewName "$VMName" ;Restart-Computer}
}

### Start Virtual Machines

Function StartVM($VMName,$IPAddress,$DNSAddresses)
{
Write-Host "Virtual Machine Name: $VMName, IP Address: $IPAddress, DNS Addresses: $DNSAddresses"
Start-vm -Name $VMName -Verbose | VMConnect localhost $VMName 
Write-Host "Starting $VMName, Opening Window, Please Go through Virtual Machine Setup Before Continuing"
Write-Host "This Virtual Machine Will need the Password 'Theman232' In order for this script to complete successfully"
Write-Host "Make Sure all the configuration of 'OUT OF BOX EXPERENCE' is set correctly"
Pause
$ScriptBlock = {
    Param($IPAddress, $DNSAddresses, $DomainCred, $VMName)
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $IPAddress -PrefixLength 24
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNSAddresses
    Add-Computer -DomainName adatum.com -DomainCredential $DomainCred 
    Rename-Computer -NewName "$VMName"
    Restart-Computer -Force
}
Invoke-Command -VMName $VMName -Credential $Cred -ScriptBlock $ScriptBlock -ArgumentList $IPAddress,$DNSAddresses,$DomainCred,$VMName
}

# Creating Switches

#New-VMSwitch -Name Private -SwitchType Private 
#New-VMSwitch -Name External -NetAdapterName "Ethernet 2"

# Creating Virtual Machines Disks
<#
CreateVHD $Diff_DTC_Desktop "LON-DC1.vhdx"
CreateVHD $Diff_DTC_Desktop "TOR-DC1.vhdx"
CreateVHD $Diff_DTC_Desktop "TREY-DC1.vhdx"
CreateVHD $Diff_DTC_Desktop "LON-SVR1.vhdx"
CreateVHD $Diff_DTC_Desktop "LON-SVR2.vhdx"
CreateVHD $Diff_DTC_Desktop "LON-BUS.vhdx"
CreateVHD $Diff_DTC_Desktop "BF-DC1.vhdx"
CreateVHD $Diff_DTC_NonDesktop "RF-DC1.vhdx"
CreateVHD $Diff_DTC_NonDesktop "BV-DC1.vhdx"
#>
# Disk Drives
<#
CreateDisk "LON-DC1 - DATA.vhdx" 20GB
CreateDisk "LON-BUS - DATA.vhdx" 25GB
CreateDisk "CA-SVR1.vhdx" 40GB
#>
# Creating Virtual Machimes
<#
CreateVM("LON-DC1")
CreateVM("TOR-DC1")
CreateVM("TREY-DC1")
CreateVM("LON-SVR1")
CreateVM("LON-SVR2")
CreateVM("LON-BUS")
CreateVM("RF-DC1")
CreateVM("BV-DC1")
CreateVM("BF-DC1")
CreateVM("CA-SVR1")
#>
# Modifying Configuration of Checkpoints and Start Actions (Also Memory)

Set-VM -Name LON-DC1 -CheckpointType Disabled -AutomaticStartAction Start
Set-VMMemory -VMName LON-DC1 -DynamicMemoryEnabled $True -MinimumBytes 1GB -StartupBytes 2GB -MaximumBytes 4GB
ModifyConfig("TOR-DC1")
ModifyConfig("TREY-DC1")
ModifyConfig("LON-SVR1")
ModifyConfig("LON-SVR2")
ModifyConfig("LON-BUS")
ModifyConfig("RF-DC1")
ModifyConfig("BV-DC1")
ModifyConfig("BF-DC1")
ModifyConfig("CA-SVR1")

#Adding Data Drives
<#
Add-VMHardDiskDrive -VMName LON-DC1 -Path "F:\VHDX's\LON-DC1 - DATA.vhdx" 
Add-VMHardDiskDrive -VMName LON-BUS -Path "F:\VHDX's\LON-BUS - DATA.vhdx"

#Strating the Virtual Machines


Start-VM -Name LON-DC1
Write-Host "Starting LON-DC1, Opening Window, Please Go through Virtual Machine Setup Before Continuing"
Pause
Invoke-Command -VMName LON-DC1 -Credential $Cred {Rename-Computer -NewName LON-DC1; Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools; Install-ADDsForest -DomainName "Adatum.com" -DomainNetBiosName "Adatum" -InstallDNS; New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.1 -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1 }
#>
StartVM "TOR-DC1" 192.168.1.2 192.168.1.1

StartVM "TREY-DC1" 192.168.1.3 192.168.1.1

StartVM "LON-SVR1" 192.168.1.4 192.168.1.1

StartVM "LON-SVR2" 192.168.1.5 192.168.1.1

StartVM "LON-BUS" 192.168.1.6 192.168.1.1 

StartVM "CA-SVR1" 192.168.1.20 192.168.1.1

Start-VM -Name RF-DC1
VMConnect localhost RF-DC1
Write-Host "Starting RF-DC1, Opening Window, Please Go through Virtual Machine Setup Before Continuing"
Write-Host "This Virtual Machine Will need the Password 'Theman232' In order for this script to complete successfully"
Write-Host "Make Sure all the configuration of 'OUT OF BOX EXPERENCE' is set correctly"
Write-Color -Color Red "THIS IS A ONE DAY SERVER! DO NOT ADD THIS TO A SWITCH!"
Pause
Invoke-Command -VMName RF-DC1 -Credential $Cred {Rename-Computer -NewName RF-DC1; Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools; Install-ADDsForest -DomainName "RedFox.com" -DomainNetBiosName "Redfox" -InstallDNS; New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.10.1 -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1; Restart-Computer }

Start-VM -Name BV-DC1
VMConnect localhost BV-DC1
Write-Host "Starting BV-DC1, Opening Window, Please Go through Virtual Machine Setup Before Continuing"
Write-Host "This Virtual Machine Will need the Password 'Theman232' In order for this script to complete successfully"
Write-Host "Make Sure all the configuration of 'OUT OF BOX EXPERENCE' is set correctly"
Write-Color -Color Red "THIS IS A ONE DAY SERVER! DO NOT ADD THIS TO A SWITCH!"
Pause
Invoke-Command -VMName BV-DC1 -Credential $Cred {Rename-Computer -NewName BV-DC1; Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools; Install-ADDsForest -DomainName "BlueVale.com" -DomainNetBiosName "BlueVale" -InstallDNS; New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.10.2 -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1; Restart-Computer }

Start-VM -Name BF-DC1
VMConnect localhost BF-DC1
Write-Host "Starting BF-DC1, Opening Window, Please Go through Virtual Machine Setup Before Continuing"
Write-Host "This Virtual Machine Will need the Password 'Theman232' In order for this script to complete successfully"
Write-Host "Make Sure all the configuration of 'OUT OF BOX EXPERENCE' is set correctly"
Write-Color -Color Red "THIS IS A ONE DAY SERVER! DO NOT ADD THIS TO A SWITCH!"
Pause
Invoke-Command -VMName BF-DC1 -Credential $Cred {Rename-Computer -NewName BF-DC1; Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools; Install-ADDsForest -DomainName "BlueFox.com" -DomainNetBiosName "BlueFox" -InstallDNS; New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.10.3 -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1; Restart-Computer }
