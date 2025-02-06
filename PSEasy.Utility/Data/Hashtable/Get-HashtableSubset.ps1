    <#
    .SYNOPSIS
    Returns a hashtable with only the keys specified in the Keys parameter

    .EXAMPLE
    $splat = Get-HashtableSubset -Source $PSBoundParameters -Keys @(
    'CelestraModel',

    .NOTES
    useful for passing through optional parameters through functions using splatting
    #>
    function Get-HashtableSubset {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param(
            [Parameter(Mandatory, Position = 0)]
            [System.Collections.IDictionary]
            $Source,

            [Parameter(Mandatory, Position = 1)]
            [string[]]
            $Keys
        )

        $subset = @{}
        foreach ($key in $Keys) {
            if ($Source.ContainsKey($key)) {
                $subset[$key] = $Source[$key]
            }
        }
        return ($subset)
    }
