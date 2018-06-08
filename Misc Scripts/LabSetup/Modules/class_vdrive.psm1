Class VDrive
{
  [String]$Name
  [String]$Type
  [UInt64]$Size
  [Switch]$Dynamic = $False
  [String]$Parent

  static [String]$Path

  VDrive($Drive)
  {
    $this.Name = $Drive.Name
    $this.Type = $Drive.Type

    if($this.Type -eq "Differencing")
    {
      $this.Parent = $Drive.Parent
    }
    elseif(($this.Type -eq "Dynamically Expanding") -or ($this.Type -eq "Fixed Size"))
    {
      $this.Size = GetBytes($Drive.Size)

      if($this.Type -eq "Dynamically Expanding")
      {
        $this.Dynamic = $True
      }
    }
  }

  [Boolean] Verify()
  {
    if($this.Name -eq "")
    {
      return $False
    }

    return $True
  }

  [void] Create()
  {
    $this.RemoveIfExists()

    if($this.Type -eq "Differencing")
    {
      New-VHD -Path ([VDrive]::Path + $this.Name) -ParentPath $this.Parent -Differencing
    }
    else
    {
      if($this.Dynamic)
      {
        New-VHD -Path ([VDrive]::Path + $this.Name) -SizeBytes $this.Size -Dynamic
      }
      else
      {
        New-VHD -Path ([VDrive]::Path + $this.Name) -SizeBytes $this.Size -Fixed
      }
    }
  }

  [void] RemoveIfExists()
  {
    if(Test-Path ([VDrive]::Path + $this.Name))
    {
      Remove-Item ([VDrive]::Path + $this.Name)
    }
  }
}
