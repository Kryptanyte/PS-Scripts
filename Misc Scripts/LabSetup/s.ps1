$ta = [ordered]@{
  svr1 = '5'
  svr2 = '2'
  svr3 = '3'
}

Function GetNodeAtIndex{ Param([Parameter(Mandatory = $True)] [Int32]$i,$a) $v = 0; Foreach($n in $a.Values){ if($i -eq $v) { return $n } $v++ } return 'false' }

Write-Host (GetNodeAtIndex 0 $ta)
