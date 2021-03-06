Set-StrictMode -Version Latest

<#
    .SYNOPSIS
    Adds a .NET framework package to the session.

    .DESCRIPTION
    The "Add-Package" cmdlet searches a package's .dll and imports it.

    .PARAMETER Name
    The name of the package that is to be added.

    .PARAMETER Destination
    The path that is to be searched.

    .EXAMPLE
    Add-Package -Name "YamlDotNet"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Add-Package.md
#>
Function Add-Package {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Name,

        [Parameter(Mandatory = $False)]
        [ValidateScript({Test-PathValid -Path $PSItem})]
        [String] $Destination
    )

    ForEach ($Item In $Name) {
        Add-Type -Path (Get-ChildItem -Path (Get-Item (Get-Package @PsBoundParameters).Source).Directory -Filter "$Item.dll" -Recurse -Force)[0].FullName
    }
}

<#
    .SYNOPSIS
    Converts a PSCustomObject to a hashtable.

    .DESCRIPTION
    The "Convert-PSCustomObjectToHashtable" cmdlet iterates over a PSCustomObject's properties and adds name-value pairs to a hastable that it returns.

    .PARAMETER InputObject
    The PSCustomObject that is to be converted.

    .PARAMETER YamlDotNet_DoubleQuoted
    Toggle strings to have the YamlDotNet ScaralStyle "DoubleQuoted".

    .EXAMPLE
    Convert-PSCustomObjectToHashtable -InputObject $InputObject

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Convert-PSCustomObjectToHashtable.md
#>
Function Convert-PSCustomObjectToHashtable {
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject] $InputObject,

        [Switch] $YamlDotNet_DoubleQuoted
    )

    $Hashtable = [Ordered] @{}

    $InputObject.PSObject.Properties |
        ForEach-Object {
        $InputProperty = $PSItem

        Switch ($PSItem.Value.GetType().Name) {
            {@("Hashtable", "PSCustomObject") -Contains $PSItem} {
                $Hashtable[$InputProperty.Name] = Convert-PSCustomObjectToHashtable -InputObject ([PSCustomObject] $InputProperty.Value) -YamlDotNet_DoubleQuoted:$YamlDotNet_DoubleQuoted
                Break
            }
            "String" {
                If ($YamlDotNet_DoubleQuoted) {
                    $InputProperty.Value = New-DoubleQuotedString($InputProperty.Value)
                }

                $Hashtable[$InputProperty.Name] = $InputProperty.Value
                Break
            }
            "Object[]" {
                $ObjectArray = $InputProperty.Value

                ForEach ($Item In $ObjectArray) {
                    Switch ($Item.GetType().Name) {
                        {@("Hashtable", "PSCustomObject") -Contains $PSItem} {
                            $ObjectArray = Set-ArrayItem -Array $ObjectArray -NewItem (Convert-PSCustomObjectToHashtable -InputObject $Item -YamlDotNet_DoubleQuoted:$YamlDotNet_DoubleQuoted) -OldItem $Item
                        }
                        "String" {
                            If ($YamlDotNet_DoubleQuoted) {
                                $ObjectArray = Set-ArrayItem -Array $ObjectArray -NewItem (New-DoubleQuotedString($Item)) -OldItem $Item
                            }

                            Break
                        }
                    }
                }

                $Hashtable[$InputProperty.Name] = [Object[]] $ObjectArray
                Break
            }
            Default {
                $Hashtable[$InputProperty.Name] = $InputProperty.Value
                Break
            }
        }
    }

    Return $Hashtable
}

<#
    .SYNOPSIS
    Downloads a file from a URL.

    .DESCRIPTION
    The "Get-FileFromWeb" cmdlet uses different methods to download a file from a URL and saves it to a desired location.

    .PARAMETER Url
    The URL where the requested resource is located.

    .PARAMETER LocalPath
    The path to where the requested file is to be saved to.

    .PARAMETER DownloadMethod
    The download function that is to be used.

    .EXAMPLE
    Get-FileFromWeb -Url "https://download.docker.com/win/stable/InstallDocker.msi" -LocalPath ".\"

    .NOTES
    Download method "BITS" can display its progress, but can also be delayed by other downloads.
    Download method "WebClient" cannot display its progress.
    Download method "WebRequest" can display its progress, but is very slow.

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Get-FileFromWeb.md
#>
Function Get-FileFromWeb {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateScript({Test-IRIValid -IRI $PSItem})]
        [String] $Url,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript({Test-PathValid -Path $PSItem})]
        [String] $LocalPath,

        [Parameter(Mandatory = $False)]
        [ValidateSet('BITS', 'WebClient', 'WebRequest')]
        [String] $DownloadMethod = "BITS",

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential
    )

    Switch ($DownloadMethod) {
        "BITS" {
            Import-Module BitsTransfer
            Start-BitsTransfer -Source $Url -Destination $LocalPath -Credential $Credential -Authentication "Basic"
            Break
        }
        "WebClient" {
            $WebClient = New-Object Net.WebClient
            $WebClient.DownloadFile($Url, $LocalPath)
            Break
        }
        "WebRequest" {
            Invoke-WebRequestWithProgress -Uri $Url -OutFile $LocalPath -Overwrite
            Break
        }
    }
}

