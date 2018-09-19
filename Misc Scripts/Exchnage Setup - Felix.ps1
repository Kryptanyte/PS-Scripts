
####################################################
## Exchange Lab Script - Created By Felix Saville ##
####################################################

# This scriptis designed to make The lab enviroment for StudentNet.local, This will be creating the following machines:

# Student-DC01 = 1 Core, 4GB RAM, 50GB HDD, Roles: {ADDS, DNS} IP Address: 192.168.70.10, Default Gateway: 192.168.70.1, DNS: 192.168.70.10, 192.168.70.1.
# Student-EX01 = 1 Core, 8GB RAM, 50GB HDD, Roles: {Exchange, IIS, ADLDS}, IP Address: 192.168.70.20, Defualt Gateway: 192.168.70.1, DNS: 192.168.70.10, 192.168.70.1.
# Student-RTR01 = 1 Core, 4GB RAM, 50GB HDD, Roles: {DNS, DHCP, Routing}, IP Address: 192.168.70.1, Default Gateway: 127.0.0.1, DNS: 127.0.0.1, 192.168.70.10.
# Student-Client1 = 1 Core, 4GB RAM, 50GB HDD, Roles: {RRAS} IP Address: (DHCP Handout), Default Gateway: 192.168.70.1, DNS: 192.168.70.10, 192.168.70.1.

# Student-RTR will be having DHCP configured, The range will be from 192.168.70.50 to 192.168.70.199, This will have DNS Addresses handed out through DNS,
# Aong with Default Gateway being handed out aswell with the IP Address.

# Varables will be set below, We need certain things repetatively within this script, these will help call them whenever we need them, they follow below:

##############################################
#    _                     _ _               #
#   | |                   | (_)              #
#   | |     ___   __ _  __| |_ _ __   __ _   #
#   | |    / _ \ / _` |/ _` | | '_ \ / _` |  #
#   | |___| (_) | (_| | (_| | | | | | (_| |  #
#   |______\___/ \__,_|\__,_|_|_| |_|\__, |  #
#    / ____|                          __/ |  #
#   | (___   ___ _ __ ___  ___ _ __  |___/   #
#    \___ \ / __| '__/ _ \/ _ \ '_ \         #
#    ____) | (__| | |  __/  __/ | | |        #
#   |_____/ \___|_|  \___|\___|_| |_|        #
#                                            #
##############################################


