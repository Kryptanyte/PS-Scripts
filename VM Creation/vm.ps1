Param(
	[Parameter(Mandatory = $True)]
	[string]$Edition,
	
	[Parameter(Mandatory = $False)]
	[string]$ISO,
	[Int16]$Generation,
	[string]$MinMem,
	[string]$StartMem,
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

#############################
##	Main Script Functions  ##
#############################

# Check for Valid Edition in Config
function CheckEdition
{
	# Loop through $OS Objects
	foreach($OS in $OSList)
	{
		# Check for Valid Name in Operating Systems
		if($OS.Name -eq $Edition)
		{
			return
		}
	}
	
	# No Valid Name Was Found, Exit with Error
	Write-Error -Message "Invalid Edition Name" -Category ObjectNotFound -CategoryActivity "CheckEdition" -CategoryReason "Edition Not Found in OS List." -CategoryTargetName $Edition
}

# Verify Passed Variables with Config
function VerifySettings
{
	
}

function Main
{
	CheckEdition
	
	VerifySettings
}

Main