<#
    .SYNOPSIS
    Ensures that a path does not already exist.

    .DESCRIPTION
    The "Initialize-TaskPath" cmdlet checks whether a path exists and, depending on the "Overwrite" flag, deletes that path or throws an error.

    .PARAMETER TaskPath
    The path that is to be checked.

    .PARAMETER Overwrite
    Whether to remove the given path.

    .EXAMPLE
    Initialize-TaskPath -TaskPath "~\Project\Output.txt"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Initialize-TaskPath.md
#>
Function Initialize-TaskPath {
    Param (
        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript({Test-PathValid -Path $PSItem})]
        [String] $TaskPath,

        [Switch] $Overwrite
    )

    If (Test-Path -Path $TaskPath) {
        If ($Overwrite) {
            Remove-Item -Path $TaskPath
        } Else {
            Throw "The path already exists and the parameter `"Overwrite`" is not passed."
        }
    }
}

<#
    .SYNOPSIS
    Installs a module only if it is not already installed.

    .DESCRIPTION
    The "Install-ModuleOnce" cmdlet checks whether a module is already installed and installs it if not.

    .PARAMETER Name
    The name of the module that is to be installed.

    .PARAMETER Scope
    The installation scope.
    Defaults to "AllUsers" when in an elevated session on Windows, to "CurrentUser" otherwise.

    .PARAMETER Force
    Whether to force the installation.

    .EXAMPLE
    Install-ModuleOnce -Name "Pester"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Install-ModuleOnce.md
#>
Function Install-ModuleOnce {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Name,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet('CurrentUser', 'AllUsers')]
        [String] $Scope,

        [Switch] $Force
    )

    Write-Verbose "Installing modules..."

    If (-Not $Scope) {
        If ((Test-IsWindows) -And (Test-AdminPermissions)) {
            $Scope = "AllUsers"
        } Else {
            $Scope = "CurrentUser"
        }
    }

    ForEach ($Item In $Name) {
        If (-Not (Get-Module -Name $Item -ListAvailable)) {
            Install-Module -Name $Item -Scope $Scope -Force:$Force
        }
    }
}

<#
    .SYNOPSIS
    Installs a package only if it is not already installed.

    .DESCRIPTION
    The "Install-PackageOnce" cmdlet checks whether a package is already installed and installs it if not.

    .PARAMETER Name
    The name of the package that is to be installed.

    .PARAMETER Destination
    The install destination.

    .PARAMETER Scope
    The installation scope.

    .PARAMETER Add
    Whether to add the package to the session.

    .PARAMETER Force
    Whether to force the installation.

    .EXAMPLE
    Install-PackageOnce -Name "YamlDotNet"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Install-PackageOnce.md
#>
Function Install-PackageOnce {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Name,

        [Parameter(Mandatory = $False)]
        [ValidateScript({Test-PathValid -Path $PSItem})]
        [String] $Destination,

        [Parameter(Mandatory = $False)]
        [ValidateSet('CurrentUser', 'AllUsers')]
        [String] $Scope,

        [Switch] $Force,

        [Switch] $Add
    )

    Write-Verbose "Installing packages..."

    $Parameters = @{}

    If ($Destination) {
        $Parameters["Destination"] = $Destination
    }

    If ($Scope) {
        $Parameters["Scope"] = $Scope
    }

    ForEach ($Item In $Name) {
        $Parameters["Name"] = $Item

        If (-Not (Get-Package @Parameters -ErrorAction SilentlyContinue)) {
            Install-Package @Parameters -Force:$Force
        }

        If ($Add) {
            Add-Package $Item
        }
    }
}

<#
    .SYNOPSIS
    Invokes an expression without causing crashes.

    .DESCRIPTION
    The "Invoke-ExpressionSafe" cmdlet Invokes the given command redirecting errors into a temporary file and other output into a variable.
    If the WithError parameter is given, the temporary file's output is appended to stdout.
    If the Graceful parameter is given and an error occurs, no exception is be thrown.

    .PARAMETER Command
    The expression to invoke safely.

    .PARAMETER WithHost
    Whether to return the host message in stdout.

    .PARAMETER WithError
    Whether to return the error message in stdout.

    .PARAMETER Graceful
    Prevents that an error is thrown.

    .EXAMPLE
    Invoke-ExpressionSafe -Command "docker swarm init --advertise-addr 'eth0:2377'" -WithError -Graceful

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Invoke-ExpressionSafe.md
#>
Function Invoke-ExpressionSafe {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Command,

        [Switch] $WithHost,
        [Switch] $WithError,
        [Switch] $Graceful
    )

    $TmpFile = New-TemporaryFile
    $Stdout = $Null

    Try {
        $Stdout = Invoke-Expression -Command "$Command 2>$TmpFile"
    } Catch {
        $PSItem > $TmpFile
    }

    $Stderr = Get-Content $TmpFile

    If (-Not $WithHost) {
        $Stdout = $Null
    }

    If ($WithError) {
        $Stdout = "${Stdout}${Stderr}"
    }

    $Stdout

    Remove-Item $TmpFile

    If ($Stderr -And (-Not $Graceful)) {
        Throw $Stderr
    }
}

<#
    .SYNOPSIS
    Download a file and displays a progress bar.

    .DESCRIPTION
    The "Invoke-WebRequestWithProgress" cmdlet creates a HttpWebRequest whose response stream is directed to a file.
    Every 10KB a progress bar showing the current download progress is displayed/updated.

    .PARAMETER Uri
    The URI of the file that is to be downloaded.

    .PARAMETER OutFile
    The path to where the file is to be saved to.

    .PARAMETER Timeout
    How long to wait for a connection success.

    .PARAMETER Overwrite
    Whether to overwrite an already existing downloaded file.

    .EXAMPLE
    Invoke-WebRequestWithProgress -Uri "https://download.docker.com/win/stable/InstallDocker.msi" -OutFile ".\"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Invoke-WebRequestWithProgress.md
#>
Function Invoke-WebRequestWithProgress {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateScript({Test-IRIValid -IRI $PSItem})]
        [Uri] $Uri,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript({Test-PathValid -Path $PSItem})]
        [String] $OutFile,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [Int] $Timeout = 15000,

        [Switch] $Overwrite
    )

    Initialize-TaskPath -TaskPath Initialize-TaskPath -Overwrite:$Overwrite

    $Request = [Net.HttpWebRequest]::Create($Uri)
    $Request.Set_Timeout($Timeout)
    $Response = $Request.GetResponse()
    $TotalLength = [Math]::Floor($Response.Get_ContentLength() / 1024)
    $ResponseStream = $Response.GetResponseStream()
    $TargetStream = New-Object -TypeName IO.FileStream -ArgumentList $OutFile, Create
    $Buffer = New-Object Byte[] 10KB
    $Count = $ResponseStream.Read($Buffer, 0, $Buffer.Length)
    $DownloadedBytes = $Count

    While ($Count -Gt 0) {
        $PercentComplete = [Convert]::ToInt32([Math]::Floor((($DownloadedBytes / 1024) / $TotalLength) * 100))
        Write-ProgressBar -PercentComplete $PercentComplete -Activity "Downloading $([Math]::Floor($DownloadedBytes / 1024))K of ${TotalLength}K"
        $TargetStream.Write($Buffer, 0, $Count)
        $Count = $ResponseStream.Read($Buffer, 0, $Buffer.Length)
        $DownloadedBytes = $DownloadedBytes + $Count
    }

    Write-Progress -Completed $True

    $TargetStream.Flush()
    $TargetStream.Close()
    $TargetStream.Dispose()
    $ResponseStream.Dispose()
}

<#
    .SYNOPSIS
    Merges two objects into one.

    .DESCRIPTION
    The "Merge-Objects" cmdlet adds all properties of the first object and the second object to a third one and returns the latter.

    .PARAMETER Object1
    The first source object.

    .PARAMETER Object2
    The second source object.

    .EXAMPLE
    Merge-Objects -Object1 @{test='123'} -Object2 @{123='test'}

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Merge-Objects.md
#>
Function Merge-Objects {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [Object] $Object1,

        [Parameter(Mandatory = $True, Position = 1)]
        [Object] $Object2
    )

    $ReturnObject = [PSCustomObject] @{}

    Foreach ($Object In @($Object1, $Object2)) {
        Foreach ($Property In $Object.PSObject.Properties) {
            $ReturnObject | Add-Member -Type NoteProperty -Name $Property.Name -Value $Property.Value -Force
        }
    }

    Return $ReturnObject
}

<#
    .SYNOPSIS
    Sets environment variable from an .env file.

    .DESCRIPTION
    The "Mount-EnvFile" cmdlet reads and parses each valid line from an .env file and sets the corresponding Windows environment variable.

    .PARAMETER EnvFilePath
    Path to the .env file that is to be mounted.

    .EXAMPLE
    Mount-EnvFile -EnvFilePath ".\.env"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Mount-EnvFile.md
#>
Function Mount-EnvFile {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateScript({Test-PathValid -Path $PSItem})]
        [String] $EnvFilePath
    )

    Get-Content $EnvFilePath |
        Select-String -Pattern "^[A-Z_]+=.+$" |
        ForEach-Object {
        $PSItem = $PSItem -Split "="
        Set-Item -Force -Path "env:$($PSItem[0])" -Value $PSItem[1]
    }
}

<#
    .SYNOPSIS
    Reads all PowerShell function names from a string.

    .DESCRIPTION
    The "Read-FunctionNames" cmdlet parses the input string and returns all findings of function names inside it.

    .PARAMETER InputString
    The string that is to be searched through.

    .EXAMPLE
    $InputString = @"
        Function X {
            $a = 1
        }
        Function Y {
            $b = 2
        }
    "@

    Read-FunctionNames -InputString $InputString

    .OUTPUTS
    Sorted by the functions' order of occurrence.

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-FunctionNames.md
#>
Function Read-FunctionNames {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $InputString
    )

    Return [System.Management.Automation.Language.Parser]::ParseInput(
        $InputString, [Ref] $Null, [Ref] $Null
    ).EndBlock.Statements.FindAll(
        [Func[Management.Automation.Language.Ast, bool]] {
            $Args[0] -Is [Management.Automation.Language.FunctionDefinitionAst]
        },
        $False
    ) |
        Select-Object -Expand Name
}

<#
    .SYNOPSIS
    Asks the user for his/her answer to a question.

    .DESCRIPTION
    The "Read-Prompt" cmdlet prompts the user for a choice regarding a question with the given parameters.

    .PARAMETER Caption
    The caption that is to be displayed.

    .PARAMETER Message
    The message that is to be displayed.

    .PARAMETER Choices
    A list of "Management.Automation.Host.ChoiceDescription"s the user can choose from.

    .PARAMETER DefaultChoice
    The choice that is selected by default.

    .EXAMPLE
    $Choices = [Management.Automation.Host.ChoiceDescription[]] (
        (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList 'Docker for Windows'),
        (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList 'Docker Toolbox')
    )
    Read-Prompt -Caption "Docker for Windows and Docker Toolbox are installed." -Message "Which one do you want to use?" -Choices $Choices -DefaultChoice 0

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-Prompt.md
#>
Function Read-Prompt {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Caption,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String] $Message,

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [Management.Automation.Host.ChoiceDescription[]] $Choices,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [Int] $DefaultChoice = 1,

        [Switch] $NoColors
    )

    If ($NoColors) {
        Return $Host.UI.PromptForChoice($Caption, $Message, $Choices, $DefaultChoice)
    } Else {
        $ForegroundColor = $Null

        If ($Host.UI.RawUI.ForegroundColor -Ne -1) {
            $ForegroundColor = $Host.UI.RawUI.ForegroundColor
        } Else {
            $ForegroundColor = "White"
        }

        Write-MultiColor -Text @("$Caption$(Get-EOLCharacter)", $Message) -Color @("Yellow", $ForegroundColor)

        Return $Host.UI.PromptForChoice($Null, $Null, $Choices, $DefaultChoice)
    }
}

<#
    .SYNOPSIS
    Displays a yes/no prompt.

    .DESCRIPTION
    The "Read-PromptYesNo" cmdlet displays a yes/no prompt and waits for the user's choice.

    .PARAMETER Caption
    The caption that is to be displayed.

    .PARAMETER Message
    The message that is to be displayed.

    .PARAMETER DefaultChoice
    The choice that is selected by default.
    Default is "No".

    .EXAMPLE
    Read-PromptYesNo -Message "Docker is not installed." -Question "Do you want to install it automatically?" -DefaultChoice 0

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-PromptYesNo.md
#>
Function Read-PromptYesNo {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Caption,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String] $Message,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [Int] $DefaultChoice = 1,

        [Switch] $NoColors
    )

    $Choices = [Management.Automation.Host.ChoiceDescription[]] (
        (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
        (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
    )

    $Decision = Read-Prompt -Caption $Caption -Message $Message -Choices $Choices -DefaultChoice $DefaultChoice -NoColors:$NoColors

    If ($Decision -Eq 0) {
        Return $True
    } Else {
        Return $False
    }
}

<#
    .SYNOPSIS
    Reads valid input.

    .DESCRIPTION
    The "Read-ValidInput" cmdlet checks the input against a script and displays a error message if the check fails.
    It loops until a valid answer can be returned.

    .PARAMETER Prompt
    A description of the input that the user is asked for.

    .PARAMETER ValidityCheck
    A script to validate the user's input.

    .PARAMETER ErrorMessage
    The error message that is shown when the validation fails.

    .EXAMPLE
    $InputPath = Read-ValidInput `
        -Prompt "The input path" `
        -ValidityCheck @(
            {Test-Path $Answer}
        ) `
        -ErrorMessage @(
            "Invalid path!"
        )

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Read-ValidInput.md
#>
Function Read-ValidInput {
    Param (
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [String] $Prompt,

        [Parameter(
            Mandatory = $True,
            Position = 1
        )]
        [ScriptBlock[]] $ValidityCheck,

        [Parameter(
            Mandatory = $True,
            Position = 2
        )]
        [String[]] $ErrorMessage
    )

    If ($ValidityCheck.Count -Ne $ErrorMessage.Count) {
        Throw "ValidityCheck and ErrorMessage count do not match!"
    }

    $Answer = $Null

    While (-Not $Answer) {
        $Answer = Read-Host -Prompt $Prompt

        For ($I = 0; $I -Lt $ValidityCheck.Count; $I++) {
            If (-Not (Invoke-Command -ScriptBlock $ValidityCheck[$I] -ArgumentList $Answer)) {
                Write-Warning -Message $ErrorMessage[$I]
                $Answer = $Null
                Break
            }
        }
    }

    Return $Answer
}

<#
    .SYNOPSIS
    Sets an array item.

    .DESCRIPTION
    The "Set-ArrayItem" cmdlet either replaces an old item with a new one or simply adds a new one to an existing array.

    .PARAMETER Array
    The array to perform the operations on.

    .PARAMETER NewItem
    The item that is to be inserted.

    .PARAMETER OldItem
    The item that is to be overridden.

    .EXAMPLE
    Set-ArrayItem -Array @(1, 3) -NewItem 2

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Set-ArrayItem.md
#>
Function Set-ArrayItem {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        $Array,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        $NewItem,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]
        $OldItem
    )

    If ($OldItem) {
        $Array[[Array]::IndexOf($Array, $OldItem)] = $NewItem
    } Else {
        $Array.Add($NewItem)
    }

    Return $Array
}

