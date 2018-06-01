$g_OwnerName = 'L5A'
$g_DomainName = 'adatum.com'
$g_AdministrativePassword = 'Pa$$w0rd'

$g_ScriptPath = $PSScriptRoot
$g_CachePath = "$g_ScriptPath\cache"
$g_TempPath = "$g_ScriptPath\temp"

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

  Write-Host -ForegroundColor Green -Object @"

  Avonmore Systems Administration Course Script Configuration

  Owner Name: $g_OwnerName
  Domain Name: $g_DomainName
  Administrative Password: $g_AdministrativePassword

"@

}

Function LoadScriptConfigFile
{
  $file = (gc "$g_CachePath\settings.pson" | Out-String | iex)

  $file
}

Function SaveScriptConfigFile
{
  $file = "@{OwnerName = ""$g_OwnerName"";DomainName = ""$g_DomainName"";AdminPass = ""$g_AdministrativePassword"";}"
  Set-Content -Path "$g_CachePath\settings.pson" -value ($file)
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
        1 { ConfigHeaderMessage; $g_OwnerName = Read-Host "Enter Owner Name" }
        2 { ConfigHeaderMessage; $g_DomainName = Read-Host "Enter Domain Name" }
        3 { ConfigHeaderMessage; $g_AdministrativePassword = Read-Host "Enter Administrator Password" <#-AsSecureString#> }
      }
    }

    SaveScriptConfigFile

  }
}


Function GetScriptConfig
{
  if(-not (Test-Path -Path $g_CachePath -PathType Container))
  {
    if(-not (New-Item -Path $g_CachePath -ItemType Directory))
    {
      # ERROR
      exit
    }

    CreateScriptConfig
  }


}

#CreateScriptConfig
SaveScriptConfigFile
LoadScriptConfigFile
