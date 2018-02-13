##########################################################################
##	Script		: VMFromCSV 1.2											##
##	Author		: Ryan Fournier										 	##
##	Date Created: 01/12/2017											##
##  Date Updated: 18/01/2018											##
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
##  -VHDPath: Relative path of drives from VMDir or Absolute file path. ##
##							[Default = "Drives"]  						##
## 		-EnableAutoStart: Enables Auto Start, if CSV has enabled.		##
## 		 		  -BeVerbose: Enables Verbose Writing.					##
##																		##		
##########################################################################

##  TODO ##
#
# Fix default VM dir + drive path
# Extend config to include other VM config options
# Support multiple file structures, e.g. JSON (ConvertTo-Json/ConvertFrom-Json) or drop csv entirely
#   - Expand to export vm configuration to file.

Param(
	#Required Params
	[Parameter(Mandatory = $True)]
	[string]$CSVFile,
	
	#Optional Params
	[Parameter(Mandatory = $False)]
	[string]$VMDir="H:\VMS",
	[string]$VHDDir="Drives",
	[switch]$EnableAutoStart = $False,
	[switch]$BeVerbose = $False
)

#Global Script Variables
$FilePathRegex = "^(?:[a-zA-Z]:\\)(?:.*)(?:\\?)$"

#Check if String Input is an Absolute Filepath
function IsFullPath
{
	Param(
		[Parameter(Mandatory = $True)]
		$Path
	)
	
	return ([regex]::Match($Path, $FilePathRegex).Captures.Success)
}

function CreateVMS
{	
	#Allow Verbose Output it -BeVerbose
	if($BeVerbose)
	{
		$VerbosePreference = "Continue"
	}
	
	#Check if VM path is valid
	if(-not IsFullPath($VMDir))
	{
		#Display Error Message
		Write-Error -Message "Invalid VM File Path!" -Category ReadError -CategoryActivity "Path Validation" -CategoryReason "File Path Invalid" -CategoryTargetName $VMDir
	}
	
	#Check if VHD path is full path or relative
	if(IsFullPath($VHDDir))
	{
		#Assign full path to VHDPath
		$VHDPath = $VHDDir
	}
	else
	{
		#Prevent double backslash
		$VMDir.Trim('\')
		$VHDDir.Trim('\')
		
		#Build relative VHDPath
		$VHDPath = $VMDir + '\' + $VHDDir + '\'
	}
	
	#Import CSV File
	$csv = Import-Csv $CSVFile

	foreach($VMObj in $csv)
	{		
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
			MemoryStartUpBytes = $VMObj.StartMem
			SwitchName = $VMObj.SwitchType
			NewVHDPath = $VHDPath+$VMObj.VMName+"-OS_Drive.vhdx"
			NewVHDSize = $VMObj.OSDriveSize
			
			#Non Config Options
			Path = $VMDir
			ErrorAction = 'Stop'
			Verbose = $False
		}
		
		#VM Extra Parameters
		$ExtraVMParams = @{
			#CSV Config Options
			ProcessorCount = $VMObj.Processors
			MemoryMinimumBytes = $VMObj.MinMemory
			MemoryMaximumBytes = $VMObj.MaxMemory
			
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
			SizeBytes = $VMObj.DataDriveSize
			
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
			#Check if Data Drive size is larger than 0
			if(($DataDiskParams.Get_Item("SizeBytes") -gt 0))
			{
				#Create Data Disk
				Write-Verbose ("Creating Data Disk. Path: "+$VHDPath+$VMObj.VMName+"-Data_Drive.vhdx")
				$VHD = New-VHD @DataDiskParams
			}
			else
			{
				#Cannot create a drive with a negative or 0 size
				Write-Verbose ("Data Disk has non-positive value. Will not be created.")
			}
		}
		else
		{
			#Don't need to create disk as it exists. It can be mounted directly
			Write-Verbose ("Data Disk Exists. Skipping Creation")
		}
		
		#Create VM
		Write-Verbose ("Creating New Virtual Machine '"+$VMObj.VMName+"'")
		$VM = New-VM @NewVMParams
		
		#Set Extra VM Settings
		Write-Verbose ("Setting Extra VM Settings")
		$VM = $VM | Set-VM @ExtraVMParams 
		
        #Check if VHD has been created or not
        if(!$VHD)
        {
            #Attach Data Drive
            Write-Verbose ("Attaching Data Drive to VM '"+$VMObj.VMName+"'")
            $VM = $VM | Add-VMHardDiskDrive @AttachDriveParams
		}
        
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
