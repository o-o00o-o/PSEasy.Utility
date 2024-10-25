<#
.SYNOPSIS
Get the value of a parameter from a command element.

.EXAMPLE
Get-ParameterValue -ParameterName 'Name' -CommandElements $CommandElements

#>
function Get-ParameterValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ParameterName,
        [Parameter(Mandatory = $true)]
        [System.Collections.ObjectModel.Collection[System.Management.Automation.Language.CommandElementAst]]$CommandElements
    )

    for ($i = 0; $i -lt $CommandElements.Count; $i++) {
        if ($CommandElements[$i].PSObject.Properties['ParameterName'] -and $CommandElements[$i].ParameterName -eq $ParameterName) {
            return $CommandElements[$i + 1].Extent.Text
        }
    }
    return $null
}
