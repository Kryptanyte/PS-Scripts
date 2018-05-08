
function GetServerConfigs
{
  $Servers = [System.Collections.ArrayList]@()
  Get-ChildItem "$PSScriptRoot/VMs" -Filter *.json |
  ForEach-Object {
    $Servers.Add((Get-Content $_.FullName | ConvertFrom-Json)) > $null
  }

	return $Servers
}
