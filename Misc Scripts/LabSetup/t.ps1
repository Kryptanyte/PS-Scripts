
class VHD
{
  [String]$Name
  [String]$Type
  [UInt64]$Size
  [String]$Parent
  [Switch]$Dynamic
}

class Server
{
  [String]$Name
  [VHD[]]$VHDs
}

$vhd1 = [VHD]@{
  Name = "Test.vhdx";
  Type = "Differencing";
  Parent = "parent.vhdx";
}

$vhd2 = [VHD]@{
  Name = "Test2.vhdx";
  Type = "Differencing";
  Parent = "parent.vhdx";
}

$svr = [Server]::new()

$svr.VHDs += $vhd1

$svr.VHDs += $vhd2

$svr
