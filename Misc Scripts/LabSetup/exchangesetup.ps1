################################################################################
################################################################################
####                                                                        ####
####                        Script Created by Ryan Fournier                 ####
####                                                                        ####
####                            Copyright Notice                            ####
####                                                                        ####
####                   Copyright (C) 2018 Ryan Fournier                     ####
####                                                                        ####
####      This script is free software: you can redistribute it and/or      ####
####     modify it under the terms of the GNU General Public License as     ####
####   published by the Free Software Foundation, either version 3 of the   ####
####            License, or (at your option) any later version.             ####
####                                                                        ####    
####   This script is distributed in the hope that it will be useful, but   ####    
####       WITHOUT AND WARRANTY; without even the implied warranty of       ####
####     MECHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU    ####
####               General Public License for more details                  ####    
####                                                                        ####       
####    You should have received a copy of the GNU General Public License   ####
####    along with the script. If not, see <http://www.gnu.org/licenses/>.  ####
####                                                                        #### 
################################################################################
################################################################################
####                                                                        #### 
####       Please review configurable settings before running script,       ####
####       it is guarenteed to fail if not configured before hand.          ####
####                                                                        ####
####       Important settings to configure are the ISO Paths and the        ####
####       Hyper-V VHD Location. In it's default state, this is the         ####
####       default location in Hyper-V.                                     ####
####                                                                        ####
####       For any support or queries, contact me on discord:               ####
####       @Kryptanyte#9559                                                 ####
####                                                                        #### 
################################################################################
################################################################################

#############################################
##                                         ##
##      BEGIN OF CONFIGURABLE SECTION      ##
##                                         ##
#############################################

###############
# Server List #
###############

$g_Servers = @(
    @{
        Name = "RTR01"
        Type = "Router"
        IPAddress = ""
    },
    @{
        Name = "DC01"
        Type = "Server"
        IPAddress = "192.168.70.10"
    },
    @{
        Name = "EX01"
        Type = "Server"
        IPAddress = "192.168.70.20"
    },
    @{
        Name = "WS01"
        Type = "Client"
        IPAddress = "192.168.70.50"
    }    
)

#Windows Administrative Password
$g_AdministrativePassword = 'Pa$$w0rd'

###################
# VM Switch Names #
###################

#Name of Internal LAB Interface
$g_LanAdapter = "LAB LAN"

#Name of External/NAT Enabled Interface
$g_WanAdapter = "Classroom Network"

#########################
# Network Configuration #
#########################

#DNS Server IP
$g_DnsServer1 = '192.168.70.10'

#Gateway Address (Router)
$g_GatewayAddress = '192.168.70.1'

########################
# Hyper-V VHD Location #
########################

#Path to Hyper-V VHD folder
$g_VHDPath = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"

############################
# Differencing Disk Config #
############################

# !IMPORTANT!
# This section is for use ONLY when using differencing disks. If installing from ISOs
# Skip to the next section

#Defines usage of Differencing disks. If set to true, vhds will be created with differencing disks
$g_Differencing = $false

#Path to differencing disks
$g_DifferencingPath = "D:\Base Images"

#Server Differencing Disk Name
$g_ServerDiffDisk = "Server.vhdx"

#Client Differencing Disk Name
$g_ClientDiffDisk = "Client.vhdx"

#################
# ISO Locations #
#################

#Path of Router ISO
$g_RouterISOPath = "D:\ISOs\pfSense.iso"

#Path of Server ISO
$g_ServerISOPath = "D:\ISOs\Server_2016.iso"

#Path of Client ISO
$g_ClientISOPath = "D:\ISOs\Windows_10.iso"

######################
# Directory Settings #
######################

# !IMPORTANT!
# This section is only required when using differencing disks.
# The folder specified (by default mountdir) MUST exist before running the script

#Path to mount Windows images for unattend file injection
$g_MountPath = "D:\mountdir"

###########################################
##                                       ##
##      END OF CONFIGURABLE SECTION      ##
##                                       ##
###########################################