Write-Host -ForegroundColor Green  "         _             _             _             _             _             _             _             _      "
Write-Host -ForegroundColor Green  "       /\  \         |\__\         /\  \         /\__\         /\  \         /\__\         /\  \         /\  \    "
Write-Host -ForegroundColor Green  "      /::\  \        |:|  |       /::\  \       /:/  /        /::\  \       /::|  |       /::\  \       /::\  \   "
Write-Host -ForegroundColor Green  "     /:/\:\  \       |:|  |      /:/\:\  \     /:/__/        /:/\:\  \     /:|:|  |      /:/\:\  \     /:/\:\  \  "
Write-Host -ForegroundColor Green  "    /::\~\:\  \      |:|__|__   /:/  \:\  \   /::\  \ _     /::\~\:\  \   /:/|:|  |__   /:/  \:\  \   /::\~\:\  \ "
Write-Host -ForegroundColor Green  "   /:/\:\ \:\__\ ____/::::\__\ /:/__/ \:\__\ /:/\:\  /\__\ /:/\:\ \:\__\ /:/ |:| /\__\ /:/__/_\:\__\ /:/\:\ \:\__\"
Write-Host -ForegroundColor Green  "   \:\~\:\ \/__/ \::::/~~/~    \:\  \  \/__/ \/__\:\/:/  / \/__\:\/:/  / \/__|:|/:/  / \:\  /\ \/__/ \:\~\:\ \/__/"
Write-Host -ForegroundColor Green  "    \:\ \:\__\    ~~|:|~~|      \:\  \            \::/  /       \::/  /      |:/:/  /   \:\ \:\__\    \:\ \:\__\  "
Write-Host -ForegroundColor Green  "     \:\ \/__/      |:|  |       \:\  \           /:/  /        /:/  /       |::/  /     \:\/:/  /     \:\ \/__/  "
Write-Host -ForegroundColor Green  "      \:\__\        |:|  |        \:\__\         /:/  /        /:/  /        /:/  /       \::/  /       \:\__\    "
Write-Host -ForegroundColor Green  "       \/__/         \|__|         \/__/         \/__/         \/__/         \/__/         \/__/         \/__/    "
Write-Host -ForegroundColor Green  "        _              _             _                         _             _                                    "
Write-Host -ForegroundColor Green  "       /\  \         /\  \         /\  \           _         /\  \         /\  \                                  "
Write-Host -ForegroundColor Green  "      /::\  \       /::\  \       /::\  \        /\  \      /::\  \        \:\  \                                 "
Write-Host -ForegroundColor Green  "     /:/\ \  \     /:/\:\  \     /:/\:\  \       \:\  \    /:/\:\  \        \:\  \                                "
Write-Host -ForegroundColor Green  "    _\:\~\ \  \   /:/  \:\  \   /::\~\:\  \      /::\__\  /::\~\:\  \       /::\  \                               "
Write-Host -ForegroundColor Green  "   /\ \:\ \ \__\ /:/__/ \:\__\ /:/\:\ \:\__\  __/:/\/__/ /:/\:\ \:\__\     /:/\:\__\                              "
Write-Host -ForegroundColor Green  "   \:\ \:\ \/__/ \:\  \  \/__/ \/_|::\/:/  / /\/:/  /    \/__\:\/:/  /    /:/  \/__/                              "
Write-Host -ForegroundColor Green  "    \:\ \:\__\    \:\  \          |:|::/  /  \::/__/          \::/  /    /:/  /                                   "
Write-Host -ForegroundColor Green  "     \:\/:/  /     \:\  \         |:|\/__/    \:\__\           \/__/     \/__/                                    "
Write-Host -ForegroundColor Green  "      \::/  /       \:\__\        |:|  |       \/__/                                                              "
Write-Host -ForegroundColor Green  "       \/__/         \/__/         \|__|                                                                          "
Write-Host " "
Write-Host "  "
Write-Host -ForegroundColor Yellow -BackgroundColor Black "This Script Is loading, Please Wait..."
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 5%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 16%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 24%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 29%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 39%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 42%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 56%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 67%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 79%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 87%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 90%"
Start-sleep -Seconds 2 
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 96%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 97%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 98%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 98%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 99%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 99%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Loaded 99%"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Red -BackgroundColor Black "ERROR: Code 175 - Bad line Number: (1, 7,42, 120, 35), Please restart your computer"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Red -BackgroundColor Black "ERROR: Code 175 - Bad line Number: (1, 7,42, 120, 35), Please restart your computer"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Red -BackgroundColor Black "ERROR: Code 175 - Bad line Number: (1, 7,42, 120, 35), Please restart your computer"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Red -BackgroundColor Black "ERROR: Code 175 - Bad line Number: (1, 7,42, 120, 35), Please restart your computer"
Start-sleep -Seconds 1
Write-Host -ForegroundColor Green -BackgroundColor Black "Just kidding, Lets do this ;)  :P"

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Finding Virtual Disk Paths and Other Locatons..."
Start-sleep -Seconds 3
################
## Disk Paths ##
################

# Setting the Default Paths for VHDX's and Virtural Machines
Set-VMHost -VirturalhardDiskPath "F:\VHDX's\" -VirturalMachinePath "F:\Virtural Machines\"

# Path Where VHDX's will be stored
$VHDPath = "F:\VHDX's\"

Write-Host -ForegroundColor Green -BackgroundColor Black "Found Disks..."
Start-sleep -Seconds 3
###################################
### Differencing Disk Locations ###
###################################

# Server 2016 with Desktop
$DiffDesk = "F:\Differencing Disks\Lab-DTC (Desktop) (OOBE).vhdx"

# Server 2016 with Core
$DiffCOre = "F:\Differencing Disks\Lab-DTC (Non-Desktop) (OOBE).vhdx"

# Windows 10 1704
$Win10 = "F:\Differencing Disks\Lab-Win10 (OOBE)"

# Tools Disk
$DriveTools = "F:\Differencing Disks\Tools.vhdx"

##Credential And Logon Information

# Credentials For Logon / Authentication (Local Administrator and Domain Administrator)
$Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "Administrator",(ConvertTo-SecureString -String "Theman232" -AsPlainText -Force)
$DomainCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "StudentNet\Administrator",(ConvertTo-SecureString -String "Theman232" -AsPlainText -Force)

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Found Differencing Disks..."
Start-sleep -Seconds 3
Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black " Added Credentals to Script, Found Administrator Account..."
Start-sleep -Seconds 3
Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Setting and Adding Functions..."
Start-sleep -Seconds 3
#####################
### Function List ###
#####################

