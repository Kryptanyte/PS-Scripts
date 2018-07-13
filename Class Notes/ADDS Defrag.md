# ADDS Database Degragmentation

**The following process is to be performed in an elevated (Administrative) command prompt**

*Stop the AD DS Service before defragmentation*

```
net stop ntds
```

*Open __ntdsutil__ and activate the NTDS instance*

```
ntdsutil

activate instance ntds
```

*Enter the __files__ shell*

```
files
```

*Run the defragmentation of the database. `{location}` is the output location for the defragmented database*

```
compact to {location}
```

__*Example*__

```
compact to C:\Compacted
```

*Verify the __integrity__ of the database*

```
integrity
```

*Quit out of the ntdsutil*

```
quit

quit
```

*__copy__ the defragmented database to the AD DS directory and remove the __.log__ files. {adds location} is the directory of the active directory database*

```
copy "{location}\ntds.dit" "{adds location}\ntds.dit"

del "{adds location}\*.log"
```

__*Example*__

```
copy "C:\Compacted\ntds.dit" "C:\Windows\NTDS\ntds.dit"

del "C:\Windows\NTDS\*.log"
```

*Restart the ADDS Service*

```
net start ntds
```

### *Optional*
*Delete the folder that was created by the Defragmentation Process*

```
del {location}
```

__*Example*__

```
del C:\Compacted
```