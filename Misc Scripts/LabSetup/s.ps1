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

Function GetXML([String] $Computer)
{
  if ( Test-Path "$path\Unattend.xml" ) {
      Remove-Item "$Path\Unattend.xml"
  }
  $unattendFile = New-Item "$Path\Unattend.xml" -type File

  $xmlString = @"
<?xml version='1.0' encoding='utf-8'?>
<unattend xmlns='urn:schemas-microsoft-com:unattend' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>

  <settings pass='offlineServicing'>
   <component
        xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State'
        xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
        language='neutral'
        name='Microsoft-Windows-PartitionManager'
        processorArchitecture='amd64'
        publicKeyToken='31bf3856ad364e35'
        versionScope='nonSxS'
        >
      <SanPolicy>1</SanPolicy>
    </component>
 </settings>
 <settings pass='specialize'>
    <component name='Microsoft-Windows-Shell-Setup' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
        <ComputerName>$Computer</ComputerName>
        <RegisteredOwner>$g_OwnerName</RegisteredOwner>
        <RegisteredOrganization>$g_DomainName</RegisteredOrganization>
    </component>
 </settings>
 <settings pass='oobeSystem'>
    <component name='Microsoft-Windows-Shell-Setup' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS'>
      <UserAccounts>
        <AdministratorPassword>
           <Value>$g_AdministrativePassword</Value>
           <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <SkipMachineOOBE>true</SkipMachineOOBE>
        <SkipUserOOBE>true</SkipUserOOBE>
      </OOBE>
      <TimeZone>New Zealand Standard Time</TimeZone>
    </component>
  </settings>
</unattend>

"@

  Set-Content -path $unattendFile -value $xmlString

  #return the file object
  Return $unattendFile
}

Function ApplyUnattend($VHD, [String] $ComputerName)
{
  $MountPath = "D:\mountdir"
  $unattend = GetXML($ComputerName)

  Mount-WindowsImage -Path $MountPath -ImagePath $VHD.Path -Index 1
  Copy-Item -Path $unattend -Destination "$MountPath\Windows\Panther"
  Dismount-WindowsImage -Path "$MountPath" -Save
}
#$VHD = Get-VHD -Path "E:\VM\HDD\test1.vhdx"
#ApplyUnattend($VHD, "LON-DC4")
$PSScriptRoot
