# Virtual Machine Configuration

## Creating A Virtual Machine

```Powershell
New-VM -Name "(Name Of Virtual Machine)" -MemoryStartupBytes "(GB's of memory)" -SwitchName "(Your Virtual Network Adapter)" -Path "(Virtual Machine Configuration Storage Path)" -Generation 2
```

## Making A New Virtual Hard Disk
```Powershell
new-vhd -Path <Input File Path Here> -SizeBytes <Size of drive> -Dynamic <Can be Fixed, Differential>
```

## Enable Nested Virtualization

The first command will be for finding the virtual machine name, in this example, we will be looking for DataCenter, and we will assign the name as a variable

```Powershell
$vm = get-vm | where {$_.name -like "LON-SVR2"}
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

## NAT Enabled Switch

(Replace Your Router With This, Also Don't Pipe all this, just an example)

*x is your assigned subnet*

```Powershell
New-VMSwitch -SwitchName "NAT" -SwitchType Internal

New-NetIpAddress -IPAddress 10.60.x.1 -PrefixLength 24 -InterfaceIndex ((Get-NetAdapter *NAT*).IfIndex)

New-NetNat -Name Nat -InternalIPInterfaceAddressPrefix "10.60.x.0/24"
```
## Setting Network Adapters On Multiple Machines

(If you have multiple machines on one router, this is handy)

```Powershell
Get-VM -Name "Project*" | Connect-VMNetworkAdapter -Switchname Nat
```
## Setting Up A Differencing Disk

```Powershell
New-VHD -Path "(Where you want the Drive).vhdx" -ParentPath "(Where Base Disk is Located).vhdx" -Differencing
```
## Setting Up A New VM with Differencing Disk

```Powershell
New-VM -Name "(Name Of VM)" -Path "(Path Of VM Configuration)" -VHDPath "(Path Of Differencing Disk)" | ` Set-VMMemory -DynamicMemoryEnabled $True ` -MaximumBytes 2GB -Minimumbytes 512MB -StartupBytes 1GB
```
