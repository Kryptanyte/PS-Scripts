# To enable Nested Virturalisation

## This will allow us to make a virtural Machine, Inside a Virtural Machine (The good old Simulation inside a Simulation aye?)

#### The first command will be for finding the virtural machine name, in this example, we will be looking for DataCenter,
and we will assign the name as a varable

```Powershell
$vmname = get-vm | where {$_.name -like "LON-SVR2*"}
```

### After this, we will need to set the virtural machine's processor count, we will need to cores for the child Virtural Machine

```Powershell
Set-VMProcessor -VMName $vm.name -count 2
```

(Note: the $vm.name is the varable of the machine you selected before)

### Next we will need to assign a set ammont of memory, for this example, we will use 8GB of Dynamic Memory

```Powershell
Set-VMMemory -VMName $vm.name -dynamicmemoryenabled $false
```
```Powershell
set-VM -VMName $nm.name -memorystartupbytes 8GB
```

### Now we will set the network adapter for the Child Virtural Machine, this will be for allowing network or internet access
```Powershell
Set-VMNetworkAdapter -VMName $vm.name -name "(Imput network addapter here) -Macaddressspoffing on
```

