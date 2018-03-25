# Unsorted Commands

*Put any new commands into this file and they will be sorted and linked on the main readme*

## Set Service Principal Names - Virtual System Migration

*This will need to be done on both machines in order to have a relationship* 
*XXX - Name of Server(s)*

```Powershell
SETSPN -s "Microsoft Virtual System Migration Services/XXX" XXX
```
## Cluster Commands

*Test Cluster* 

```Powershell
Test-Cluster -Node *Enter the host machines here* -Include "Storage Space Direct",Incentory,Network,"System Configuration"
```
*New Cluster*

```Powershell
New-Cluster -Name s2dcluster -node *Enter Host Machines Here* -NoStorage -StaticAddress 192.168.1.x
```
*Setting up form drive*

```Powershell
Set-ClusterQuorum -Cluster s2dcluster -FireShareWitness \\File1\Quorum
```

*Get Cluster Network*

```Powershell
Get-ClusterNetwork -Cluster s2dcluster -Name "Cluster Network 1"
```

*Renaming Cluster Network*

```Powershell
(Get-ClusterNetwork -Cluster s2dcluster -Name "Cluster Network 1").Name = "(Whatever Name You Choose)"
```

*Enabling Cluster*

```Powershell
Enable-ClusterS2D
```

*Shwoing storage pools, and Optomizing storage Pools*

```Powershell
Get-StoragePool

Optimize-StoragePool "(Cluster Name Here)"
```

*Invoke Command to every machine for a new Switch (Hyper-V Manager)*

```Powershell
Invoke-Command -ComputerName *Enter Host Machines Here* -ScriptBlock { New-VMSwitch -Name "Production" -NetAdaptorName ethernet0 -EnableEmbeddedteaming $True -AllowManagementOS $True } 
```

*SMB Delegation - Setting up Keribos in active Directory *

```Powershell
Enable-SmbDelegation -SmbServer (File share Created) -SmbClient (The new cluster)
```

(Might Want to sort the cluster commands later)

