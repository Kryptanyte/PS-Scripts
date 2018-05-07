function GetServerConfigs
{
  $Servers = [System.Collections.ArrayList]@()
  Get-ChildItem "$PSScriptRoot/VMs" -Filter *.json |
  ForEach-Object {
    $Servers.Add((Get-Content $_.FullName | ConvertFrom-Json)) > $null
  }

	return $Servers
}

Clear-Host



$ServerNames = @(
  "LON-DC1",
  "LON-SVR1",
  "LON-CL1",
  "EU-RTR",
  "TOR-SVR1",
  "INET"
)
$ToInstall = new-object bool[] $ServerNames.Length
<#
Write-Host -Object @"

    1) LON-DC1
    2) LON-SVR1
    3) LON-CL1
    4) EU-RTR
    5) TOR-SVR1
    6) INET

    a) Accept
    q) Quit Setup

"@

$result = Read-Host "Select an Option"
#>
Write-Host -ForegroundColor Cyan -Object @"

      Lab VM List

"@

$i = 0
foreach($name in $ServerNames)
{
  Write-Host "$name"
}
