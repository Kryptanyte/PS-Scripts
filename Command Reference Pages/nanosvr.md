## Nano Server Creation

Import the Nano Server cmdlets

```powershell
cd <nanoserver dir>
Import-Module .\NanoServerImageGenerator\NanoServerImageGenerator
```

Create the Nano Server vhdx

```powershell
New-NanoServerImage -DeploymentType Guest -Edition Standard -MediaPath <Parent Dir of NanoServer> -TargetPath <vhdx Directory>\<name>.vhdx -ComputerName <name> -Compute -Package microsoft-nanoserver-iis-package
```

Create new VM with the vhdx

**Ignore Command**
```powershell
New-VM -Name <name> -MemoryStartupBytes 1GB -Generation 2 -VHDPath <vhdx Directory>\<name>.vhdx
```

Start VM, login and check assigned IP address (<ip>) go back to main menu and enable winrm

In a powershell windows (admin) run command

```powershell
djoin /provision /domain <domainname> /machine <name> /savefile D:\odjblob
```

Add server to trustedhosts

```powershell
Set-Item wsman:\localhost\client\trustedhosts "<ip>"
```

Remote into server and run command

```powershell
Enter-PSSession -ComputerName <ip> -Credential <ip>\administrator

netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
```

In admin cmd on host

```bash
net use z: \\$ip\c$

copy d:\objblob z:\
```

Remote into server again with above command

```powershell
djoin /requestodj /loadfile c:\odjblob /windowspath C:\windows /localos

shutdown /r /t 5
```

Can now log into nano server with domain cred

## Making a new Nano Server with local hard drive
```powershell

Diskpart.exe
select disk 0
clean
convert GPT
Create partition efi size=100
format quick fs=fat32 label="system"
assign letter="s"
create partition msr size=128
create primary partition
format quick fs=ntfs label="NanoServer"
assign leter="N"
list volume

```
