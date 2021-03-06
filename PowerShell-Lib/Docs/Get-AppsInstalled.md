---
external help file: AppLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Get-AppsInstalled.md
schema: 2.0.0
---

# Get-AppsInstalled

## SYNOPSIS
Returns a list of installed apps on the current computer.

## SYNTAX

### Windows
```
Get-AppsInstalled [-SelectObjectProperty <Object>] [-SortObjectProperty <Object>] [<CommonParameters>]
```

### Linux
```
Get-AppsInstalled -PackageManager <String> [<CommonParameters>]
```

## DESCRIPTION
The "Get-AppsInstalled" cmdlet - on Windows - gets the registry's uninstall keys depending on the system's architecture.
Then it filters all subkeys by the existence of a "DisplayName" and properties given in the "SelectObjectProperty" parameter.
Finally it sorts all found apps by their "DisplayName" and returns them.
On Linux a simple package list is returned with a format dedending on each package manager.

## EXAMPLES

### EXAMPLE 1
```
Get-AppsInstalled -SelectObjectProperty @("DisplayName", "DisplayVersion") -SortObjectProperty @("DisplayName", "DisplayVersion")
```

## PARAMETERS

### -SelectObjectProperty
The properties to select.

```yaml
Type: Object
Parameter Sets: Windows
Aliases:

Required: False
Position: Named
Default value: @("DisplayName")
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortObjectProperty
The properties to sort by.

```yaml
Type: Object
Parameter Sets: Windows
Aliases:

Required: False
Position: Named
Default value: @("DisplayName")
Accept pipeline input: False
Accept wildcard characters: False
```

### -PackageManager
The package manager to use.
Defaults to automatic detection.
Currently only Pacman is supported.

```yaml
Type: String
Parameter Sets: Linux
Aliases:

Required: True
Position: Named
Default value: (Get-DefaultPackageManager)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Source: https://stackoverflow.com/a/31714410

## RELATED LINKS

[https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Get-AppsInstalled.md](https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Get-AppsInstalled.md)

