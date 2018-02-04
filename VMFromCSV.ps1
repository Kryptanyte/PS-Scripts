##########################################################################
##	Script		: VMFromCSV											 	##
##	Author		: Ryan Fournier										 	##
##	Date		: 1/12/2017											 	##
##																	 	##
##	Description	: Script to create Virtual Machines from a csv list  	##
##########################################################################
##							Copyright Notice							##
##																		##
##					Copyright (C) 2017 Ryan Fournier 					##
##																		##
##	   This script is free software: you can redistribute it and/or		##
##	  modify it under the terms of the GNU General Public License as	##
##  published by the Free Software Foundation, either version 3 of the	##
##			 License, or (at your option) any later version.			##
##																		##	
##	This script is distributed in the hope that it will be useful, but	##	
##		WITHOUT AND WARRANTY; without even the implied warranty of		##
##	  MECHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU	##
##				General Public License for more details					##	
##																		##		
##	You should have received a copy of the GNU General Public License	##
##	along with the script. If not, see <http://www.gnu.org/licenses/>.	##
##########################################################################
##								Parameters								##
##																		##
## 								 (Required)								##
## 						 -CSVFile: Path to CSV File						##
##																		##
## 								 (Optional)								##
## 	   -VMDir: Where the VMs are to be stored. [Default = "H:\VMS"] 	##
## -VHDPath: Relative path of drives from VMDir. [Default = "\Drives\"] ##
## 		-EnableAutoStart: Enables Auto Start, if CSV has enabled.		##
## 		 		  -BeVerbose: Enables Verbose Writing.					##
##																		##		
##########################################################################

Param(
	#Required Params
	[Parameter(Mandatory = $True)]
	[string]$CSVFile,
	
	#Optional Params
	[Parameter(Mandatory = $False)]
	[string]$VMDir="H:\VMS",
	[string]$VHDPath=$VMDir+"\Drives\",
	[switch]$EnableAutoStart = $False,
	[switch]$BeVerbose = $False
)

#Global Script Variables
$SizeRegex = "^(\d+(?:TB|GB|MB|KB|B))$"

#Convert String Input to Bytes. Eg 40GB String = 42949672960 Bytes
function ConvertToByte
{
	Param(
		[Parameter(Mandatory = $True)]
		$Str
	)
	
	$Factor = 0
	
	if($Str.Contains("TB")) {
		$Factor = 4
	} elseif($Str.Contains("GB")) {
		$Factor = 3
	} elseif($Str.Contains("MB")) {
		$Factor = 2
	} elseif($Str.Contains("KB")) {
		$Factor = 1
	}	
	$Size = [int]([regex]::Match($Str, "(\d+)").Captures.Groups[1].Value)
		
	return $Size*([math]::pow(1024, $Factor))
}

function GetRegexSuccess
{
	Param(
		[Parameter(Mandatory = $True)]
		$Str,
		$RegexStr
	)
	
	return -not ([regex]::Match($Str, $RegexStr) | Select -ExpandProperty Success)
}

function VerifyFields
{
	Param(
		[Parameter(Mandatory = $True)]
		$VMRow
	)
	
	if($VMRow.VMName -eq "") {return $True}
	
	if((GetRegexSuccess -Str $VMRow.StartMem -RegexStr $SizeRegex)) {return $True}
	
	if((GetRegexSuccess -Str $VMRow.MinMemory -RegexStr $SizeRegex)) {return $True}
	
	if((GetRegexSuccess -Str $VMRow.MaxMemory -RegexStr $SizeRegex)) {return $True}
	
	if($VMRow.SwitchType -eq "") {return $True}

	if((GetRegexSuccess -Str $VMRow.OSDriveSize -RegexStr $SizeRegex)) {return $True}
	
	if((GetRegexSuccess -Str $VMRow.DataDriveSize -RegexStr $SizeRegex)) {return $True}

	if($VMRow.Processors -eq "" -or (GetRegexSuccess -Str $VMRow.Processors -RegexStr "^(?:\d+)$")) {return $True}
	
	if((GetRegexSuccess -Str $VMRow.ISOPath -RegexStr "\.iso$")) {return $True}
	
	if((GetRegexSuccess -Str $VMRow.AutoStart -RegexStr "^(?:true|True|false|False)$")) {return $True}
	
	return $False
}

