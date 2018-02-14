#Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All"

#Set-VMHost -VirtualHardDiskPath "E:\VM\HDD"
#Set-VMHost -VirtualMachinePath "E:\VM\VM"

$VMInit = @{
	Name = "LON-DC1"
	Generation = 2
	NewVHDPath = "LON-DC1-System.vhdx"
	NewVHDSizeBytes = 50GB	
	SwitchName = "Private"
	MemoryStartUpBytes = 2GB
}

$VMSettings = @{
	ProcessorCount = 2
	CheckpointType = "disable"
}

$NetworkAdapter = @{
	IPAddress = "10.60.40.10"
	Gateway = "10.60.40.1"
	PrefixLength = 24
	DomainName = "adatum.com"
	DomainNetBIOSName = "adatum"
}

#$VM = New-VM @VMInit

$VM = Get-VM -Name "LON-DC1"

#$VM = $VM | Set-VM @VMSettings
##Set-VM -Name "LON-DC1" -ProcessorCount 2 -CheckpointType Disable