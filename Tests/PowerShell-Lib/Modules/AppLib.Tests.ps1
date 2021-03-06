Set-StrictMode -Version Latest

Import-Module -Name "${PSScriptRoot}\..\..\..\PowerShell-Lib\PowerShell-Lib.psd1" -Force
Import-Module -Name "${PSScriptRoot}\..\..\..\PowerShell-Lib\Modules\AppLib.psm1" -Force

Describe "Get-AppsInstalled" {
    Context "Windows" {
        Mock Test-IsWindows {
            Return $True
        } -ModuleName "AppLib"

        Context "There are apps installed" {
            Mock Get-ItemProperty {
                Return @(
                    [PSCustomObject] @{
                        DisplayName = "App 1"
                    },
                    [PSCustomObject] @{
                        DisplayName = "App 2"
                    }
                )
            } -ModuleName "AppLib"

            $GetAppsInstalled = Get-AppsInstalled

            It "returns a list of installed apps" {
                $GetAppsInstalled | Should Not BeNullOrEmpty
                $GetAppsInstalled | Should BeOfType [PSCustomObject]
            }
        }

        Context "No apps are installed" {
            Mock Get-ItemProperty {
                Return $Null
            } -ModuleName "AppLib"

            $GetAppsInstalled = Get-AppsInstalled

            It "returns a list of installed apps" {
                $GetAppsInstalled | Should BeNullOrEmpty
            }
        }
    }
}

Describe "Install-App" {
    Context "Windows" {
        Mock Test-IsWindows {
            Return $True
        } -ModuleName "AppLib"
        $InstallerPathExe = "TestDrive:\x.exe"
        $InstallerPathMsi = "TestDrive:\x.msi"

        New-Item -Path $InstallerPathExe -ItemType "File"
        New-Item -Path $InstallerPathMsi -ItemType "File"

        Context "exe" {
            Mock Start-Process {} -ModuleName "AppLib"

            It "gives no feedback" {
                Install-App -InstallerPath $InstallerPathExe | Should BeNullOrEmpty
            }
        }

        Context "msi" {
            Mock Start-Process {} -ModuleName "AppLib"

            It "gives no feedback" {
                Install-App -InstallerPath $InstallerPathMsi | Should BeNullOrEmpty
            }
        }

        Context "default" {
            $InstallerPath = "~"

            It "throws an error" {
                {Install-App -InstallerPath $InstallerPath} | Should Throw "File extension of `"$InstallerPath`" is neither `".exe`" nor `".msi`"."
            }
        }
    }
}

Describe "Test-AppInstalled" {
    $AppName = "testapp"
    $AppNameRegex = "^testapp$"

    Context "Windows" {
        Mock Test-IsWindows {
            Return $True
        } -ModuleName "AppLib"

        Context "app installed" {
            Mock Get-AppsInstalled {
                Return @(
                    @{
                        "DisplayName" = "testapp"
                    }
                )
            } -ModuleName "AppLib"

            It "returns true for an installed app" {
                Test-AppInstalled -AppName $AppName | Should Be $True
                Test-AppInstalled -AppName $AppNameRegex -RegexCompare | Should Be $True
            }
        }

        Context "app not installed" {
            Mock Get-AppsInstalled {
                Return @(
                    @{}
                )
            } -ModuleName "AppLib"

            It "returns false for a not installed app" {
                Test-AppInstalled -AppName $AppName | Should Be $False
                Test-AppInstalled -AppName $AppNameRegex -RegexCompare | Should Be $False
            }
        }
    }

    Context "Linux" {
        Mock Test-IsWindows {
            Return $False
        } -ModuleName "AppLib"

        Mock Test-IsLinux {
            Return $True
        } -ModuleName "AppLib"

        Context "Pacman" {
            Mock Get-DefaultPackageManager {
                Return "Pacman"
            } -ModuleName "AppLib"

            Context "app installed" {
                Mock Get-AppsInstalled {
                    Return "testapp"
                } -ModuleName "AppLib"

                It "returns true for an installed app" {
                    Test-AppInstalled -AppName $AppName | Should Be $True
                    Test-AppInstalled -AppName $AppNameRegex -RegexCompare | Should Be $True
                }
            }

            Context "app not installed" {
                Mock Get-AppsInstalled {
                    Return ""
                } -ModuleName "AppLib"

                It "returns false for a not installed app" {
                    Test-AppInstalled -AppName $AppName | Should Be $False
                    Test-AppInstalled -AppName $AppNameRegex -RegexCompare | Should Be $False
                }
            }
        }
    }
}
