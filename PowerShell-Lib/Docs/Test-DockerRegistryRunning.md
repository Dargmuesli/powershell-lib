---
external help file: DockerLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-DockerRegistryRunning.md
schema: 2.0.0
---

# Test-DockerRegistryRunning

## SYNOPSIS
Checks whether Docker runs a registry container.

## SYNTAX

```
Test-DockerRegistryRunning [-Hostname] <String> [-Port] <String> [<CommonParameters>]
```

## DESCRIPTION
The "Test-DockerRegistryRunning" cmdlet tries to invoke a web request to the registry's catalog and returns true on success.

## EXAMPLES

### EXAMPLE 1
```
Test-DockerRegistryRunning -Hostname "localhost" -Port "8080"
```

## PARAMETERS

### -Hostname
The hostname the registry is supposed to run on.

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

### -Port
The port the registry is supposed to run on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-DockerRegistryRunning.md](https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-DockerRegistryRunning.md)

