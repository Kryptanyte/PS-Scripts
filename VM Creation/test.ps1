$ConfigFileLoc = (Split-Path $MyInvocation.MyCommand.Path -Parent) + "\conf"
$FileLoc = $ConfigFileLoc + "\OperatingSystems.json"
$JsonObj = ((Get-Content $FileLoc) -join "`n" | ConvertFrom-Json).OperatingSystems

$Var = "WS_2016_S"

if($JsonObj.$Var)
{
	Write-Host "Test"
}
else
{
	Write-Host "Invalid"
}

#$JsonObj
$Limit = "1GB"
$Limit
[scriptblock]::Create($Limit).InvokeReturnAsIs()