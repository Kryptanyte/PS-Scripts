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

if($ISO)
{
	write-host "test"
}