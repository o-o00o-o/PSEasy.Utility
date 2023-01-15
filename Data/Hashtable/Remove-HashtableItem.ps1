<#<#
.SYNOPSIS
Removes properties from Hashtable

.DESCRIPTION


.PARAMETER InputObject
Parameter description

.PARAMETER NullValues
Parameter description

.EXAMPLE
instead of

$splat = @{}
if ($Param1) {
    $splat.Add('Param1', $Param1)
}
if ($Param2) {
    $splat.Add('Param2', $Param2)
}
Some-Function @splat

How about this. Increasingly more elegant when you have many optional parameters.

$splat = @{
    Param1 = $Param1
    Param2 = $Param2
}
Remove-HashtableItem $splat -NullValue
Some-Function @splat

.NOTES
As an alternative to adding individual items to a hashtable if not blank

.LINK
Add-HashTableItem
#>#>
function Remove-HashtableItem {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        <#Category#>'PSUseShouldProcessForStateChangingFunctions', <#CheckId#>'',
        Justification = 'We are modifying a variable, so no persisted behaviour to protect'
    )]
    param(
        [Parameter(Position = 1, ValueFromPipeline)]
        [Alias('ht')]
        [hashtable]
        $Hashtable,

        [Parameter()]
        [switch]
        $NullValue
    )
    process {
        foreach ($item in $Hashtable.GetEnumerator()) {
            if ($NullValue -and $null -eq $item.Value) {
                $Hashtable.Remove($item.Key)
            }
        }
    }
}
