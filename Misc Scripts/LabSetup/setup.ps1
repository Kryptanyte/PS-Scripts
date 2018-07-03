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

    Write-Color -Color Red,Cyan "`n  q)"," Exit"

    $Selection = Read-Host "`nSelect an Option"

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
    Write-Color -Color Red,Cyan "  q)"," Exit"

    $Selection = Read-Host "`nSelect an Option"

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

    Write-Color -Color Red,Cyan "`n  q)"," Exit"

    $Selection = Read-Host "`nSelect an Option"

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

Function AsMB($bytes)
{
  return ($bytes / 1MB)
}

Function AsGB($bytes)
{
  return ($bytes / 1GB)
}

Function Edit-ServerConfig($Server)
{
  While($True)
  {
    Clear-Host

    Write-Color -Color Green -Text "`n  Avonmore Systems Administration Course Script Configuration`n"
    $i = 1
    $Server.PSObject.Properties | Foreach {

      if($_.Value -ne $null)
      {
        $type = $_.Value.GetType()

        if(($type -like 'string') -or ($type -like 'int'))
        {
          Write-Color -Color Red,Green,Magenta -Text "  $i) ","$($_.Name): ",$_.Value
        }
        else
        {

          if($type -like 'hashtable')
          {
            if($_.Name -eq 'Memory')
            {
              Write-Color -Color Red,Green -Text "  $i) ","$($_.Name)"

              Foreach($NodeKey in $_.Value.Keys)
              {
                Write-Color -Color DarkGreen,Yellow,DarkCyan -Text "       $($NodeKey): ","$(AsMB($_.Value[$NodeKey]))"," MB"
              }
            }
            elseif($_.Name -eq 'DSC')
            {

            }
            else
            {
              Write-Color -Color Green,Magenta -Text "  $($_.Name): ","'$type'"
            }
          }
          elseif($type -like "vdrive*")
          {
            Write-Color -Color Red,Green -Text "  $i) ","$($_.Name)"

            Foreach($Drive in $_.Value)
            {
              Write-Color -Color Green,Magenta -Text "       Name: ",$Drive.Name
              Write-Color -Color DarkGreen,Yellow -Text "         Type: ",$Drive.Type
              if($Drive.Type -eq 'Differencing')
              {
                Write-Color -Color DarkGreen,Yellow -Text "         Parent: ",$Drive.Parent
              }
              else
              {
                Write-Color -Color DarkGreen,Yellow,DarkCyan -Text "         Size: ","$(AsGB($Drive.Size))"," GB"
              }
            }
          }
          else
          {
            Write-Color -Color Green,Magenta -Text "  $($_.Name): ","'$type'"
          }
        }
      }
      else
      {
        Write-Color -Color Green,red -Text "  $($_.Name): ","Not Set"
      }

      $i++
    }

    Write-Color -Color Red,Cyan "`n  q)"," Exit"

    $Selection = Read-Host "`nSelect an Option"

  }
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
  #Get-InstalledServers

  While($True)
  {
    ConfigHeaderMessage

    Write-Color -Color Red,Cyan "  1)"," Setup Server/s"
    Write-Color -Color Red,Cyan "  2)"," Edit Server Configurations"
    Write-Color -Color Red,Cyan "  3)"," Edit Script Configuration"

    Write-Color -Color Red,Cyan "`n  q)"," Exit"

    $Selection = Read-Host "`nSelect an Option"

    if($Selection -eq "q")
    {
      break
    }
    elseif($Selection -match "^\d+$")
    {
      $Num = [Int32][String]$Selection
      switch($Num)
      {
        1 { if($g_Config.ValidateConfig()){ Setup-Server } else { Write-Color -Color Red -Text "`n  Please Configure Script Settings before installing servers.`n"; Start-Sleep -Seconds 3} }
        2 { List-ServerConfigs }
        3 { Create-ScriptConfig }

      }
    }
  }
}

Main
