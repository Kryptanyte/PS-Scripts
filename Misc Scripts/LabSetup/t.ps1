
$rootdir = $PSScriptRoot
$VMDir = "D:\VM\VM\"

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
  [Switch]$Dynamic = $False
  [String]$Parent

  static [String]$Path

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
        $this.Dynamic = $True
      }
    }
  }

  [Boolean] Verify()
  {
    if($this.Name -eq "")
    {
      return $False
    }

    return $True
  }

  [void] Create()
  {
    $this.RemoveIfExists()

    if($this.Type -eq "Differencing")
    {
      New-VHD -Path ([VDrive]::Path + $this.Name) -ParentPath $this.Parent -Differencing
    }
    else
    {
      if($this.Dynamic)
      {
        New-VHD -Path ([VDrive]::Path + $this.Name) -SizeBytes $this.Size -Dynamic
      }
      else
      {
        New-VHD -Path ([VDrive]::Path + $this.Name) -SizeBytes $this.Size -Fixed
      }
    }
  }

  [void] RemoveIfExists()
  {
    if(Test-Path ([VDrive]::Path + $this.Name))
    {
      Remove-Item ([VDrive]::Path + $this.Name)
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
  [Int32]$Priority
  [HashTable]$Memory
  [VDrive[]]$Drives
  [VSwitch[]]$Switches
  [HashTable]$DSC

  Server($ServerTable)
  {
    $this.Name = $ServerTable.ServerName
    $this.Priority = $ServerTable.Priority
    $this.Memory = @{Min = GetBytes($ServerTable.Memory.Min); Max = GetBytes($ServerTable.Memory.Max); Startup = GetBytes($ServerTable.Memory.Startup)}
    #Write-Host (GetBytes($ServerTable.Memory.Min))
    Foreach($Drive in $ServerTable.Drives)
    {
      $this.Drives += [VDrive]::new($Drive)
    }

    $this.DSC = $ServerTable.DSC
  }

  [void] Create()
  {
    $this.RemoveIfExists()

    New-VM -Name $this.Name -Generation 2 -MemoryStartupBytes $this.Memory.Startup

    if(($this.Memory.Max) -and ($this.Memory.Min))
    {
      Set-VMMemory -VMName $this.Name -MaximumBytes $this.Memory.Max -MinimumBytes $this.Memory.Min -DynamicMemoryEnabled $True
    }

    Foreach($drive in $this.Drives)
    {
      Add-VMHardDiskDrive -VMName $this.Name -ControllerType SCSI -Path ([VDrive]::Path + $drive.Name)
    }


  }

  [void] RemoveIfExists()
  {
    if(Get-VM -Name $this.Name)
    {
      Remove-VM -Name $this.Name
    }
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
     $svr = [Server]::new((gc <#Get-Content#> "$dir$file"| Out-String | iex <#Invoke-Expression#>))

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

####################################
##      Server Install Stuff      ##
####################################

Function Install_Main($ToInstall)
{
  $ServerList = Install_SortServerPrio($ToInstall)

  Install_CreateVHDs($ServerList)

  Install_CreateVMs($ServerList)
}

Function Install_SortServerPrio($ToInstall)
{
  $SortedList = [System.Collections.ArrayList]@()

  Foreach($Name in $ToInstall)
  {
    $SortedList.Add($ServerConfigs[$Name]) > $null
  }

  return $SortedList
}

Function Install_CreateVHDs($ServerList)
{
  Foreach($svr in $ServerList)
  {
    Foreach($drive in $svr.Drives)
    {
      $drive.Create()
    }
  }
}

Function Install_CreateVMs($ServerList)
{
  Foreach($svr in $ServerList)
  {
    $svr.Create()
  }
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
      Write-Host -ForegroundColor Yellow "      $c)"$svr.Name

      $c++
    }

    Write-Host -ForegroundColor Cyan -Object @"

      s) Start Install
      q) Exit

"@

    $Selection = Read-Host "Select Server/s to install or action to execute"

    if($Selection -eq "0")
    {
      $M_IS_Running = $False
    }
    elseif($Selection -eq "s")
    {
      $M_IS_Running = $False

      Install_Main($InstallServers)
    }
    elseif($Selection -eq "q")
    {
      $M_IS_Running = $False
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
  [VDrive]::Path = "E:\VM\HDD\"

  $ServerConfigs = GetServerTable

  Menu_MainMenu
}

Main
