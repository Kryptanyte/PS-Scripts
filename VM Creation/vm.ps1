Param(
	[Parameter(Mandatory = $True)]
	[string]$Edition,
	
	[Parameter(Mandatory = $False)]
	[ValidatePattern("^.*\.iso$")]
	[string]$ISO,
	[ValidateRange(1,2)]
	[Int16]$Generation,
	[ValidatePattern("^[0-9]*(?:T|GB|MB)$")]
	[string]$MinMem,
	[ValidatePattern("^[0-9]*(?:T|GB|MB)$")]
	[string]$StartMem,
	[ValidatePattern("^[0-9]*(?:T|GB|MB)$")]
	[string]$MinDiskSize
)

########################
##	Global Variables  ##
########################

# Get Operating Systems from JSON File
$ConfigFileLoc = (Split-Path $MyInvocation.MyCommand.Path -Parent) + "\conf"
$JsonPath = $ConfigFileLoc + "\OperatingSystems.json"
$OSList = ((Get-Content $JsonPath) -join "`n" | ConvertFrom-Json).OperatingSystems

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

function IsValidVar
{
	Param(
		[Parameter(Mandatory = $True)]
		$Var
	)
	
	return switch -Wildcard ($Var.GetType().Name) {
		"String"
		{
			[string]::IsNullOrEmpty($Var)
		}
	}
}

#############################
##	Main Script Functions  ##
#############################

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
}

function GetVMName
{
	Parameter(
		[Parameter(Mandatory = $True)]
		[string]$VMName
	)
	
	return (Get-VM -Name ($VMName + "*") | measure).count + 1
}

# Verify Passed Variables with Config
function VerifySettings
{
	Param(
		[Parameter(Mandatory = $True)]
		$OSConf
	)
	
	$VMConf = @{
		"New-VM"=@{}
	}
	if(IsValidVar($ISO))
	{
		
	}
	else
	{
		$VMConf[
	}
}

function Main
{
	$OSConf = GetEdition
	
	$VMConf = VerifySettings($OSConf)
}

Main