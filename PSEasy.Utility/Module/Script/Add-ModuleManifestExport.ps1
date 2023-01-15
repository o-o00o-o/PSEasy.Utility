<#
.SYNOPSIS
Helps to build a ModuleManifest argument hashtable based from the details of the files

.DESCRIPTION


.PARAMETER File
Array of files. Typically a result from Get-ChildItem

.EXAMPLE

#>
function Add-ModuleManifestExport {
    [CmdletBinding()]
    param (
        [Parameter()][ValidateSet('PublicOnlyIfIndicated', 'PublicByDefault')][string]$ExportMode,
        [Parameter(Mandatory)][hashtable]$ModuleManifestArgs,
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

            $export = if (-not $nature.PSObject.Properties['AccessibilityIndicator']) {
                $false
            } elseif ($nature.AccessibilityIndicator -eq 'public') {
                $true
            } elseif ($nature.AccessibilityIndicator -eq 'private') {
                $false
            } else {
                $ExportMode -eq 'PublicByDefault'
            }

            if ($nature.ScriptType -eq 'function') {
                if ($export) {
                    Write-Verbose "marking $($nature.filenameFunctionName) for export"
                    if (-not $ModuleManifestArgs.Contains('FunctionsToExport')) {
                        $ModuleManifestArgs.Add('FunctionsToExport', @())
                    }
                    $ModuleManifestArgs.FunctionsToExport += $nature.filenameFunctionName
                } else {
                    Write-Verbose "not exporting $($nature.filenameFunctionName)"
                }

                if ($PassThru) { Write-Output $_file }
            }
        }
    }
    end {
        # Write-Output ([scriptblock]::Create($sb.ToString()))
    }
}