<#
    .SYNOPSIS
    Checks whether an environment variable exists.

    .DESCRIPTION
    The "Test-EnvVarExists" cmdlet checks the existence of an environment variable and returns true on success.

    .PARAMETER EnvVarName
    The environment variable's name that is to be checked.

    .EXAMPLE
    Test-EnvVarExists -EnvVarName "OS"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-EnvVarExists.md
#>
Function Test-EnvVarExists {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $EnvVarName
    )

    If (Get-ChildItem -Path "env:$EnvVarName" -ErrorAction SilentlyContinue) {
        Return $True
    } Else {
        Return $False
    }
}

<#
    .SYNOPSIS
    Checks whether a PowerShell module is installed.

    .DESCRIPTION
    The "Test-ModuleInstalled" cmdlet tries to get the desired module and return true on success.

    .PARAMETER ModuleName
    The module's name that is to be checked.

    .EXAMPLE
    Test-ModuleInstalled -ModuleName "PowerShell-Lib"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-ModuleInstalled.md
#>
Function Test-ModuleInstalled {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $ModuleName
    )

    If (Get-Module -ListAvailable -Name $ModuleName) {
        Return $True
    } Else {
        Return $False
    }
}

<#
    .SYNOPSIS
    Checks whether an object's property exists.

    .DESCRIPTION
    The "Test-PropertyExists" cmdlet checks if an object contains a property name and returns true on success.

    .PARAMETER Object
    The object that is to be checked for properties.

    .PARAMETER PropertyName
    The object's property name that is to be checked.

    .EXAMPLE
    Test-PropertyExists -Object {test='123'} -PropertyName "test"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-PropertyExists.md
