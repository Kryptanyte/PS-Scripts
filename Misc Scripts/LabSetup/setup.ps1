$g_ScriptPath = $PSScriptRoot
$g_TempPath = "$g_ScriptPath\temp"

$g_Config = [ScriptCache]::new()
[ScriptCache]::CachePath = "$g_ScriptPath\cache"

class ScriptCache
{
  [String]$OwnerName
  [String]$DomainName
  [String]$AdminPass

  static [String]$CachePath

  [void] SaveConfig()
  {
    Write-Host 'Saving Config'
    $f = ''
    $this.PSObject.Properties | Foreach {
      $f += ($_.Name + "='" + $_.Value + "';")
    }

    Set-Content -Path ([ScriptCache]::CachePath +'\settings.pson') -value ('@{' + $f + '}')
  }

  [void] LoadConfig()
  {
    $file = (Get-Content ([ScriptCache]::CachePath + '\settings.pson') | Out-String | Invoke-Expression)

    $this.PSObject.Properties | Foreach {
      if($file.Contains($_.Name))
      {
        $_.Value = $file[$_.Name]
      }
    }
  }
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

  $OwnerName = $g_Config.OwnerName
  $DomainName = $g_Config.DomainName
  $AdminPass = $g_Config.AdminPass

  Write-Host -ForegroundColor Green -Object @"

  Avonmore Systems Administration Course Script Configuration

  Owner Name: $OwnerName
  Domain Name: $DomainName
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

    $Selection = Read-Host "Select an Option"

    if($Selection -eq "q")
    {
      break
    }
    else
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

  While($True)
  {
    ConfigHeaderMessage

    Write-Host -ForegroundColor Cyan -Object @"

  1) Edit Script Configuration
  2) Create Server Configuration

  q) Exit

"@

    $Selection = Read-Host "Select an Option"

    if($Selection -eq "q")
    {
      break
    }
    else
    {
      $Num = [Int32][String]$Selection
      switch($Num)
      {
        1 { CreateScriptConfig }
        2 {  }
      }
    }
  }
}

Function Main()
{
  GetScriptConfig
}

Main
