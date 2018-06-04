class ScriptCache
{
  [String]$OwnerName
  [String]$DomainName
  [String]$AdminPass

  static [String]$CachePath

  [void] SaveConfig()
  {
    Write-Host 'Saving Config'
    $f = ''
    $this.PSObject.Properties | Foreach {
      $f += ($_.Name + "='" + $_.Value + "';")
    }

    Set-Content -Path ([ScriptCache]::CachePath +'\settings.pson') -value ('@{' + $f + '}')
  }

  [void] LoadConfig()
  {
    $file = (Get-Content ([ScriptCache]::CachePath + '\settings.pson') | Out-String | Invoke-Expression)

    $this.PSObject.Properties | Foreach {
      if($file.Contains($_.Name))
      {
        $_.Value = $file[$_.Name]
      }
    }
  }
}
