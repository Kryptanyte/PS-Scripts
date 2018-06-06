using module '.\Modules\class_server.psm1'
using module '.\Modules\class_scriptconfig.psm1'

$g_ScriptPath = $PSScriptRoot
$g_TempPath = "$g_ScriptPath\temp"

[ScriptCache]::CachePath = "$g_ScriptPath\cache"
$g_Config = [ScriptCache]::new()

$g_ServConfigs = @{}
$g_SelectedServers = [System.Collections.ArrayList]@()

Function GetNodeAtIndex
{
  Param(
    [Parameter(Mandatory = $True)]
    [Int32]$i,$a
  )

  $v = 0

  Foreach($n in $a.Values)
  {
    if($i -eq $v)
    {
      return $n
    }
      $v++
    }

    return
  }


Function SecureStringToPlainText($SecureString)
{
  <#
  From MatthewG

  URL: https://stackoverflow.com/questions/28352141/convert-a-secure-string-to-plain-text
  #>

  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
  return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

Function StringToBase64([String] $PlainText)
{
  <#
  From Sean Metcalf

  URL: https://adsecurity.org/?p=478
  #>

  $Bytes = [System.Text.Encoding]::Unicode.GetBytes($PlainText)
  return [Convert]::ToBase64String($Bytes)
}

Function ConfigHeaderMessage
{

  Clear-Host

  $AdminPass = if($g_Config.AdminPass -ne '') { 'Set' } else { 'Not Set' }

  Write-Host -ForegroundColor Green -Object @"

  Avonmore Systems Administration Course Script Configuration

  Owner Name: $($g_Config.OwnerName)
  Domain Name: $($g_Config.DomainName)
  Administrative Password: $AdminPass

"@

}

Function CreateScriptConfig
{

  while($True)
  {
    ConfigHeaderMessage

    Write-Host -ForegroundColor Cyan -Object @"

  1) Owner Name
  2) Domain Name
  3) Administrative Password

  q) Exit

"@

    $Selection = Read-Host 'Select an Option'

    if($Selection -eq "q")
    {
      break
    }
    elseif($Selection -match "^\d+$")
    {
      $Num = [Int32][String]$Selection
      switch($Num)
      {
        1 { ConfigHeaderMessage; $g_Config.OwnerName = Read-Host "Enter Owner Name" }
        2 { ConfigHeaderMessage; $g__Config.DomainName = Read-Host "Enter Domain Name" }
        3 { ConfigHeaderMessage; $g__Config.AdminPass = Read-Host "Enter Administrator Password" <#-AsSecureString#> }
      }
    }

    $g_Config.SaveConfig()

  }
}


Function GetScriptConfig
{
  if(-not (Test-Path -Path ([ScriptCache]::CachePath) -PathType Container))
  {
    if(-not (New-Item -Path ([ScriptCache]::CachePath) -ItemType Directory))
    {
      # ERROR
      exit
    }

    CreateScriptConfig
  }

  $g_Config.LoadConfig()
}

Function SetupServer
{

}

Function ListServerConfigs
{
  While($True)
  {

    ConfigHeaderMessage

    Write-Host -ForegroundColor Green -Object @"
  Selected Servers: $g_SelectedServers
"@

    $i = 1

    Foreach($Serv in $g_ServConfigs)
    {
      Write-Host $Serv
      Write-Host -ForegroundColor Cyan -Object "  $(($i++))) $($Serv.Name)"
    }

    Write-Host -ForegroundColor Cyan -Object @"

  q) Exit

"@

    $Selection = Read-Host 'Select an Option'

    if($Selection -eq "q")
    {
      break
    }
    elseif($Selection -match "^\d+$")
    {
      $Index = [Int32][String]$Selection - 1

      if(($Index -lt $g_ServConfigs.Count) -and ($Index -ge 0))
      {
        $Serv = GetNodeAtIndex $Index $g_ServConfigs

        if($g_SelectedServers.Contains($Serv.Name))
        {
          $g_SelectedServers.Remove($Serv.Name)
        }
        else
        {
          $g_SelectedServers.Add($Serv.Name)
        }

        $g_SelectedServers.Sort()
      }
    }

    #Read-Host
  }
}

Function GetServerConfigs
{
  $DirectoryList = Get-ChildItem -Path ("$g_ScriptPath\ServerConfigs") -Filter '*.pson'

  $Unsorted = @{}

  Foreach($ServConf in $DirectoryList)
  {
    $Serv = [Server]::new((gc <#Get-Content#> "$g_ScriptPath\ServerConfigs\$ServConf"| Out-String | iex <#Invoke-Expression#>))

    $Unsorted.Add($Serv.Name, $Serv) > $null
  }

  $g_ServConfigs = $Unsorted.GetEnumerator() | sort name
  $g_ServConfigs
  Read-Host 'test'
}

Function Main()
{
  GetScriptConfig
  GetServerConfigs

  While($True)
  {
    ConfigHeaderMessage

    Write-Host -ForegroundColor Cyan -Object @"

  1) Setup Server/s
  2) Edit Server Configurations
  3) Edit Script Configuration

  q) Exit

"@

    $Selection = Read-Host 'Select an Option'

    if($Selection -eq "q")
    {
      break
    }
    elseif($Selection -match "^\d+$")
    {
      $Num = [Int32][String]$Selection
      switch($Num)
      {
        1 { SetupServer }
        2 { ListServerConfigs }
        3 { CreateScriptConfig }

      }
    }
  }
}

Main