function CreateVMS
{	
	#Allow Verbose Output it -BeVerbose
	if($BeVerbose)
	{
		$VerbosePreference = "Continue"
	}
	
	#Import CSV File
	$csv = Import-Csv $CSVFile

	foreach($VMObj in $csv)
	{
		#Validate Row
		if(VerifyFields($VMObj))
		{
			Write-Verbose ("VMObj Error. Field in "+$CSVFile+" is Invalid")
			continue
		}
		
		#If VM Exists - Skip
		if(Get-VM($VMObj.VMName) -ErrorAction SilentlyContinue)
		{
			Write-Verbose ("Virtual Machine: "+$VMObj.VMName+" Exists! Skipping...")
			continue
		}
		
		#VM Creation Parameters
		$NewVMParams = @{
			#CSV Config Options
			Name = $VMObj.VMName
			MemoryStartUpBytes = ConvertToByte($VMObj.StartMem)
			SwitchName = $VMObj.SwitchType
			NewVHDPath = $VHDPath+$VMObj.VMName+"-OS_Drive.vhdx"
			NewVHDSize = ConvertToByte($VMObj.OSDriveSize)
			
			#Non Config Options
			Path = $VMDir
			ErrorAction = 'Stop'
			Verbose = $False
		}
		
		#VM Extra Parameters
		$ExtraVMParams = @{
			#CSV Config Options
			ProcessorCount = $VMObj.Processors
			MemoryMinimumBytes = ConvertToByte($VMObj.MinMemory)
			MemoryMaximumBytes = ConvertToByte($VMObj.MaxMemory)
			
			#Non Config Options
			DynamicMemory = $True
			PassThru = $True
			ErrorAction = 'Stop'
			Verbose = $False
		}
		
		#Data Disk Creation Parameters
		$DataDiskParams = @{
			#CSV Config Options
			Path = $VHDPath+$VMObj.VMName+"-Data_Drive.vhdx"
			SizeBytes = ConvertToByte($VMObj.DataDriveSize)
			
			#Non Config Options
			Dynamic = $True
			ErrorAction = 'Continue'
			Verbose = $False
		}
		
		#Data Disk Mounting Parameters
		$AttachDriveParams =@{
			#CSV Config Options
			Path = $VHDPath+$VMObj.VMName+"-Data_Drive.vhdx"
			
			#Non Config Options
			ControllerType = 'SCSI'
			PassThru = $True
			ErrorAction = 'Continue'
			Verbose = $False
		}
		
		#Install Disk Mounting Parameters
		$InstallDiskParams = @{
			#CSV Config Options
			VMName = $VMObj.VMName
			Path = $VMObj.ISOPath
			
			#Non Config Options
			ErrorAction = 'Stop'
			Verbose = $False
		}
		
		#Check if Data Drive exists
		if(-not (Test-Path ($VHDPath+$VMObj.VMName+"-Data_Drive.vhdx")))
		{
			#Create Data Disk
			Write-Verbose ("Creating Data Disk. Path: "+$VHDPath+$VMObj.VMName+"-Data_Drive.vhdx")
			$VHD = New-VHD @DataDiskParams
		}
		else
		{
			#Don't need to create disk as it exists. It can be mounted directly.
			Write-Verbose ("Data Disk Exists. Skipping Creation")
		}
		
		#Create VM
		Write-Verbose ("Creating New Virtual Machine '"+$VMObj.VMName+"'")
		$VM = New-VM @NewVMParams
		
		#Set Extra VM Settings
		Write-Verbose ("Setting Extra VM Settings")
		$VM = $VM | Set-VM @ExtraVMParams 
		
		#Attach Data Drive
		Write-Verbose ("Attaching Data Drive to VM '"+$VMObj.VMName+"'")
		$VM = $VM | Add-VMHardDiskDrive @AttachDriveParams
		
		#Check if ISO File Exists
		if(Test-Path $VMObj.ISOPath)
		{
			#Mount Install ISO
			Write-Verbose ("Mounting Installation ISO. Path: "+$VMObj.ISOPath)
			Set-VMDvdDrive @InstallDiskParams
		}
		else
		{
			#Display Error Message
			Write-Error -Message "ISO File does not exist!" -Category ReadError -CategoryActivity "File Exists Check" -CategoryReason "File Does Not Exists" -CategoryTargetName $VMObj.ISOPath
		}
		
		#Start VM
		if([boolean]$VMObj.AutoStart -And $EnableAutoStart) 
		{
			Write-Verbose ("Starting VM '"+$VMObj.VMName+"'")
			Get-VM -Name $VMObj.VMName | Start-VM
		}
	}
}

CreateVMS
