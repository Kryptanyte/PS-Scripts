using module '.\class_vdrive.psm1'
using module '.\class_vswitch.psm1'

Function GetBytes($s) {return (($s/1GB)*1GB)}

Class Server
{
  [String]$Name
  [Int32]$Priority
  [HashTable]$Memory
  [VDrive[]]$Drives
  [VSwitch[]]$Switches
  [HashTable]$DSC

  Server($ServerTable)
  {
    $this.Name = $ServerTable.ServerName
    $this.Priority = $ServerTable.Priority
    $this.Memory = @{Min = GetBytes($ServerTable.Memory.Min); Max = GetBytes($ServerTable.Memory.Max); Startup = GetBytes($ServerTable.Memory.Startup)}
    #Write-Host (GetBytes($ServerTable.Memory.Min))
    Foreach($Drive in $ServerTable.Drives)
    {
      $this.Drives += [VDrive]::new($Drive)
    }

    $this.DSC = $ServerTable.DSC
  }

  [void] Create()
  {
    $this.RemoveIfExists()

    New-VM -Name $this.Name -Generation 2 -MemoryStartupBytes $this.Memory.Startup

    if(($this.Memory.Max) -and ($this.Memory.Min))
    {
      Set-VMMemory -VMName $this.Name -MaximumBytes $this.Memory.Max -MinimumBytes $this.Memory.Min -DynamicMemoryEnabled $True
    }

    Foreach($drive in $this.Drives)
    {
      Add-VMHardDiskDrive -VMName $this.Name -ControllerType SCSI -Path ([VDrive]::Path + $drive.Name)
    }


  }

  [void] RemoveIfExists()
  {
    if(Get-VM -Name $this.Name)
    {
      Remove-VM -Name $this.Name
    }
  }
}
