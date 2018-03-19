##
##	Commands Used to Setup Domain Controller VM
##

#Server Config
Rename-Computer -NewName LON-DC1
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.60.40.10 -PrefixLength 24 -DefaultGateway 10.60.40.1
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddress "127.0.0.1,192.168.1.10"
#Restart System

#Active Directory
Add-WindowsFeature ad-domain-services -IncludeManagementTools
Install-ADDSForest -DomainName adatum.com -DomainNetbiosName adatum -InstallDns
#Input Safemode Admin Pass

#Firewall Rule
Get-NetFirewallRule "*remotesvc*" | Enable-NetFirewallRule