#>
Function Test-PropertyExists {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [Object] $Object,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String[]] $PropertyName,

        [Switch] $PassThrough
    )

    $PropertyValue = @()
    $Type = $Object.GetType().Name

    ForEach ($Item In $PropertyName) {
        $Item = $Item.Trim(".")
        $IndexFirstDot = $Item.IndexOf(".")

        If ($Type -Eq "Hashtable") {
            If ($IndexFirstDot -Ne -1) {
                $CurrentPropertyName = $Item.Substring(0, $IndexFirstDot)
                $NextPropertyName = $Item.Substring($IndexFirstDot + 1, $Item.Length - ($IndexFirstDot + 1))

                If ($Object.Keys -Contains $CurrentPropertyName) {
                    $SubResult = Test-PropertyExists -Object $Object[$CurrentPropertyName] -PropertyName $NextPropertyName -PassThrough:$PassThrough

                    If ($SubResult) {
                        $PropertyValue += $SubResult
                    } Else {
                        Return $False
                    }
                } Else {
                    If ($PassThrough) {
                        Return $Null
                    } Else {
                        Return $False
                    }
                }
            } Else {
                If ($Object.Keys -Contains $Item) {
                    $PropertyValue += @{$Item = $Object[$Item]}
                } Else {
                    If ($PassThrough) {
                        Return $Null
                    } Else {
                        Return $False
                    }
                }
            }
        } ElseIf ($Type -Eq "PSCustomObject") {
            If ($IndexFirstDot -Ne -1) {
                $CurrentPropertyName = $Item.Substring(0, $IndexFirstDot)
                $NextPropertyName = $Item.Substring($IndexFirstDot + 1, $Item.Length - ($IndexFirstDot + 1))

                If ($Object.PSObject.Properties.Match($CurrentPropertyName).Count) {
                    $SubResult = Test-PropertyExists -Object ($Object | Select-Object -ExpandProperty $CurrentPropertyName) -PropertyName $NextPropertyName -PassThrough:$PassThrough

                    If ($SubResult) {
                        $PropertyValue += $SubResult
                    } Else {
                        Return $False
                    }
                } Else {
                    If ($PassThrough) {
                        Return $Null
                    } Else {
                        Return $False
                    }
                }
            } Else {
                If (-Not $Object.PSObject.Properties.Match($Item).Count) {
                    If ($PassThrough) {
                        Return $Null
                    } Else {
                        Return $False
                    }
                } Else {
                    $PropertyValue += $Object | Select-Object -Property $Item
                }
            }
        } Else {
            If ((($Object.GetType().Name -Ne "Hashtable") `
                        -And ($Object.GetType().Name -Ne "PSCustomObject")) `
                    -Or
                (($Object.GetType().Name -Eq "Hashtable") `
                        -And (-Not ($Object.Keys -Contains $Item))) `
                    -Or `
                (($Object.GetType().Name -Eq "PSCustomObject") -And `
                        -Not ($Object.PSObject.Properties.Name -Contains $Item))) {
                If ($PassThrough) {
                    Return $Null
                } Else {
                    Return $False
                }
            }
        }
    }

    If ($PassThrough) {
        Return $PropertyValue
    } Else {
        Return $True
    }
}

