class ScriptCache
{
  [String]$OwnerName
  [String]$DomainName
  [String]$AdminPass

  [Boolean]$Valid
  [Array]$IgnoredVars = @('Valid','IgnoredVars')

  static [String]$CachePath

  [void] SaveConfig()
  {
    Write-Host 'Saving Config'
    $f = ''
    $this.PSObject.Properties | Foreach {
      $f += ($_.Name + "='" + $_.Value + "';")
    }

    Set-Content -Path ([ScriptCache]::CachePath +'\settings.pson') -value ('@{' + $f + '}')

    $this.Valid = $this.ValidateConfig()
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

  [Boolean] ValidateConfig()
  {
    Foreach($node in $this.PSObject.Properties)
    {
      if($this.IgnoredVars.Contains($node.Name))
      {
        continue
      }

      if($node.TypeNameOfValue -eq 'System.String')
      {
        if($node.Value -eq $null)
        {
          return $False
        }
      }

      if($node.TypeNameOfValue -eq 'System.Collections.HashTable')
      {
        Foreach($e in $Node.Value)
        {
          if($e.Count -eq 0)
          {
            return $false
          }
        }
      }
    }

    return $True
  }
}
