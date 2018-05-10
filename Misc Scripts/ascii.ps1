<#
Script       : ascii.ps1
Author       : Ryan Fournier
Date Created : 09/05/2018
Date Updated : 10/05/2018

##########################################################################
##                            Copyright Notice                          ##
##                    Copyright (C) 2018 Ryan Fournier                  ##
##                                                                      ##
##     This script is free software: you can redistribute it and/or     ##
##    modify it under the terms of the GNU General Public License as    ##
##  published by the Free Software Foundation, either version 3 of the	##
##           License, or (at your option) any later version.            ##
##                                                                      ##
##  This script is distributed in the hope that it will be useful, but  ##
##      WITHOUT AND WARRANTY; without even the implied warranty of      ##
##    MECHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU   ##
##              General Public License for more details                 ##
##                                                                      ##
##  You should have received a copy of the GNU General Public License   ##
##########################################################################
#>

Param(
	[Parameter(Mandatory = $True)]
	[string]$InputString,

	[Parameter(Mandatory = $False)]
	[string]$EncryptionKey,
	[int]$EncryptionMulti,
	[switch]$SumString = $False,
	[switch]$Decode = $False
)

# Covert a Raw String to Array of ASCII Codes
function StrToCodes
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$ToConvert
	)

	# Covert Raw String to Character Array
	$CharArr = $ToConvert.ToCharArray()

	# Create Empty Arralist for ASCII Codes
	$ReturnArr = [System.Collections.ArrayList]@()

	# Iterate through each Character in the Character Array
	Foreach($char in $CharArr)
	{
		# Covert Character to ASCII Code and Add to ASCII Code Arraylist
		$ReturnArr.Add(([int][char]$char)) > $null
	}

	# Return ASCII Code Arralist
	return $ReturnArr
}

# Sum all Codes in Array
function SumArr
{
	Param(
		[Parameter(Mandatory = $True)]
		$Arr
	)

	# Initialise Return Sum Variable
	$Sum = 0

	# Iterate through each Code in Passed Array, add Code to Sum
	$Arr | Foreach { $Sum += $_ }

	# Return Sum of all Codes
	return $Sum
}

# Get Multiplier of Passed Encryption Key or Encryption Multiplier Value
function GetMulti
{
	# Initialise Return Multiplier Value
	$Multiplier = 1

	# If Encryption Multiplier is default
	if($EncryptionMulti -eq 0)
	{
		# Check for Encryption Key
		if($EncryptionKey -ne "")
		{
			# Sum the Encryption Key to get the final Multiplier
			$Multiplier = SumArr((StrToCodes($EncryptionKey)))
		}
	}
	# Check that Encryption Multiplier is Greater Than 1
	elseif($EncryptionMulti -gt 1)
	{
		# Set final Multiplier to Passed Encryption Multiplier
		$Multiplier = $EncryptionMulti
	}

	# Return Final Multiplier
	return $Multiplier
}

# Encode String to Encrypted ASCII Codes
function Encode
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$RawString
	)

	# Convert Raw String to ASCII Code Array
	$EncodedArr = StrToCodes($RawString)

	# Get ASCII Code Multiplier
	$Multi = GetMulti

	# Initialise Return Array for Encrypted ASCII Codes
	$EncryptedArr = [System.Collections.ArrayList]@()

	# Iterate through ASCII Code Array
	Foreach($Value in $EncodedArr)
	{
		# Multiply ASCII Code by Multiplier and add to Return Array
		$EncryptedArr.Add(($Value * $Multi)) > $null
	}

	# Join Return Array into single String
	return ($EncryptedArr -join " ")
}

# Decode ASCII Code String to Character Output
function Decode
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$RawString
	)

	# Split Raw String into Array of ASCII Codes
	$EncodedArr = $RawString.Split(" ")

	# Get ASCII Code Multiplier
	$Multi = GetMulti

	# Initialise Return Array for Decrypted Characters
	$StringArr = [System.Collections.ArrayList]@()

	# Iterate through ASCII Code Array
	Foreach($Value in $EncodedArr)
	{
		# Divide Code by Multiplier, Convert to Char and add to Return Array
		$StringArr.Add(([char][int]($Value / $Multi))) > $null
	}

	# Join Return Array into single String
	return ($StringArr -join "")
}

function Main
{
	# If -Decode Switch is specified, decode Input String
	if($Decode)
	{
		# Decode Input String
		$DecodedStr = Decode($InputString)

		# Write Decoded String to Window
		Write-Host $DecodedStr
	}

	# If -SumString Switch is specified, Sum Input String
	elseif($SumString)
	{
		# Get ASCII Code Multiplier
		$Multi = GetMulti

		# Initialise Encrypted ASCII Code Array
		$CodeArr = [System.Collections.ArrayList]@()

		# Not even going to try. TL;DR: Outputs Codes
	  (StrToCodes($InputString)) | Foreach {$CodeArr.Add(($_ * $Multi))} > $null

		# Sum Encrypted Codes and Write to Window
		Write-Host (SumArr($CodeArr))
	}

	# If no other Switches specified, Encode Input String
	else
	{
		# Encode Input String
		$EncodedStr = Encode($InputString)

		# Write Input String to Window
		Write-Host $InputString

		# Write Encoded ASCII String to Window
		Write-Host $EncodedStr
	}
}

# Call the Main Function (Entry point of Script)
Main