<#
    .SYNOPSIS
    Checks whether a type is loaded.

    .DESCRIPTION
    The "Test-TypeLoaded" cmdlet .

    .PARAMETER Name
    The type's name that is to be checked.

    .EXAMPLE
    Test-TypeLoaded -Name "YamlDotNet"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Test-TypeLoaded.md
#>
Function Test-TypeLoaded {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    If (([System.Management.Automation.PSTypeName]$Name).Type) {
        Return $True
    } Else {
        Return $False
    }
}

<#
    .SYNOPSIS
    Displays an indeterminate progress bar while a test is successful.

    .DESCRIPTION
    The "Wait-Test" cmdlet increases the progress bar's value in steps from 0 to 100 infinitely to provide visual feedback about a running task to the user.

    .PARAMETER Test
    The task check which needs to pass.

    .PARAMETER Activity
    A description of the running task.

    .PARAMETER Milliseconds
    The time to wait between test checks.

    .PARAMETER WithProgressBar
    Whether to display a progress bar.

    .PARAMETER Speed
    The progress bar's fill speed.

    .EXAMPLE
    Wait-Test -Test "-Not (Test-DockerRunning)" -Activity "Waiting for Docker to initialize" -WithProgressBar

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Wait-Test.md
#>
Function Wait-Test {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String] $Test,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [String] $Activity = "Processing",

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [Int] $Milliseconds = 1000,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [Int] $Speed = 5,

        [Switch] $WithProgressBar
    )

    $Index = 0

    While (Invoke-Expression -Command $Test) {
        $Index = $Index + $Speed

        If ($Index -Ge 100) {
            $Index = 0
        }

        If ($WithProgressBar) {
            Write-ProgressBar -Activity "$Activity ..." -PercentComplete $Index
        }

        Start-Sleep -Milliseconds $Milliseconds
    }

    If ($WithProgressBar) {
        Write-Progress -Completed $True
    }
}

