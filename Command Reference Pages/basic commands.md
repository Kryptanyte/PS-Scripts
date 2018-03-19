# Basic Commands

### Updating Server from Powershell

```Powershell
$sess = New-CimInstance -NameSpace root/Microsft/windows/Windowsupdate -Classname MSFT_WUOperationsSession

Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates
```
