---
external help file: PowerShellLib-help.xml
Module Name: PowerShell-Lib
online version: https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-Prompt.md
schema: 2.0.0
---

# Read-Prompt

## SYNOPSIS
Asks the user for his/her answer to a question.

## SYNTAX

```
Read-Prompt [-Caption] <String> [-Message] <String> [-Choices] <ChoiceDescription[]> [-DefaultChoice <Int32>]
 [-NoColors] [<CommonParameters>]
```

## DESCRIPTION
The "Read-Prompt" cmdlet prompts the user for a choice regarding a question with the given parameters.

## EXAMPLES

### EXAMPLE 1
```
$Choices = [Management.Automation.Host.ChoiceDescription[]] (
```

(New-Object Management.Automation.Host.ChoiceDescription -ArgumentList 'Docker for Windows'),
    (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList 'Docker Toolbox')
)
Read-Prompt -Caption "Docker for Windows and Docker Toolbox are installed." -Message "Which one do you want to use?" -Choices $Choices -DefaultChoice 0

## PARAMETERS

### -Caption
The caption that is to be displayed.

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

### -Message
The message that is to be displayed.

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

### -Choices
A list of "Management.Automation.Host.ChoiceDescription"s the user can choose from.

```yaml
Type: ChoiceDescription[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultChoice
The choice that is selected by default.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoColors
{{Fill NoColors Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

[https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-Prompt.md](https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-Prompt.md)