<#
    .SYNOPSIS
    Writes an error record.

    .DESCRIPTION
    Creates a custom error record and writes a non-terminating error.

    .PARAMETER Exception
    The exception that will be associated with the error record.

    .PARAMETER ErrorId
    The error's identifier that must be a non-localized string for a specific error type.

    .PARAMETER ErrorCategory
    An error category enumeration that defines the category of the error.

    .PARAMETER TargetObject
    The object that was being processed when the error occurred.

    .PARAMETER Message
    The exception's description.

    .PARAMETER InnerException
    The exception instance that caused the exception association with the error record.

    .EXAMPLE
    $Content = Get-Content -LiteralPath $Path -ErrorAction "SilentlyContinue"

    If (-Not $Content) {
        New-ErrorRecord -Exception "InvalidOperationException" -ErrorId "FileIsEmpty" -ErrorCategory "InvalidOperation" -TargetObject $Path -Message "File '$Path' is empty." -InnerException $Error[0].Exception
    }

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Write-ErrorRecord.md

    .NOTES
    Source: https://gist.github.com/wpsmith/e8a9c54ca1c7c741b5e9
#>
Function Write-ErrorRecord {
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $Exception,

        [Parameter(Mandatory = $True, Position = 1)]
        [Alias('ID')]
        [String] $ErrorId,

        [Parameter(Mandatory = $True, Position = 2)]
        [Alias('Category')]
        [ValidateSet('NotSpecified', 'OpenError', 'CloseError', 'DeviceError',
            'DeadlockDetected', 'InvalidArgument', 'InvalidData', 'InvalidOperation',
            'InvalidResult', 'InvalidType', 'MetadataError', 'NotImplemented',
            'NotInstalled', 'ObjectNotFound', 'OperationStopped', 'OperationTimeout',
            'SyntaxError', 'ParserError', 'PermissionDenied', 'ResourceBusy',
            'ResourceExists', 'ResourceUnavailable', 'ReadError', 'WriteError',
            'FromStdErr', 'SecurityError')]
        [System.Management.Automation.ErrorCategory] $ErrorCategory,

        [Parameter(Mandatory = $True, Position = 3)]
        [Object] $TargetObject,

        [String] $Message,

        [Exception] $InnerException
    )
    Begin {
        $Exceptions = Get-AvailableExceptions
        $ExceptionList = $Exceptions -Join (Get-EOLCharacter)
    }
    Process {
        Trap [Microsoft.PowerShell.Commands.NewObjectCommand] {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        If ($Exceptions -Match "^(System\.)?$Exception$") {
            If ($Message -And $InnerException) {
                $Exception = New-Object $Exception $Message, $InnerException
            } elseif ($Message) {
                $Exception = New-Object $Exception $Message
            } else {
                $Exception = New-Object $Exception
            }

            $ErrorRecord = New-Object "Management.Automation.ErrorRecord" @($Exception, $ErrorID, $ErrorCategory, $TargetObject)
            $PSCmdlet.WriteError($ErrorRecord)
        } Else {
            Write-Warning "Available exceptions are:$(Get-EOLCharacter)$ExceptionList"

            $Message = "Exception '$Exception' is not available."
            $Exception = New-Object "System.InvalidOperationException" $Message
            $ErrorID = 'BadException'
            $ErrorCategory = 'InvalidOperation'
            $TargetObject = 'Get-AvailableExceptionsList'
            $ErrorRecord = New-Object Management.Automation.ErrorRecord $exception, $ErrorID, $ErrorCategory, $targetObject

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }
    }
}