# Waiting For VM to start
Function WaitForVM($VMName)
{
  $Running = $True

  While ($Running)
  {
  Start-Sleep -Seconds 60
  $Running = $False

  Try
  { Test-Connection -ComputerName $VMName } 
  
  Catch {$Running = $True}
  }
}

# Create a new VHDX
Function CreateVHD($ParentPath,$DiskPath)
{
New-VHD -Path "$VHDPath$DiskPath" -Differncing -ParentPath $ParentPath
}

# Create A New Disk

Function CreateDisk($DiskPath,$SizeBytes)
{
New-VHD -Path "$VHDPath$Diskpath" -Dynamic -SizeBytes $SizeBytes
}

# Create A New Virtural Machine
Function CreateVM($Name)
{
New-VM -name $Name -MemoryStartupBytes 4GB -VHDPath "$VHDPath$Name.vhdx" -Generation 2 
}

# Modfying Configurtion of Virtural Machines (Setting Name, Memory, Stopping Checkoints, and Adding an Adapter)
Function ModifyConfig($Name)
{
Set-VM -Name $name -CheckpointType Disabled -AitomaticStartAction Nothing
Set-VMMemory -VMName $Name -DynamicMemoryEnabled $True -MinimumBytes 1GB -StartupBytes 2GB -MaximumBytes 4GB
Connect-VMNetworkAdapter -Switchname "Student 1" -VMName $Name  
}

# Setting The IP Address of the Virtural Machines using "Invoke-Command", Naming the Computer, Adding to StudentNet.Local Domain and restarting to save changes.

Function IPConfig($VMName,$IPAddress,$DNSaddress)
{
Invoke-Command -VMName $VMName -Credential $Cred {New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "$IPAddress" -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "$DNSAddresses"; Add-Computer -DomainName StudentNet.local -Credential $DomainCred; Rename-Computer -NewName "$VMName"; Restart-Computer}
}

# Starting Up Virtural Machines, Waiting for them, Using "IPConfig" Function for IPAddressing, DNS Addressing, Domain Joining, and Restarting
Function StartVM($VMName,$IPAddress,$DNSAddresses)
{
Write-Color -Color Yellow "Virtual Machine Name: $VMName, IP Address: $IPAddress, DNS Addresses: $DNSAddresses"
Start-VM -Name $VMName -Verbose | VMConnect localhost $VMName
Write-Color -Color Green "Starting $VMName, Opening Window, Please Go Through Out-Of-Box Experence before Contiuning"
Write-Color -Color Green "This Virtural Machine Will Need The Password 'Theman232' in order for this script to work correctly"
Write-Color -Color Yellow "Make Sure All The Configuration of 'Out-Of-Box Experence' Is Set Correctly Before Pressing A Key"
Pause
IPConfig $VMName $IPAddress $DNSAddresses 
}

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Functions Added! Starting Machines..."
Start-sleep -Seconds 3

#########################
### Creating Switches ###
#########################

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Creating Virtural Switches, Please Wait..."


# Creating the External Swtch
New-VMSwitch -Name External -NetAdapterName "Ethernet 1"

# Creating the Internal Siwtch 
New-VMSwitch -Name External -SwitchType Internal

Write-Host " "
Write-Host " "
Start-sleep -Seconds 5
Write-Host -ForegroundColor Green -BackgroundColor Black "Switches Created..."

########################################
### Creating Virtural Machine Disk's ###
########################################

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Creating Virtural Machines, This May Take Awhile..."
Start-sleep -Seconds 5

# Creating Exhange Server
CreateVHD $DiffDesk "Student-EX01"

# Creating A Clinet Machine 
CreateVHD $DiffDesk "Student-CLIENT01"

# Creating An Administraor PC for remote management
CreateVHD $DiffDesk "Student-ADMIN01"

# Creating A Domain Controller for ADDS
CreateVHD $DiffDesk "Student-DC01"

# Creating A Router for the Default Gateway



Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Green -BackgroundColor Black "Created EX01, CLIENT01, ADMIN01, DC01 and RTR..."
Start-sleep -Seconds 5










