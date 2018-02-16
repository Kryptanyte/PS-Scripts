## New-VM Hashtable Configuration ##
$NewVM-Router = @{
	## Virtual Machine Name ##
	Name = "DD-WRT"
	
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
$SetVM-ExtraConfig = @{
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

## Attach-VMDvdDrive Hashtable Configuration ##
$AttachDvdDrive = @{
	## VM Name ## (not needed if vm object is piped)
	#VMName = <String>
	
	## Disk Image Location ##
	Path = "D:\ISOs\Core6.0-ddwrt-14896.iso"	
}

## Create New VM ##
$VM = New-VM @NewVM-Router

## Assign Extra Configuration Options ##
$VM = $VM | Set-VM @SetVM-ExtraConfig

## Mount Install ISO to VM ##
$VM = $VM | Attach-VMDvdDrive @AttachDvdDrive

