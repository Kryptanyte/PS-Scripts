## Ou's as an Administrative Tools
#### -Allows Better Management
#### -Better Organization
#### -Delegated Administration
######   A) Limit Scope Of Mistakes/Errors
######   B) Minimize Domain Administrators

## Group as an Administrative Tools
#### Allows Users to be grouped according to:
###### A) Desired Permissions on resources (Domain Local)
###### B) Role Within Organization (Global Groups)




### Adding The Organizational Unit "Research" to your active directory
```Powershell
New-OrginisationalUnit -Name "Research" -ProtectFromAccidentialDeletion $false
```
### Creating a Organizational Unit Within Research called "Lab1"
```PowerShell
New-ADOrganizationalUnit -Name LAB1 -Path "OU=RESEARCH,DC=ADATUM,DC=COM" -ProtectedFromAccidentalDeletion $false
```
### Creating a Organizational Unit Within Research called "Lab2"
```Powershell
New-ADOrganizationalUnit -Name "LAB2" -Path "OU=LAB1,OU=RESEARCH,DC=ADATUM,DC=COM" -ProtectedFromAccidentalDeletion $false
```
### Adding a group to the Research Organizational Unregister Called "Research Tech 1"
##### Note: This group will be Global, With the setting of a Security Group within the domain
```PowerShell
New-ADGroup RESEARCHTECH1 -Path “OU=RESEARCH,DC=ADATUM,DC=COM” -GroupScope Global -GroupCategory Security
```
### Adding a Group to the Research Organizational Unit Called "Tech 1"
##### Note: This group will be Global, With the setting of a Security Group within the domain
```PowerShell
New-ADGroup TECH1 -Path “OU=LAB1,OU=RESEARCH,DC=ADATUM,DC=COM” -GroupScope Global -GroupCategory Security
```
### Adding a Group to the Research Organizational Unit Called "Tech 2"
##### Note: This group will be Global, With the setting of a Security Group within the domain
```PowerShell
New-ADGroup TECH2 -Path “OU=LAB2,OU=LAB1,OU=RESEARCH,DC=ADATUM,DC=COM” -GroupScope Global -GroupCategory Security
```
### Creating a new User Called "Jon Snow" Within the Organizational Unit "Lab 1"
##### Note: There are different parameters with this user creation, The essentials is the "Name" parameter.
##### Along with the conversion of the string for passwords, Active directory will not except plain text as a password.
```PowerShell
New-ADUser -Name “Jon Snow" -GivenName Jon -Surname Snow -SamAccountName jon.snow -UserPrincipalName jon.snow@adatum.com -path "OU=RESEARCH, DC=ADATUM, DC=com" -AccountPassword (ConvertTo-SecureString "P@ssword" -AsPlainText -Force)-Enabled $true
```
## Creating a new User Called "Jaime Lannister" Within the Organizational Unit "Lab 1"
#### Note: There are different parameters with this user creation, The essentials is the "Name" parameter.
#### Along with the conversion of the string for passwords, Active directory will not except plain text as a password.
```PowerShell
New-ADUser -Name “Jaime Lannister" -GivenName Jaime  -Surname Lannister -SamAccountName Jaime.Lannister -UserPrincipalName Jaime.Lannister@adatum.com -path "OU=LAB1,OU=RESEARCH, DC=ADATUM, DC=com" -AccountPassword (ConvertTo-SecureString "P@ssword" -AsPlainText -Force)-Enabled $true
```
## Creating a new User Called "Sansa Stark" Within the Organizational Unit "Lab 2"
#### Note: There are different parameters with this user creation, The essentials is the "Name" parameter.
#### Along with the conversion of the string for passwords, Active directory will not except plain text as a password.
```PowerShell
New-ADUser -Name “Sansa Stark" -GivenName Sansa -Surname Stark -SamAccountName Sansa.Stark -UserPrincipalName Sansa.Stark@adatum.com -path "OU=LAB2,OU=LAB1,OU=RESEARCH, DC=ADATUM, DC=com" -AccountPassword (ConvertTo-SecureString "P@ssword" -AsPlainText -Force)-Enabled $true
```
## Adding the user "Jon Snow" to the "Research Tech 1" Organization
```Powersell
Add-ADGroupMember RESEARCHTECH1 Jon.Snow
```
## Adding the user "Jamie Lannister" to the "Tech 1" Organization
```PowerShell
Add-ADGroupMember TECH1 Jaime.Lannister
```
## Adding the user "Jon Snow" to the "Research Tech 2" Organization
```PowerShell
Add-ADGroupMember TECH2 Sansa.Stark
```
