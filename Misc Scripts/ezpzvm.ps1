Param(
  	[Parameter(Mandatory = $True)]
    [String]$VMName,
    [String]$IPAddr,
    [Int32]$Netmask,
    [String]$Gateway,
    [String]$DNSServers,
    [String]$ComputerName,
    [String]$DomainName
)

$VM = Get-VM -VMName $VMName -Verbose

if($VM.State -ne "running")
{
  Start-VM $VM -Verbose
  Wait-VM $VM -Verbose
}

if(-not($Credential = Get-Credential -Message "Please enter Local Admin Credential"))
{
  exit
}

Write-Host -ForegroundColor Yellow "Creating PSSession"
$sess = New-PSSession -VMName $VMName -Credential $Credential -Verbose
if(-not ($sess))
{
  exit
}
else
{

  Write-Host -ForegroundColor Yellow "Entering PSSession"

  Enter-PSSession $sess -Verbose

  Write-Host -ForegroundColor Yellow "Setting IP Address"

  #New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $IPAddr -PrefixLength $Netmask -DefaultGateway $Gateway -Verbose

  netsh int ip set addr static "Ethernet" $IPAddr 255.255.255.0 $Gateway

  Write-Host -ForegroundColor Yellow "Setting DNS Addresses"

  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNSServers -Verbose

  $DomCred = Get-Credential -Message "Please enter Domain Admin Credential"

  Invoke-Command -Session $sess -ScriptBlock {Add-Computer -DomainName $DomainName -DomainCredential $DomCred -NewName $ComputerName -Verbose}

  #Restart-VM $VM

  Exit-PSSession

  Remove-PSSession $sess
}
