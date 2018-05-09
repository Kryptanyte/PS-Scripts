Param(
	[Parameter(Mandatory = $True)]
	[string]$InputString,

	[Parameter(Mandatory = $False)]
	[string]$EncryptionKey,
	[int]$EncryptionMulti,
	[switch]$SumString = $False,
	[switch]$Decode = $False
)

function StrToCodes
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$ToConvert
	)

	$CharArr = $ToConvert.ToCharArray()
	$ReturnArr = [System.Collections.ArrayList]@()

	Foreach($char in $CharArr)
	{
		$ReturnArr.Add(([int][char]$char)) > $null
	}

	return $ReturnArr
}

function SumArr
{
	Param(
		[Parameter(Mandatory = $True)]
		$Arr
	)

	$Sum = 0

	$Arr | Foreach { $Sum += $_ }

	return $Sum
}

function GetMulti
{
	$Multiplier = 1

	if($EncryptionMulti -eq 0)
	{
		if($EncryptionKey -ne "")
		{
			$Multiplier = SumArr((StrToCodes($EncryptionKey)))

			$Enc = $True
		}
	}
	elseif($EncryptionMulti -gt 1)
	{
		$Multiplier = $EncryptionMulti
	}

	return $Multiplier
}

function Encode
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$RawString
	)

	$EncodedArr = StrToCodes($RawString)
	$Multi = GetMulti

	$EncryptedArr = [System.Collections.ArrayList]@()

	Foreach($Value in $EncodedArr)
	{
		$EncryptedArr.Add(($Value * $Multi)) > $null
	}

	return ($EncryptedArr -join " ")
}

function Decode
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$RawString
	)

	$EncodedArr = $RawString.Split(" ")
	$Multi = GetMulti

	$StringArr = [System.Collections.ArrayList]@()

	Foreach($Value in $EncodedArr)
	{
		$StringArr.Add(([char][int]($Value / $Multi))) > $null
	}

	return ($StringArr -join "")
}

function Main
{
	if($Decode)
	{
		$DecodedStr = Decode($InputString)

		Write-Host $DecodedStr
	}
	elseif($SumString)
	{
		$Multi = GetMulti
		$CodeArr = [System.Collections.ArrayList]@()
	  (StrToCodes($InputString)) | Foreach {$CodeArr.Add(($_ * $Multi))} > $null
		Write-Host (SumArr($CodeArr))
	}
	else
	{
		$EncodedStr = Encode($InputString)

		Write-Host $InputString
		Write-Host $EncodedStr
	}
}

Main
