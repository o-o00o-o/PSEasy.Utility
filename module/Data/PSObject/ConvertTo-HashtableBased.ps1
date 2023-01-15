<#
.SYNOPSIS
Takes a PSObject array (of whatever depth) and returns an array of HashTables but with the deeper structures still as PSObjects

.DESCRIPTION

.EXAMPLE
$Get-Content "blah.tests.json" | ConvertFrom-Json | ConvertTo-HashTableBased

.NOTES
This is useful to convert json documents into structures that are suitable for data driven pester tests

It is easier to navigate the objects as PSObjects, but pester data driven needs the top level to be HashTables

We tried to do this with a more flexible ConvertTo-Hashtable - but ran out of time and this sufficed
#>
function ConvertTo-HashtableBased {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [PSObject[]]
        $InputObject
    )

    process {
        try {
            if ($null -eq $InputObject) { return $null }

            if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
                foreach ($object in $InputObject) {
                    if ($object -is [psobject]) {
                        $hash = @{ }
                        foreach ($property in $object.PSObject.Properties) {
                            Write-Verbose $property.Name
                            $hash[$property.Name] = $property.Value
                        }
                        Write-Output $hash
                    } else {
                        Write-Verbose 'object is not [psobject]'
                    }
                }
            } else {
                Write-Verbose "Not enumerable"
            }
        } catch {
            throw
        }
    }
}
