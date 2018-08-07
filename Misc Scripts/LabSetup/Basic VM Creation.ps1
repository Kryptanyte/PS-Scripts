$VHDPath = "E:\VM\HDD"

New-VMSwitch -Name "Private Switch" -SwitchType Private

Function CreateVM($Name, $Parent)
{
  New-VHD -Path "$VHDPath\$Name.vhdx" -Differencing -ParentPath "$VHDPath\Base Images\$Parent.vhdx" -Verbose -ErrorAction SilentlyContinue

  New-VM -Name $Name -MemoryStartupBytes 2GB -VHDPath "$VHDPath\$Name.vhdx" -Generation 2 -SwitchName "Private Switch" -Verbose

  if($Name -eq "LON-DC1")
  {
    Set-VM -Name $Name -CheckpointType Disabled -AutomaticStartAction Start -Verbose
  }
  else
  {
    Set-VM -Name $Name -CheckpointType Disabled -AutomaticStartAction Nothing -Verbose
  }

  Set-VMMemory -VMName $Name -DynamicMemoryEnabled $True -MinimumBytes 1GB -StartupBytes 2GB -MaximumBytes 4GB -Verbose
}

Function CreateDataVHD($Name)
{
  New-VHD -Path "$VHDPath\$Name - Data.vhdx" -Dynamic -SizeBytes 25GB -Verbose

  Add-VMHardDiskDrive -VMName $Name -Path "$VHDPath\$Name - Data.vhdx" -Verbose
}

CreateVM "LON-DC1" "2016_DC_DE_23_05_2018"
CreateVM "TOR-DC1" "2016_DC_DE_23_05_2018"
CreateVM "TREY-DC1" "2016_DC_DE_23_05_2018"
CreateVM "LON-SVR1" "2016_DC_DE_23_05_2018"
CreateVM "LON-SVR2" "2016_DC_DE_23_05_2018"
CreateVM "LON-BUS" "2016_DC_DE_23_05_2018"
CreateVM "LON-DC1" "10_Education_64bit_05_06_2018"
CreateVM "BF-DC1" "2016_DC_DE_23_05_2018"
CreateVM "RF-DC1" "2016_DC_Core_22_05_2018"
CreateVM "BV-DC1" "2016_DC_Core_22_05_2018"

CreateDataVHD("LON-DC1")
CreateDataVHD("LON-BUS")
