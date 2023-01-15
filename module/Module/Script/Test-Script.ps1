<#
.SYNOPSIS
Checks if the Script given is consistent

.DESCRIPTION


.PARAMETER File
Array of files. Typically a result from Get-ChildItem

.EXAMPLE
Typically used in a psm1 module file to import all the ps1 files in a folder

src\example\example.psm1

    Get-ChildItem $PSScriptRoot -filter '*-*.ps1' -Recurse -Exclude ('*.Tests.ps1') |
    ForEach-Object {
        . $_
        Test-Script $_
    }

This can be executed by

    Import-Module '.\src\example' -Force -PassThru

#>
function Test-Script {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)][System.IO.FileInfo[]]$File,
        [Parameter()][switch]$PassThru
    )

    begin {
        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"
    }

    process {
        foreach ($_file in $File) {
            $nature = Get-ScriptNature -File $_file

            if ($nature.ScriptType -eq 'function') {
                if ($nature.FilenameFunctionName -ne $nature.ScriptFunctionName) {
                    throw "$($nature.filenameFunctionName) doesn't match the function definition (filename: $($nature.filenameFunctionName) contents: $($nature.ScriptFunctionName))"
                }

            }

            if ($PassThru) { Write-Output $_file }
        }
    }

    end {
        # Write-Output ([scriptblock]::Create($sb.ToString()))
    }
}
