---
external help file: DockerLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Start-DockerRegistry.md
schema: 2.0.0
---

# Start-DockerRegistry

## SYNOPSIS
Starts a registry container in Docker.

## SYNTAX

```
Start-DockerRegistry [-RegistryName] <String> [-Hostname] <String> [-Port] <String> [<CommonParameters>]
```

## DESCRIPTION
Tries to start the Docker registry image and offers to install it in case it is not.

## EXAMPLES

### EXAMPLE 1
```
Start-DockerRegistry -Name "registry" -Host "localhost" -Port "8080"
```

## PARAMETERS

### -RegistryName
The registry container's name that is to be used.

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

### -Hostname
The hostname on which the registry should be available.

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

### -Port
The port on which the registry should be available.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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

[https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Start-DockerRegistry.md](https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Start-DockerRegistry.md)

