# ADDS Snapshotting

*Requires Elevated Command Prompt*


## Create Snapshot

```
ntdsutil

activate instance ntds

snapshot

create
```

## Mounting and Navigating Snapshot

```Powershell
ntdsutil

snapshot

list all

# {guid} will be output from list all

mount {guid}

# {path} will be output from mount

quit

quit

dsamain -dbpath {path}\windows\ntds\ntds.dit -ldapport 50000
```

*Open ADUC*

*Right click on Active __Directory Users and Computers__ within the directory tree on the left and select __Change Domain Controller__*

*Double click on __<Type a Directory Server name:[port] here>__ and type in the domain controller followed by :50000*

```Powershell
# ctrl+c to cancel the dsamain

ntdsutil

activate instance ntds

quit

snapshot

unmount {guid}
```

## Delete Snapshot

```
ntdsutil

activate instance ntds

snapshot

list all

# {guid} will be output from list all

delete {guid}

quit

quit
```
