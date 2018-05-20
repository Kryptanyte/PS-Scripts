
$rootdir = $PSScriptRoot

#function keys ($h) { foreach ($k in $h.keys) { $k ; keys $h[$k] }}

function GetBytes($s) {return (($s/1GB)*1GB)}

Class VDrive
{
  [String]$Name
  [String]$Type
  [UInt64]$Size
  [Switch]$Dynamic
  [String]$Parent

  VDrive($Drive)
  {
    $this.Name = $Drive.Name
    $this.Type = $Drive.Type

    if($this.Type -eq "Differencing")
    {
      $this.Parent = $Drive.Parent
    }
    elseif(($this.Type -eq "Dynamically Expanding") -or ($this.Type -eq "Fixed Size"))
    {
      $this.Size = GetBytes($Drive.Size)

      if($this.Type -eq "Dynamically Expanding")
      {
        $this.Dynamic = $true
      }
    }
  }
}

Class VSwitch
{
  [String]$Name
  [String]$Type
}

Class Server
{
  [String]$Name
  [HashTable]$Memory
  [VDrive[]]$Drives
  [VSwitch[]]$Switches
  [HashTable]$DSC

  Server($ServerTable)
  {
    $this.Name = $ServerTable.ServerName
    $this.Memory = $ServerTable.Memory

    Foreach($Drive in $ServerTable.Drives)
    {
      $this.Drives += [VDrive]::new($Drive)
    }

    $this.DSC = $ServerTable.DSC
  }
}

Function GetServerTable
{
  $dir = "$rootdir\ServerConfigs\"

  $files = Get-ChildItem $dir -Filter "*.pson"

  $Servers = @()

  Foreach($file in $files)
  {
    $Servers += [Server]::new((gc "$dir$file"| Out-String | iex))
  }

  return $Servers
}

Function Menu_InstallSelect
{
  Write-Host -ForegroundColor Green -Object @"

    Avonmore Systems Administration Course Lab Setup
    Please Select Servers to Install

    Existing Servers:

    Currently Selected:

"@
  $c = 0
  Foreach($svr in $Servers)
  {
    Write-Host -ForegroundColor Yellow "  $c)"$svr.Name

    $c++
  }
}

Function GetInstalledServers
{
  #$List = Get-VM
}

Function Main
{
  Clear-Host

  $Servers = GetServerTable

  GetInstalledServers
}

Main
