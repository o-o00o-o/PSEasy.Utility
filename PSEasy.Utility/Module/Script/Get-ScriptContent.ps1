<#
.SYNOPSIS
    Extracts functions and aliases from PowerShell script files.

.DESCRIPTION
    The Get-Script function takes an array of System.IO.FileInfo objects as a parameter and produces an array of objects that describe the functions and aliases defined in each script file.

.PARAMETER Files
    An array of System.IO.FileInfo objects representing the script files to be analysed. This parameter can also accept input from the pipeline.

.OUTPUTS
    An array of custom objects, each containing the file path, functions, and aliases defined in the corresponding script file.

.EXAMPLE
    $File = Get-ChildItem -Path "path\to\your\scripts" -Filter "*.ps1"
    $scriptInfo = Get-Script -File $File
    $scriptInfo

    This example retrieves all .ps1 files in the specified directory and extracts the functions and aliases defined in each file.

.EXAMPLE
    Get-ChildItem -Path "path\to\your\scripts" -Filter "*.ps1" | Get-ScriptContent

    This example retrieves all .ps1 files in the specified directory and extracts the functions and aliases defined in each file using the pipeline.

.NOTES
#>
function Get-ScriptContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.IO.FileInfo[]]$File
    )

    process {
        foreach ($file in $File) {
            # Read the file content
            $fileContent = Get-Content -Path $file.FullName -Raw

            # Parse the script using the AST
            $scriptAst = [System.Management.Automation.Language.Parser]::ParseInput($fileContent, [ref]$null, [ref]$null)

            # Initialize arrays to store functions and aliases
            $functions = @()
            $aliases = @()

            ("Parsed $($file.FullName)" + ($scriptAst | Format-List | Out-String)) | Write-Debug

            # Extract functions
            $scriptAst.FindAll({ param ($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object {
                ("found function $($_.Name)" + ($_ | Format-List | Out-String)) | Write-Debug

                $functions += $_.Name
            }

            # Extract aliases
            $scriptAst.FindAll({ param ($node)
                    $node -is [System.Management.Automation.Language.CommandAst]
                }, $true) |
            Where-Object {
                $_.CommandElements[0].Extent.Text -eq 'Set-Alias'
            } |
            ForEach-Object {
                try {

                    $aliasName = Get-ParameterValue -ParameterName 'Name' -CommandElements $_.CommandElements
                    $aliasValue = Get-ParameterValue -ParameterName 'Value' -CommandElements $_.CommandElements

                ("found alias $($aliasName)" + ($_ | Format-List | Out-String)) | Write-Debug
                ("alias $($aliasName) elements" + ($_.CommandElements | Format-List | Out-String)) | Write-Debug

                    $aliases += [PSCustomObject]@{
                        Name  = $aliasName
                        Value = $aliasValue
                    }
                }
                catch { throw }
            }

            # Add the results to the array
            Write-Output ([PSCustomObject]@{
                    File      = $file
                    FilePath  = $file.FullName
                    Functions = $functions
                    Aliases   = $aliases
                })
        }
    }
}
