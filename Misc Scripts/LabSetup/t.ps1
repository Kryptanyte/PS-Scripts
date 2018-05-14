
class VHD
{
  [String]$Name
  [String]$Type
  [UInt64]$Size
  [String]$Parent
  [Switch]$Dynamic

  [Switch] VerifyVHD()
  {
    if($this.Name -eq "")
    {
      return $False
    }

    if($this.Type -eq "")
    {
      return $False
    }
    else
    {
      if(-not ("Fixed Size","Dynamically Expanding","Differencing").Contains($this.Type))
      {
        return $False
      }
      else
      {
        if($this.Type -eq "Differencing")
        {
          if($this.Type -eq "")
          {
            return $False
          }
          else
          {
            <#
            if(-not (Test-Path -Path $this.Name -PathType Leaf))
            {
              return $False
            }
            #>
          }
        }
      }
    }

    return $True
  }
}

class Server
{
  [String]$Name
  [VHD[]]$VHDs
  [Int32]$Generation
  [UInt64]$MinMemory
  [UInt64]$MaxMemory
  [String]$InstallISO
  [String]$Network

  [Switch] VerifyServer()
  {
    if(($this.Generation -lt 1) -or ($this.Generation -gt 2))
    {
      return $False
    }

    if(-not (Get-VMSwitch -Name $this.Switch -ErrorAction SilentlyContinue))
    {
      return $False
    }

    Foreach($VHD in $this.VHDs)
    {
      if(-not $VHD.VerifyVHD())
      {
        return $False
      }
    }
    return $True
  }

  [void] Create()
  {
    if(-not (Get-VMSwitch -Name $this.Switch -ErrorAction SilentlyContinue))
    {
      return
    }

    $VM = New-VM -Name $this.Name -Generation $this.Generation
  }
}

$svr = [Server]::new()

$svr.VHDs += [VHD]@{
  Name = "Test.vhdx";
  Type = "Differencing";
  Parent = "parent.vhdx";
}

$svr.VHDs += [VHD]@{
  Name = "Test2.vhdx";
  Type = "Differencing";
  Parent = "parent.vhdx";
}

Foreach($VHD in $svr.VHDs)
{
  $VHD.Name
}
