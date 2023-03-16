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
    )
    Write-Debug "Add-HashtableItem: Checking adding $Value to $Key"
    if ($null -ne $Value -and $Value -ne '') {
        Write-Debug "Add-HashtableItem: Adding to Hashtable $Key = $Value"
        $Hashtable.Add($Key , $Value)
    }
}
