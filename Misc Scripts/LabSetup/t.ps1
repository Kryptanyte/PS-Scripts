
$rootdir = $PSScriptRoot

#function keys ($h) { foreach ($k in $h.keys) { $k ; keys $h[$k] }}

function GetBytes($s) {return (($s/1GB)*1GB)}
function GetNodeAtIndex{Param([Parameter(Mandatory = $True)] [Int32]$i,$a) $v = 0; Foreach($n in $a.Values){ if($i -eq $v) { return $n } $v++ } return }

#######################
##      Classes      ##
#######################

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

###################################
##      Server Config Stuff      ##
###################################

Function GetServerTable
{
  $dir = "$rootdir\ServerConfigs\"

  $files = Get-ChildItem $dir -Filter "*.pson"

  $Servers = @{}

  Foreach($file in $files)
  {
     $svr = [Server]::new((gc "$dir$file"| Out-String | iex))

     $Servers.Add($svr.Name, $svr) > $null
  }

  return $Servers
}

Function GetInstalledServers
{
  $List = Get-VM

  $Existing = @()

  Foreach($svrname in $ServerConfigs.Keys)
  {
    if(Get-VM -Name $svrname -EA SilentlyContinue)
    {
      $Existing += $svrname
    }
  }

  return $Existing
}

##########################
##      Menu Stuff      ##
##########################

Function Menu_InstallSelect
{
  $ExistingServers = GetInstalledServers

  $M_IS_Running = $True

  $InstallServers = [System.Collections.ArrayList]@()

  While($M_IS_Running)
  {
    Clear-Host

    Write-Host -ForegroundColor Green -Object @"

      Avonmore Systems Administration Course Lab Setup
      Please Select Servers to Install

      Existing Servers: $ExistingServers

      Currently Selected: $InstallServers

"@
    $c = 1
    Foreach($svr in $ServerConfigs.Values)
    {
      Write-Host -ForegroundColor Yellow -"    $c)"$svr.Name

      $c++
    }

    Write-Host ForegroundColor Yellow -Object "    q) Exit"

    $Selection = Read-Host "Select Server/s to install or type 's' to start installtion process"

    if($Selection -eq "0")
    {
      $M_IS_Running = $False
    }
    elseif($Selection -eq "s")
    {
      $M_IS_Running = $False

      Install_StartInstall($InstallServers)
    }
    else
    {
      if($Selection -match "^\d+$")
      {
        $Num = [Int32][String]$Selection - 1

        $svr = GetNodeAtIndex $Num $ServerConfigs

        if($InstallServers.Contains($svr.Name))
        {
          $InstallServers.Remove($svr.Name)
        }
        else
        {
          $InstallServers.Add($svr.Name)
        }

        $InstallServers.Sort()
      }
    }
  }
}

Function Menu_MainMenu
{
  $M_MM_Running = $true

  While($M_MM_Running)
  {
    Clear-Host

    Write-Host -ForegroundColor Green -Object @"

      Avonmore Systems Administration Course Lab Setup
      Please Select Menu

"@
    Write-Host -ForegroundColor Yellow -Object @"
      1) Install Server/s
      2) Remove Server/s

      q) Exit

"@

    $Item = Read-Host "Select an Item: "

    if($Item -eq "1")
    {
      Menu_InstallSelect
    }
    elseif($Item -eq "2")
    {

    }
    elseif($Item -eq "q")
    {
      Clear-Host

      $M_MM_Running = $False
    }
  }
}

####################
##      Main      ##
####################

Function Main
{
  Clear-Host

  $ServerConfigs = GetServerTable

  Menu_MainMenu
}

Main
