## VM Name Variable ##
$CurrVMName = "DD-WRT"

## New-VM Hashtable Configuration ##
$NewVM = @{
	## Virtual Machine Name ##
	Name = $CurrVMName
	
	## Virtual Machine Generation ##
	Generation = 1
	
	## Existing VHD FilePath ##
	#VHDPath = <String>
	
	## New VHD FilePath and Size ##
	NewVHDPath = "DD-WRT-System.vhdx"
	NewVHDSizeBytes = 5GB
	
	## Create VM Without VHD ##
	#NoVHD
	
	## Startup Memory Size ##
	MemoryStartUpBytes = 512MB
	
	## Initial Network Switch ##
	#SwitchName = <String>
}

## Set-VM Hashtable Configuration ##
$SetVM = @{
	## VM Name ## (not needed if vm object is piped)
	#Name = <String>
	
	## Amount of Cores Assigned to VM ##
	ProcessorCount = 1
	
	## Upper and Lower Limits of RAM ##
	#MemoryMinimumBytes = <Int64>
	#MemoryMaximumBytes = <Int64>
	
	## Startup Memory Size ##
	#MemoryStartUpBytes = <Int64>
	
	## 
	#DynamicMemory
	#StaticMemory
	
	## Rename VM ##
	#NewVMName = <String>
	
	## Set Paging File Location ##
	#SmartPagingFilePath = <String>
	
	## Automatic VM Actions ##
	#AutomaticStartAction = <StartAction>
	#AutomaticStopAction = <StopAction>
	#AutomaticStartDelay = <Int32>
}

## Add-VMDvdDrive Hashtable Configuration ##
$AddDvdDrive = @{
	## VM Name ## (not needed if vm object is piped)
	#VMName = <String>
	
	## Disk Image Location ##
	Path = "D:\ISOs\Core6.0-ddwrt-14896.iso"	
}

$NewLegacyAdapter = @{
    ## VM Name ## (not needed if vm object is piped)
	VMName = $CurrVMName

    ## Initial Network Switch ##
	#SwitchName = <String>
    
    ## Make New Legacy Network Adapter ##
    IsLegacy = $true
}

## Create New VM ##
$VM = New-VM @NewVM

## Assign Extra Configuration Options ##
$VM = $VM | Set-VM @SetVM

## Mount Install ISO to VM ##
$VM = $VM | Add-VMDvdDrive @AddDvdDrive

## Remove Non-Legacy Network Adapter ##
Remove-VMNetworkAdapter -VMName $CurrVMName

## Add a Legacy Network Adapter and Connect to Private Switch ##
Add-VMNetworkAdapter @NewLegacyAdapter -SwitchName "Private"

## Add a Legacy Network Adapter With no Default Switch ##
Add-VMNetworkAdapter @NewLegacyAdapter