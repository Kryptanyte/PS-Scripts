### Credit - Felix Saville
### This Script has been tested in a production enviroment and does work, but needs more editing,
### Looking at making this all one script that E-Mails the users with a pre-made outlook template.
### In production use, this script would email me a listg of the users that have expiring passwords (Ether expired or the next 29 days untill)

Param (
	[string]$Path = "\\TLFILE1\Groupdata\IT\Check - Users passwords to expire (End Of Year)",
	[int]$Age = 29,
    [string]$SearchBase = "OU=Users",
	[string]$From = "itstatus@tll.co.nz",
	[string]$To = "felix.saville@tll.co.nz",
	[string]$SMTPServer = "mail.tll.co.nz"
)


cls
$Result = @()



$maxPasswordAgeTimeSpan = $null
$dfl = (get-addomain).DomainMode
$maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
If ($maxPasswordAgeTimeSpan -eq $null -or $maxPasswordAgeTimeSpan.TotalMilliseconds -eq 0) 
{	Write-Host "MaxPasswordAge is not set for the domain or is set to zero!"
	Write-Host "So no password expiration's possible."
	Exit
}


$Users = Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -properties GivenName,sn,PasswordExpired,PasswordLastSet,PasswordneverExpires,LastLogonDate
ForEach ($User in $Users)
{	If ($User.PasswordNeverExpires -or $User.PasswordLastSet -eq $null)
	{	Continue
	}
	If ($dfl -ge 3) 
	{	## Greater than Windows2008 domain functional level
		$accountFGPP = $null
		$accountFGPP = Get-ADUserResultantPasswordPolicy $User
    	If ($accountFGPP -ne $null) 
		{	$ResultPasswordAgeTimeSpan = $accountFGPP.MaxPasswordAge
    	} 
		Else 
		{	$ResultPasswordAgeTimeSpan = $maxPasswordAgeTimeSpan
    	}
	}
	Else
	{	$ResultPasswordAgeTimeSpan = $maxPasswordAgeTimeSpan
	}
	$Expiration = $User.PasswordLastSet + $ResultPasswordAgeTimeSpan
	If ((New-TimeSpan -Start (Get-Date) -End $Expiration).Days -le $Age)
	{	$Result += New-Object PSObject -Property @{
			'Last Name' = $User.sn
			'First Name' = $User.GivenName
			UserName = $User.SamAccountName
			'Expiration Date' = $Expiration
			'Last Logon Date' = $User.LastLogonDate
			State = If ($User.Enabled) { "" } Else { "Disabled" }
		}}
}
$Result = $Result | Select 'Last Name','First Name',UserName,'Expiration Date','Last Logon Date',State | Sort 'Expiration Date','Last Name' -Descending

### Create txt File for Output
$ExportDate = Get-Date -f "yyyy-MM-dd"
$Result | Export-Csv $path\ExpiringReport-$ExportDate.txt -NoTypeInformation

#Send HTML Email to myself for results
$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@
$splat = @{
	From = $From
	To = $To
	SMTPServer = $SMTPServer
	Subject = "Password Expiration Report"
}
$Body = $Result | ConvertTo-Html -Head $Header | Out-String
Send-MailMessage @splat -Body $Body -BodyAsHTML -Attachments $Path\ExpiringReport-$ExportDate.txt
