if(-not (Get-Module -ListAvailable -Name "NameIT")) {
    Write-Error -Message "NameIT module not installed. Please install this module to use this script"

    exit
}

# Module required for generation of users
Import-Module NameIT

<#

    Function to join Distinguished Name sections with the Domain DN

    Input:
        Array of DN Objects to join.

#>
function MakeDN {
    Param(
        [Parameter(Mandatory = $true)]
        $DNVar
    )
	return @(($DNVar -join ','), $g_DomainDN) -join ','
}

<#

    Function to generate Account Name in valid format (8 character length)

    Inputs:
        PSObject $User - User object passed from name generator
        Int32 $Offset - Offset of name weight. Starts at 0.

#>
function GenerateSamAccountName  {
    Param(
        [Parameter(Mandatory = $true, Position=0)]
        [PSObject]$User,
        [Parameter(Mandatory = $true, Position=1)]
        [Int32]$Offset
    )

    if($User.LastName.length -ge (8-$Offset)) {
        $SAMName = $User.LastName.Substring(0, (7-$Offset))
    } else {
        $SAMName = $User.LastName
    }

    if($User.FirstName.Length -gt $Offset) {
        $SAMName = $SAMName + ($User.FirstName.Substring(0, (1+$Offset)))
    } else {
        $SAMName = $SAMName + $User.FirstName
    }

    if($SAMName.length -gt 8) {
        Write-Error -Message "Generate SAM Account Name failed with error: Length exceeding 8 characters with name $SAMName"
    } else {
        return $SAMName.ToLower()
    }
}

<#

    Function to generate Account name that doesn't already exist in AD

    Inputs:
        PSObject $User - User object passed from name generator

#>
function ValidSamAccountName {
    Param(
        [Parameter(Mandatory = $true, Position=0)]
        [PSObject]$User
    )

    $i = 0

    Do {
        $SAMName = GenerateSamAccountName -User $User -Offset $i

        $i++
    } until ( -not (Get-ADUser -Filter {SAMAccountName -eq $SAMName }) )

    return $SAMName
}

# Domain Settings
$g_DomainDN = "DC=CONTOSSO,DC=CO,DC=NZ"
$g_UserOU = "OU=Users"

# Number of users to create in each OU
$g_UsersInOU = 20

# List of OU containers to created users in
$g_OUList = @(
    MakeDN($g_UserOU)
    MakeDN("OU=Inactive Accounts", $g_UserOU)
)

# Initialisation of generated Users
$UserList = @()

# Generate list of random Users with Invoke-Generate and format them.
Foreach($User in (Invoke-Generate (New-NameItTemplate {[PSCustomObject]@{name=""} }) -count  ($g_OUList.Count * $g_UsersInOU) -AsPSObject)) {
    $split = $User.name.split(" ")
    
    $UserList += @{ 'FirstName' = $split[0]; 'LastName' = $split[1]; 'FullName' = $User.name}
}

# Offset for UserList array
$CreationOffset = 0

# Iterate through the list of OU's to have users created in them
Foreach($ou in $g_OUList) {

    # Iterate through the UserList array and create the number of users specified by $g_UsersInOu
    For($i = $CreationOffset; $i -lt ($CreationOffset + $g_UsersInOU); $i++) {
        # Generate a valid account name
        $UserName = (ValidSamAccountName -User $UserList[$i])

        # Create the new user
        New-ADUser -SamAccountName $UserName -UserPrincipalName $UserName -GivenName $UserList[$i].FirstName -Surname $UserList[$i].LastName -Name $UserList[$i].FullName -DisplayName $UserList[$i].FullName -Path $ou -ChangePasswordAtLogon $true -Enabled $true #-WhatIf

        # Console output
        Write-Host "Created New User $UserName"
    }

    # Increase the UserList Offset
    $CreationOffset += $g_UsersInOU
}
