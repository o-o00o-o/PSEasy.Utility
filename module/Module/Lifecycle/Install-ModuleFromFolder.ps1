#Requires -Version 5
<#
.SYNOPSIS
    Copy the modules to the Users PSModulePath and Import the module

.DESCRIPTION
    Typically this can be useful during development however you should publish the modules to the artifact server

.NOTES
    To use the modules you can now simply

.EXAMPLE
    Import-Module -ModulePath 'C:\Downloads\MyModule\
#>
function Install-ModuleFromFolder {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "The path to the folder containing the module that you want to install")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ModulePath
    )
    begin {
        Set-StrictMode -Version 2.0
        $UserModulePath = Get-ModuleUserFolder
    }

    process {
        foreach ($_ModulePath in $ModulePath) {
            [string] $ModuleName = Split-Path -Path $ModulePath -Leaf

            Write-Host "Installing Modules to $UserModulePath"
            if (!(Test-Path $UserModulePath)) {
                New-Item $UserModulePath -force -ItemType Directory
            }

            Write-Host "Refreshing $ModuleName Module Files"
            if (Test-Path (Join-Path $UserModulePath $ModuleName)) {
                Remove-Item (Join-Path $UserModulePath $ModuleName) -Recurse -force
            }
            Copy-Item $ModulePath $UserModulePath -Recurse

            Write-Host "Force Importing Module $ModuleName"
            Import-Module $ModuleName -force -PassThru # reload
        }
    }
    end {

    }

}
