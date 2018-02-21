# To enable Nested Virtuallisation

### This will allow us to make a virtual Machine, Inside a Virtual Machine (The good old Simulation inside a Simulation aye?)

The first command will be for finding the virtual machine name, in this example, we will be looking for DataCenter, and we will assign the name as a variable

```Powershell
$vmname = get-vm | where {$_.name -like "LON-SVR2*"}
```

After this, we will need to set the virtual machine's processor count, we will need to cores for the child Virtual Machine

```Powershell
Set-VMProcessor -VMName $vm.name -count 2 -ExposeVirtualizationExtentions $true
```

(Note: the $vm.name is the variable of the machine you selected before)

Next we will need to assign a set ammont of memory, for this example, we will use 8GB of Non-Dynamic Memory

```Powershell
Set-VMMemory -VMName $vm.name -dynamicmemoryenabled $false
```
```Powershell
set-VM -VMName $vm.name -memorystartupbytes 8GB
```

Now we will set the network adapter for the Child Virtual Machine, this will be for allowing network or internet access
```Powershell
Set-VMNetworkAdapter -VMName $vm.name -name "(Input network adapter here)" -Macaddressspoofing on
```

