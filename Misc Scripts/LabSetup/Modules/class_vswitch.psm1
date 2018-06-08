Class VSwitch
{
  [String]$Name
  [String]$Type

  VSwitch($vSwitch)
  {
    $this.Name = $vSwitch.Name
    $this.Type = $vSwitch.Type
  }

  [void] Create()
  {
    New-VMSwitch -Name $this.Name -SwitchType $this.Type
  }
}
