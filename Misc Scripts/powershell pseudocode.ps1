Function WaitForVM($name)
{
  $running = $true

  while ($running)
  {
    Start-Sleep -Seconds 120
    $running = $false

    Try
    {
      Test-Connection -ComputerName $name
    } catch { $running = $true }
  }
}
