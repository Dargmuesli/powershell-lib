---
external help file: DockerLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Stop-DockerStack.md
schema: 2.0.0
---

# Stop-DockerStack

## SYNOPSIS
Stops a Docker stack.

## SYNTAX

```
Stop-DockerStack [-StackName] <String> [<CommonParameters>]
```

## DESCRIPTION
The "Stop-DockerStack" cmdlet stops a Docker stack and waits for all included containers to stop.

## EXAMPLES

### EXAMPLE 1
```
Stop-DockerStack -StackName "appstack"
```

## PARAMETERS

### -StackName
The name of the stack to is to be stopped.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Stop-DockerStack.md](https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Stop-DockerStack.md)

