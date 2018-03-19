Param(
	[Parameter(Mandatory = $True)]
	[string]$Edition,
	
	[Parameter(Mandatory = $False)]
	[ValidatePattern("^.*\.iso$")]
	[string]$ISO,
	[ValidateRange(1,2)]
	[Int16]$Generation,
	[ValidatePattern("^[0-9]*(?:TB|GB|MB)$")]
	[string]$MinMem,
	[ValidatePattern("^[0-9]*(?:TB|GB|MB)$")]
	[string]$StartMem,
	[ValidatePattern("^[0-9]*(?:TB|GB|MB)$")]
	[string]$DiskSize,
	
	[switch]$Terminal,
	[switch]$Desktop
)

########################
##	Global Variables  ##
########################

# Get Operating Systems from JSON File
$ConfigFileLoc = (Split-Path $MyInvocation.MyCommand.Path -Parent) + "\conf"
$JsonPath = $ConfigFileLoc + "\OperatingSystems.json"
$OSList = ((Get-Content $JsonPath) -join "`n" | ConvertFrom-Json).OperatingSystems

$OSConf

###########################
##	Re-usable Functions  ##
###########################

# Convert Size String to Int64 Bytes
function InBytes
{
	Param(
		[Parameter(Mandatory = $True)]
		$Size
	)
	
	return [scriptblock]::Create($Size).InvokeReturnAsIs()
}

function IsValidPath
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$Path,
		
		[Parameter(Mandatory = $False)]
		[string]$PathType = "Leaf"
	)
	
	return Test-Path -Path $Path -PathType $PathType
}

#############################
##	Main Script Functions  ##
#############################

function PARAMVALIDATION
{
	if($ISO -and (-not (IsValidPath -Path $ISO)))
	{
		Write-Error -Message "ISO must reference a valid path to a .iso image" -Category ReadError -CategoryActivity "Parameter Validation" -CategoryReason "Invalid ISO Path" -CategoryTargetName $ISO
		exit 1
	}
	
	if($StartMem -and ($StartMem -lt $OSConf.Setting.StartMem))
	{
		#Write-Error -Message "Start Memory cannot be smaller than OS Specifications" -
		#exit 1
	}

	
	if($MinMem -and ($MinMem -lt $OSConf.Settings.MinMem))
	{
		Write-Error -Message "Minimum Memory cannot be smaller than OS Specifications" -Category InvalidArgument -CategoryActivity "Parameter Validation" -CategoryReason "Invalid Minimum Memory Size" -CategoryTargetName $MinMem
		exit 1
	}
	
	if($MinMem -and $MaxMem)
	{
		if($MinMem -gt $MaxMem)
		{
			Write-Error -Message "Minimum Memory cannot be larger than Maximum Memory" -Category InvalidArgument -CategoryActivity "Parameter Validation" -CategoryReason "Invalid Memory Size"
			exit 1
		}
		
		if($StartMem)
		{
			if($StartMem -lt $MinMem)
			{
				
				exit 1
			}
			
			if($StartMem -gt $MaxMem)
			{
				
				exit 1
			}
		}
	}
}

# Check for Valid Edition in Config
function GetEdition
{
	# Loop through $OS Objects
	foreach($OS in $OSList)
	{
		# Check for Valid Name in Operating Systems
		if($OS.Name -eq $Edition)
		{
			return $OS
		}
	}
	
	# No Valid Name Was Found, Exit with Error
	Write-Error -Message "Invalid Edition Name" -Category ObjectNotFound -CategoryActivity "CheckEdition" -CategoryReason "Edition Not Found in OS List." -CategoryTargetName $Edition
	exit 1
}

function GetVMName
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$VMName
	)
	
	return $VMName + ([int]((Get-VM -Name ($VMName + "*") | measure).count) + 1)
}

# Verify Passed Variables with Config
function VerifySettings
{
	$VMConf = @{
		"New-VM"=@{}
		"Set-VMDvdDrive"=@{}
	}
	
	$VMConf["New-VM"]["Name"] = $OSConf.Name
	$VMConf["New-VM"]["MemoryStartupBytes"] = if($StartMem){$StartMem}else{$OSConf.Settings.StartMem}
	$VMConf["New-VM"]["NewVHDPath"] = ($OSConf.Name + "_System.vhdx")
	$VMConf["New-VM"]["NewVHDSize"] = if($DiskSize){$DiskSize}else{$OSConf.Settings.MinDiskSize}
	$VMConf["New-VM"]["Generation"] = $OSConf.Settings.Generation
	
	if($OSConf.Settings.InstallType -eq "Server")
	{
		if($Desktop)
		{
			write-host "test"
		}
	}
	#$VMConf["Set-VM"]["MemoryMinimumBytes"] = 
	
	$VMConf["Set-VMDvdDrive"]["Path"] = if($ISO){$ISO}else{$OSConf.Settings.ISO}
	
	return $VMConf
}

function Main
{
	# Work around for Powershell Validation Problems, DO NOT TOUCH
	PARAMVALIDATION 
	# Below here can be touched

	$OSConf = GetEdition
	
	$VMConf = VerifySettings
}

Main
