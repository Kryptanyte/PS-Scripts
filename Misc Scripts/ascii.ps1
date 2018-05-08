Param(
	[Parameter(Mandatory = $True)]
	[string]$InputString,

	[Parameter(Mandatory = $False)]
	[string]$EncryptionKey,
	[int]$EncryptionMulti,
	[switch]$Sum = $False,
	[switch]$InlineCodes = $False,
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

	ForEach($char in $CharArr)
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

	$Sum
	$Arr | Foreach {$Sum += $_}
	return $Sum
}

function Encode
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$RawString
	)

	$EncodedArr = StrToCodes($RawString)
	$Enc = $False
	$Multi

	if($EncryptionMulti -eq 0)
	{
		if($EncryptionKey -ne "")
		{
			$Multi = SumArr((StrToCodes($EncryptionKey)))

			$Enc = $True
		}
	}
	elseif($Multi -gt 0)
	{
		$Enc = $True
	}

	if($Enc)
	{
		Foreach($Value in $EncodedArr)
		{
			$Value = $Value * $Multi
		}
	}

	return ($EncodedArr -join " ")
}

Encode($InputString)

$EncryptionMulti

<#

if($Key -ne "")
{
	$CharArr = $Key.ToCharArray()
	$Total
	ForEach($char in $CharArr)
	{
		$code = [int][char]$char

		$Total += $code
	}

	$Multiplier = $Total
}

function Decode
{
	$CodeArr = $ToConvert.Split(" ")
	$StrArr = [System.Collections.ArrayList]@()

	ForEach($code in $CodeArr)
	{
		if($Multiplier -gt 0)
		{
			$code = ($code / $Multiplier)
		}

		$char = [char][int]$code

		$StrArr.Add($char) > $null
	}

	Write-Host -ForegroundColor Yellow ($StrArr -Join "")

}

function Encode
{
	$CharArr = $ToConvert.ToCharArray()
	$CodeArr = [System.Collections.ArrayList]@()
	$CodeStr = ""
	$Total = 0

	foreach($char in $CharArr)
	{
		$code = [int][char]$char

		if($Multiplier -gt 0)
		{
			$code = $code * $Multiplier
		}

		if($SumChar)
		{
			$Total += $code
		}

		$CodeArr.Add($code) > $null

		if($CodeStr -eq "")
		{
			$CodeStr = [string]$code
		}
		else
		{
			$CodeStr = $CodeStr + " " + [string]$code
		}
	}

	if($InlineCodes)
	{
		Write-Host -ForegroundColor Yellow $ToConvert
		Write-Host -ForegroundColor Green $CodeStr
	}
	elseif($SumChar)
	{
		Write-Host -ForegroundColor Yellow $Total
	}
	else
	{
		For($i = 0; $i -lt $CharArr.Length; $i++)
		{
			Write-Color -Text ($CharArr[$i]), " | ", ($CodeArr[$i]) -Color Yellow,White,Green
		}
	}
}

if($Decode)
{
	Decode
}
else
{
	Encode
}
#>
