Param(
	[Parameter(Mandatory = $True)]
	[string]$ToConvert,

	[Parameter(Mandatory = $False)]
	[string]$Key = "",
	[int]$Multiplier = 0,
	[switch]$SumChar = $False,
	[switch]$InlineCodes = $False,
	[switch]$Decode = $False
)

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
