using module '.\Modules\class_server.psm1'
using module '.\Modules\class_scriptconfig.psm1'

if(-Not (Get-Module PSWriteColor))
{
  Install-Module PSWriteColor
}

Import-Module PSWriteColor -Force

$g_ScriptPath = $PSScriptRoot
$g_TempPath = "$g_ScriptPath\temp"

[ScriptCache]::CachePath = "$g_ScriptPath\cache"
$g_Config = [ScriptCache]::new()

$g_ServConfigs = [System.Collections.ArrayList]@()

$g_InstalledServers = [System.Collections.ArrayList]@()
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

  Write-Color -Color Green -Text "`n  Avonmore Systems Administration Course Script Configuration`n"

  Write-Color -Color Green,Magenta -Text "  Owner Name: ",$($g_Config.OwnerName)
  Write-Color -Color Green,Magenta -Text "  Domain Name: ",$($g_Config.DomainName)
  Write-Color -Color Green,Magenta -Text "  Administrative Password: ",$AdminPass

  Write-Color ''
}

Function Create-ScriptConfig
{

  while($True)
  {
    ConfigHeaderMessage

    Write-Color -Color Red,Cyan "  1)"," Owner Name"
    Write-Color -Color Red,Cyan "  2)"," Domain Name"
    Write-Color -Color Red,Cyan "  3)"," Administrative Password"

    Write-Color -Color Red,Cyan "`n  q)"," Exit`n"

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
        2 { ConfigHeaderMessage; $g_Config.DomainName = Read-Host "Enter Domain Name" }
        3 { ConfigHeaderMessage; $g_Config.AdminPass = Read-Host "Enter Administrator Password" <#-AsSecureString#> }
      }
    }

    $g_Config.SaveConfig()
  }
}


Function Get-ScriptConfig
{
  if(-not (Test-Path -Path ([ScriptCache]::CachePath) -PathType Container))
  {
    if(-not (New-Item -Path ([ScriptCache]::CachePath) -ItemType Directory))
    {
      # ERROR
      exit
    }

    Create-ScriptConfig
  }

  $g_Config.LoadConfig()
  
  $g_Config.Valid = $g_Config.ValidateConfig()
}

Function Setup-Server
{
  While($True)
  {

    ConfigHeaderMessage

    Write-Color -Color Green,Magenta "  Selected Servers: ",$g_SelectedServers"`n"

    $i = 1

    Foreach($Serv in $g_ServConfigs)
    {
      Write-Color -Color Red,Cyan,Yellow -Text "  $(($i++)))"," $($Serv.Name) ",(ifcontains $g_InstalledServers $Serv.Name '[Installed]')
    }

    Write-Color -Color Red,Cyan "`n  i)"," Install"
    Write-Color -Color Red,Cyan "  q)"," Exit`n"

    $Selection = Read-Host 'Select an Option'

    if($Selection -eq "q")
    {
      break
    }
    elseif($Selection -eq "i")
    {
      #Sort-ServerPriority()

      #Create-VM()
    }
    elseif($Selection -match "^\d+$")
    {
      $Index = [Int32][String]$Selection - 1

      if(($Index -lt $g_ServConfigs.Count) -and ($Index -ge 0))
      {
        $Serv = $g_ServConfigs[$Index]

        if($g_InstalledServers.Contains($Serv.Name))
        {
          Continue
        }

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

Function Get-InstalledServers
{
  $VMList = Get-VM

  Foreach($Serv in $g_ServConfigs)
  {
    if($VMList.Name.Contains($Serv.Name))
    {
      $g_InstalledServers.Add($Serv.Name)
    }
  }
}

function ifcontains($a, $s, $t, $f='')
{
  if($a.Contains($s))
  {
    return $t
  }
  else
  {
    return $f
  }
}

Function List-ServerConfigs
{
  While($True)
  {

    ConfigHeaderMessage
    $i = 1

    Foreach($Serv in $g_ServConfigs)
    {
      Write-Color -Color Red,Cyan -Text "  $(($i++)))"," $($Serv.Name) "
    }

    Write-Color -Color Red,Cyan "`n  q)"," Exit`n"

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
        Edit-ServerConfig($g_ServConfigs[$Index])
      }
    }
    #Read-Host
  }
}

Function Edit-ServerConfig($Server)
{

}

Function Get-ServerConfigs
{
  $DirectoryList = Get-ChildItem -Path ("$g_ScriptPath\ServerConfigs") -Filter '*.pson'

  Foreach($ServConf in $DirectoryList)
  {
    $Serv = [Server]::new((gc <#Get-Content#> "$g_ScriptPath\ServerConfigs\$ServConf"| Out-String | iex <#Invoke-Expression#>))

    $g_ServConfigs.Add($Serv) > $null
  }
}

Function Main()
{
  Get-ScriptConfig
  Get-ServerConfigs
  Get-InstalledServers

  While($True)
  {
    ConfigHeaderMessage

    Write-Color -Color Red,Cyan "  1)"," Setup Server/s"
    Write-Color -Color Red,Cyan "  2)"," Edit Server Configurations"
    Write-Color -Color Red,Cyan "  3)"," Edit Script Configuration"

    Write-Color -Color Red,Cyan "`n  q)"," Exit`n"

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
        1 { if($g_Config.Valid){ Setup-Server } else { Write-Color -Color Red -Text "`n  Please Configure Script Settings before installing servers.`n"; Start-Sleep -Seconds 3} }
        2 { List-ServerConfigs }
        3 { Create-ScriptConfig }

      }
    }
  }
}

Main