#Script Root
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
              <NextHopAddress>$g_GatewayAddress</NextHopAddress>
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

  $unattend = GetXML -Computer $ComputerName -IPAddress $IPAddress

  Mount-WindowsImage -Path $g_MountPath -ImagePath $VHD.Path -Index 1
  Copy-Item -Path $unattend -Destination "$g_MountPath\Windows\Panther"
  Dismount-WindowsImage -Path "$g_MountPath" -Save
}

Function CreateVHD
{
  Param(
    $Name,
    $Type
  )

  $VHD

  if($g_Differencing)
  {
    Switch($Type)
    {
        Server
        {
          $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Differencing -ParentPath "$g_DifferencingPath\$g_ServerDiffDisk" -Verbose
        }
        Client
        {
          $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Differencing -ParentPath "$g_DifferencingPath\$g_ClientDiffDisk" -Verbose
        }
        Router
        {
          $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Dynamic -SizeBytes 25GB -Verbose
        }
    }
  }
  else
  {
    $VHD = New-VHD -Path "$g_VHDPath\$Name.vhdx" -Dynamic -SizeBytes 25GB -Verbose
  }

  return $VHD
}

Function CreateVM
{
  Param(
    $Computer
  )

  $VHD = CreateVHD -Name $Computer.Name -Type $Computer.Type
  
  Switch($Computer.Type)
  {
    { ('Server','Client') -contains $_ }
    {
      New-VM -VMName $Computer.Name -MemoryStartupBytes 3GB -Generation 2 -SwitchName $g_LanAdapter -VHDPath $VHD.Path -Verbose
      
      if($g_Differencing)
      {
        ApplyUnattend -VHD $VHD -ComputerName $Computer.Name -IpAddress $Computer.IPAddress
      }
      else
      {
        Switch($Computer.Type)
        {
            Server
            {
                Add-VMDvdDrive -VMName $Computer.Name -Path $g_ServerISOPath -Verbose
            }
            Client
            {
                Add-VMDvdDrive -VMName $Computer.Name -Path $g_ClientISOPath -Verbose
            }
        }
      }
    }
    Router
    {
      New-VM -VMName $Computer.Name -MemoryStartupBytes 3GB -Generation 1 -VHDPath $VHD.Path -Verbose
      Add-VMNetworkAdapter -VMName $Computer.Name -SwitchName $g_LanAdapter -Verbose
      Add-VMNetworkAdapter -VMName $Computer.Name -SwitchName $g_WanAdapter -Verbose
      Set-VMDvdDrive -VMName $Computer.Name -Path $g_RouterISOPath -Verbose
    }
  }
}

Function ConfigureNAT
{
    
    if(Get-NetNat)
    {    
        Write-Host "`n    Existing NAT Detected. Continuing will remove this.`n"
        
        Read-Host "Press Enter to Continue"
        
        Remove-NetNat -Confirm
    }
    
    New-VMSwitch -Name $g_WanAdapter -SwitchType Internal -Verbose
    
    New-NetIpAddress -IPAddress 192.168.70.1 -PrefixLength 24 -InterfaceIndex ((Get-NetAdapter *$g_WanAdapter*).IfIndex)
    
    New-NetNat -Name $g_WanAdapter -InternalIPInterfaceAddressPrefix "$g_GatewayAddress/24"
}

Function Main
{
    Write-Host "`n    This setup will create a NAT switch. Please manually create an External switch if NAT is not desired`n"
    
    Read-Host "Press Enter to Continue"

    if(-not (Get-VMSwitch -Name $g_WanAdapter -ErrorAction SilentlyContinue))
    {
        ConfigureNAT
    }

    if(-not (Get-VMSwitch -Name $g_LanAdapter -ErrorAction SilentlyContinue))
    {
        New-VMSwitch -Name $g_LanAdapter -SwitchType Private -Verbose
    }

    $g_Servers | Foreach-Object {
        CreateVM -Computer $_
        
        Start-VM -VMName $_.Name
        
        vmconnect localhost $_.Name
        
        if($_.Type -eq "Router")
        {
            Write-Host "`n    Please install the pfSense Router before continuing.`n"
            Read-Host "Press enter to continue"
        }
    }
}

Main


