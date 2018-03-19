##
##	Commands Used to Create Domain Controller VM
##
##  Double Commented Commands are Equivalent of the Line Above Them
##

Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All"

Set-VMHost -VirtualHardDiskPath "E:\VM\HDD"
Set-VMHost -VirtualMachinePath "E:\VM\VM"

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

$VM = New-VM @VMInit
##New-VM -Name "LON-DC1" -Generation 2 -NewVHDPath "LON-DC1-System.vhdx" -NewVHDSizeBytes 50GB -SwitchName "Private" -MemoryStartUpBytes 2GB

$VM = $VM | Set-VM @VMSettings
##Set-VM -Name "LON-DC1" -ProcessorCount 2 -CheckpointType Disable