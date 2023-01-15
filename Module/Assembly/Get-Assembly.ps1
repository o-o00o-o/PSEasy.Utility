<#
.SYNOPSIS
Gets Assemblies currently loaded into the current session

.DESCRIPTION
No standard function for this??!

Very useful when trying to sort out DLL Hell

.EXAMPLE
Get the function into your session with

    . library\Get-Assembly.ps1

Get all assemblies currently loaded

    Get-Assembly

Get all assemblies currently loaded with system in the name

    Get-Assembly system

Get all assemblies currently loaded with either system or data in the name

    Get-Assembly system, data

.NOTES
General notes
#>
function Get-Assembly {
    param (
        # Array of Module Names to search. They can be regular expressions
        [Parameter(Position = 1)]
        [Alias('ModuleName')]
        [string[]]$ModuleNames
    )
    try {
        $all = ([appdomain]::currentdomain.getassemblies()).ManifestModule |
        Select-Object Name,
        @{  Name = 'Version'
            Expr = {
                [Version](
                    ($_.Assembly.GetCustomAttributesData() |
                        Where-Object { $_.AttributeType.Name -eq 'AssemblyFileVersionAttribute' }
                    ).ConstructorArguments[0]
                ).Value
            }
        },
        FullyQualifiedName

        if ($ModuleNames) {
            $found = [System.Collections.Generic.List[object]]::new()
            foreach ($ModuleName in $ModuleNames) {
                $foundAssemblies = ($all | Where-Object { $_.Name -match $ModuleName })
                $foundAssemblies | Format-Table | Out-String | Write-Verbose
                if ($foundAssemblies) {
                    $null = $found.AddRange(@($foundAssemblies))
                }
            }
            Write-Verbose $found.Count
            Write-Output $found.ToArray() | Sort-Object Name -unique
        } else {
            Write-Output $all | Sort-Object Name
        }
    } catch {
        throw
    }
}
