$g_AdministrativePassword = 'Pa$$w0rd'
$g_DnsServer1 = '192.168.70.10'
$g_VHDPath = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
$g_LanAdapter = "LAB LAN"
$g_WanAdapter = "Classroom Network"

$g_ScriptPath = $PSScriptRoot

Function GetXML($Computer, $IPAddress)
{
  if ( Test-Path "$g_ScriptPath\unattend.xml" ) {
      Remove-Item "$g_ScriptPath\unattend.xml"
  }
  $unattendFile = New-Item "$g_ScriptPath\unattend.xml" -type File

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
    </component>
    <component name='Microsoft-Windows-TCPIP' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <Interfaces>
        <Interface>
          <Ipv4Settings>
            <DhcpEnabled>false</DhcpEnabled>
          </Ipv4Settings>
          <Identifier>Ethernet</Identifier>
          <UnicastIpAddresses>
            <IpAddress wcm:action='add' wcm:keyValue='1'>$IPAddress/24</IpAddress>
          </UnicastIpAddresses>
          <Routes>
            <Route wcm:action='add'>
              <Identifier>0</Identifier>
              <Prefix>0.0.0.0/0</Prefix>
              <NextHopAddress>192.168.70.1</NextHopAddress>
              <Metric>20</Metric>
            </Route>
          </Routes>
        </Interface>
      </Interfaces>
    </component>
    <component name='Microsoft-Windows-DNS-Client' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <Interfaces>
        <Interface>
          <Identifier>Ethernet</Identifier>
          <DNSServerSearchOrder>
            <IpAddress wcm:action='add' wcm:keyValue='1'>$g_DnsServer1</IpAddress>
          </DNSServerSearchOrder>
        </Interface>
      </Interfaces>
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

Function ApplyUnattend
{
  Param(
    $VHD,
    $ComputerName,
    $IPAddress
  )

  $MountPath = "B:\mountdir"
  $unattend = GetXML -Computer $ComputerName -IPAddress $IPAddress

  Mount-WindowsImage -Path $MountPath -ImagePath $VHD.Path -Index 1
  Copy-Item -Path $unattend -Destination "$MountPath\Windows\Panther"
  Dismount-WindowsImage -Path "$MountPath" -Save
}

Function CreateVHD
{
  Param(
    $Name,
    $Type
  )

  $VHD

  Switch($Type)
  {
    Server
    {
      $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Differencing -ParentPath "$g_VHDPath\Base Images\2018-08-09_Server-2016-Datacenter-DE.vhdx"
    }
    Client
    {
      $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Differencing -ParentPath "$g_VHDPath\Base Images\2018-08-23_Windows-10-Edu.vhdx"
    }
    Router
    {
      $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Dynamic -SizeBytes 25GB
    }
  }

  return $VHD
}

Function CreateVM
{
  Param(
    $ComputerName,
    $Type,
    $IPAddress
  )

  $VHD = CreateVHD -Name $ComputerName -Type $Type

  Switch($Type)
  {
    { ('Server','Client') -contains $_ }
    {
      New-VM -VMName $ComputerName -MemoryStartupBytes 3GB -Generation 2 -SwitchName $g_LanAdapter -VHDPath $VHD.Path
    }
    Router
    {
      New-VM -VMName $ComputerName -MemoryStartupBytes 3GB Generation 1 -VHDPath $VHD.Path
      Add-VMNetworkAdapter -VMName $ComputerName -SwitchName $g_LanAdapter
      Add-VMNetworkAdapter -VMName $ComputerName -SwitchName $g_WanAdapter
    }
  }
}

#ApplyUnattend -VHD $VHD -ComputerName "LON-DC4" -IPAddress "192.168.70.11"
#$PSScriptRoot

CreateVM -ComputerName 'test' -Type 'Server' -IPAddress '123'
