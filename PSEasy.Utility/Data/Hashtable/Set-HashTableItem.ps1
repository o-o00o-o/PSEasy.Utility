<#
.SYNOPSIS
Sets a value to a hashtable, adding or updating as necessary

.DESCRIPTION
Long description

.PARAMETER Hashtable
The hashtable to update

.PARAMETER Key
The key value

.PARAMETER Value
The new value

.PARAMETER NoOverwrite
If set will not change an existing value if the key already exists
#>
function Set-HashTableItem {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    [CmdletBinding()]
    param(
        [Parameter()][Alias('ht')][hashtable]$Hashtable,
        [Parameter()][Alias('k')][object]$Key,
        [Parameter()][Alias('v')][object]$Value,
        [Parameter()][Alias('safe')][switch]$NoOverwrite
    )
    if ($Hashtable.Contains($Key)) {
        if (-not $NoOverwrite) {
            $Hashtable.$Key = $Value
        }
    } else {
        $Hashtable.Add($Key, $Value)
    }
}
