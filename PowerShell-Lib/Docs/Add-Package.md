---
external help file: PowerShellLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/powershell-lib/blob/master/PowerShell-Lib/Docs/Add-Package.md
schema: 2.0.0
---

# Add-Package

## SYNOPSIS
Adds a .NET framework package to the session.

## SYNTAX

```
Add-Package [-Name] <String> [-Destination <String>]
```

## DESCRIPTION
The "Add-Package" cmdlet searches a package's .dll and imports it.

## EXAMPLES

### -------------------------- BEISPIEL 1 --------------------------
```
Add-Package -Name "YamlDotNet"
```

## PARAMETERS

### -Name
The name of the package that is to be added.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
The path that is to be searched.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Dargmuesli/powershell-lib/blob/master/PowerShell-Lib/Docs/Add-Package.md](https://github.com/Dargmuesli/powershell-lib/blob/master/PowerShell-Lib/Docs/Add-Package.md)
