---
external help file: ValidationLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-IPAddressValid.md
schema: 2.0.0
---

# Test-IPAddressValid

## SYNOPSIS
Checks whether an IP address is valid.

## SYNTAX

```
Test-IPAddressValid [-IPAddress] <String[]> [<CommonParameters>]
```

## DESCRIPTION
The "Test-IPAddressValid" cmdlet tries to match an IP address with a regex pattern for valid IP addresses and returns true on success.

## EXAMPLES

### EXAMPLE 1
```
Test-IPAddressValid -IPAddress "127.0.0.1"
```

## PARAMETERS

### -IPAddress
The IP address that is to be checked.

```yaml
Type: String[]
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

[https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-IPAddressValid.md](https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-IPAddressValid.md)