<#
    .SYNOPSIS
    Write multicolored text.

    .DESCRIPTION
    The "Write-MultiColor" cmdlet writes indented and multicolored text to the console and optionally to a log file.

    .PARAMETER Text
    The text that is to be written.

    .PARAMETER Color
    The color in which the text is to be written.

    .PARAMETER StartTab
    The number of tabs to indent the text with.

    .PARAMETER LinesBefore
    The number of empty lines before the text.

    .PARAMETER LinesAfter
    The number of empty lines after the text.

    .PARAMETER LogFile
    The path to the log file.

    .PARAMETER TimeFormat
    The time format for logging.

    .EXAMPLE
    Write-MultiColor -Text "Red ", "Green ", "Yellow " -Color Red, Green, Yellow

    Write-MultiColor -Text "This is text in Green ",
                    "followed by Red ",
                    "and then we have Magenta... ",
                    "isn't it fun? ",
                    "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan

    Write-MultiColor -Text "This is text in Green ",
                    "followed by Red ",
                    "and then we have Magenta... ",
                    "isn't it fun? ",
                    "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan -StartTab 3 -LinesBefore 1 -LinesAfter 1

    Write-MultiColor "1. ", "Option 1" -Color Yellow, Green
    Write-MultiColor "2. ", "Option 2" -Color Yellow, Green
    Write-MultiColor "3. ", "Option 3" -Color Yellow, Green
    Write-MultiColor "4. ", "Option 4" -Color Yellow, Green
    Write-MultiColor "9. ", "Press 9 to exit" -Color Yellow, Gray -LinesBefore 1

    Write-MultiColor -LinesBefore 2 -Text "This little ","message is ", "written to log ", "file as well." -Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt" -TimeFormat "yyyy-MM-dd HH:mm:ss"
    Write-MultiColor -Text "This can get ","handy if you ", "want to display things, and log actions to file ", "at the same time." -Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt"

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Write-MultiColor.md

    .NOTES
    Source: https://stackoverflow.com/a/36519870/4682621
