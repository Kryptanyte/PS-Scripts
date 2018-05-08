function GetServerConfigs
{
  $Servers = [System.Collections.ArrayList]@()
  Get-ChildItem "$PSScriptRoot/VMs" -Filter *.json |
  ForEach-Object {
    $t = ((Get-Content $_.FullName) | ConvertFrom-Json).PSObject.Properties

    ForEach($v in $t)
    {
      $v.Name
    }

  }

	return $Servers
}

$Servers = GetServerConfigs
$ToInstall = new-object bool[] $ServerNames.Length

Write-Host -ForegroundColor Cyan -Object @"

      Lab VM List

"@


ForEach($Serv in $Servers)
{
  #Write-Host $Serv[0]
}
