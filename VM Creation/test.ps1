$VMInit = @{
	VM1 = @{
		Name = "LON-DC1"
		Generation = 2
		NewVHDPath = "LON-DC1-System.vhdx"
		NewVHDSizeBytes = 50GB	
		SwitchName = "Private"
		MemoryStartUpBytes = 2GB
	}
	VM2 = @{
		Name = "LON-DC2"
		Generation = 1
		NewVHDPath = "LON-DC1-System.vhdx"
		NewVHDSizeBytes = 25GB	
		SwitchName = "Private"
		MemoryStartUpBytes = 1GB
	}
}

$VMS = ConvertTo-Json $VMInit #| Out-File -FilePath "test.json"

$VMInit.GetEnumerator() | % ($_.Value)

foreach($VMObj in $VMInit)
{
	#Write-Host($VMObj)
}