#>
Function Write-MultiColor {
    Param (
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [AllowEmptyString()]
        [String[]] $Text,

        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [ConsoleColor[]] $Color = "White",

        [ValidateNotNull()]
        [Int] $StartTab = 0,

        [ValidateNotNull()]
        [Int] $LinesBefore = 0,

        [ValidateNotNull()]
        [Int] $LinesAfter = 0,

        [ValidateNotNull()]
        [String] $LogFile = "",

        [ValidateNotNullOrEmpty()]
        $TimeFormat = "yyyy-MM-dd HH:mm:ss"
    )

    $DefaultColor = $Color[0]

    # Add empty line before
    If ($LinesBefore -Ne 0) {
        For ($I = 0; $I -Lt $LinesBefore; $I++) {
            Write-Host (Get-EOLCharacter) -NoNewline
        }
    }

    # Add TABS before text
    If ($StartTab -Ne 0) {
        For ($I = 0; $I -Lt $StartTab; $I++) {
            Write-Host "`t" -NoNewLine
        }
    }

    If ($Color.Count -Ge $Text.Count) {
        For ($I = 0; $I -Lt $Text.Length; $I++) {
            Write-Host $Text[$I] -ForegroundColor $Color[$I] -NoNewLine
        }
    } Else {
        For ($I = 0; $I -Lt $Color.Length; $I++) {
            Write-Host $Text[$I] -ForegroundColor $Color[$I] -NoNewLine
        }
        For ($I = $Color.Length; $I -Lt $Text.Length; $I++) {
            Write-Host $Text[$I] -ForegroundColor $DefaultColor -NoNewLine
        }
    }

    Write-Host

    # Add empty line after
    If ($LinesAfter -Ne 0) {
        For ($I = 0; $I -Lt $LinesAfter; $I++) {
            Write-Host (Get-EOLCharacter)
        }
    }

    If ($LogFile -Ne "") {
        $TextToFile = ""

        For ($I = 0; $I -Lt $Text.Length; $I++) {
            $TextToFile += $Text[$I]
        }

        Write-Output "[$([datetime]::Now.ToString($TimeFormat))]$TextToFile" | Out-File $LogFile -Encoding "Unicode" -Append
    }
}

<#
    .SYNOPSIS
    Displays a progress bar.

    .DESCRIPTION
    The "Write-ProgressBar" cmdlet displays a progress bar with a given progress percentage and a description of the currently running activity.

    .PARAMETER PercentComplete
    The progress of the progress bar.

    .PARAMETER Activity
    A description of the activity that is running.

    .EXAMPLE
    Write-ProgressBar -Activity "Checking ..." -PercentComplete $Index

    .LINK
    https://github.com/Dargmuesli/PowerShell-Lib/blob/master/PowerShell-Lib/Docs/Write-ProgressBar.md
#>
Function Write-ProgressBar {
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Int] $PercentComplete,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [String] $Activity = "Processing"
    )

    Write-Progress -Activity "$Activity" -PercentComplete $PercentComplete
}

Export-ModuleMember -Function *
