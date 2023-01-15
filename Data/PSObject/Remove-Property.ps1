<#<#
.SYNOPSIS
Removes properties from PSObject for specific conditions

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

How about this. Increasingly more elegant when you have many of these.

$splat = @{
    Param1 = $Param1
    Param2 = $Param2
}
Remove-Property $splat -NullValues
Some-Function @splat

.NOTES
As an alternative to adding individual items to a hashtable if not blank

#>#>
function Remove-Property {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        <#Category#>'PSUseShouldProcessForStateChangingFunctions',<#CheckId#>'',
        Justification = 'Changing temporary variable, so no need for should process'
    )]
    param(
        [Parameter(Position = 1, ValueFromPipeline)]
        [PSCustomObject]
        $InputObject,

        [Parameter()]
        [switch]
        $NullValues
    )
    process {
        foreach ($property in $InputObject.PSObject.Properties) {
            if ($NullValues -and $null -eq $property.Value) {
                $InputObject.PSObject.Properties.Remove($property.Name)
            }
        }
    }
}
