<#
.SYNOPSIS
    Add the item to the hashtable if it has a value. Useful for splatting.
.NOTES
    See the alternative approach using Remove-HashtableItem
.LINK
    Remove-HashtableItem
#>
function Add-HashtableItem {
    [CmdletBinding()]
    param(
        [alias("ht")]
        [parameter(Position = 1, Mandatory = $true)]
        [Hashtable] $Hashtable

        , [alias("k")]
        [parameter(Position = 2, Mandatory = $true)]
        [string] $Key

        , [alias("v")]
        [parameter(Position = 3, Mandatory = $false)]
        [object] $Value

        , [alias("eb")]
        [Parameter(Position = 4, Mandatory = $false)]
        [VAlidateSet('LeaveExisting', 'Error', 'Overwrite')]
        [string]$KeyExistsBehaviour = 'Overwrite'
    )
    Write-Debug "Add-HashtableItem: Checking adding $Value to $Key"
    if ($null -ne $Value -and $Value -ne '') {
        Write-Debug "Add-HashtableItem: Adding to Hashtable $Key = $Value"
        if ($Hashtable.ContainsKey($Key)) {
            switch ($KeyExistsBehaviour) {
                'Overwrite' { $Hashtable.Add($Key , $Value) }
                'Error' {throw "hashtable already has a key $Key and KeyExistsBehaviour is set to $KeyExistsBehaviour"}
                Default {}
            }
        }
    }
}
