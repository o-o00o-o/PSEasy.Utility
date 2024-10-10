
<#
.SYNOPSIS
Gets all paths where values have a token e.g. '$(blah)' that will need replacing

.DESCRIPTION


.EXAMPLE

#>
function Get-ObjectTokenPath {
    param(
        [Parameter(Mandatory)][PSCustomObject]$InputObject,
        # The path of the current object. Empty if this is the root object
        [Parameter()][string]$Path = '',
        # any properties with this name (wildcards supported) will be excluded (including children). Default is '*splat' which can have infinite nested objects
        [Parameter()][string]$ExcludeNameSpec = '*splat'
    )
    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Name -like $ExcludeName) {
            Write-Debug "Get-ObjectTokenPath: $($property.Name) is excluded"
            continue
        }

        if ($property.Value -is [PSCustomObject]) {
            Get-ObjectTokenPath -InputObject ($InputObject.$($Property.name)) -Path "$Path.$($property.Name)" -ExcludeNameSpec $ExcludeNameSpec
        }
        else {
            if ($property.Value -is [string]) {
                $null = $property.Value -match '\$\(([^)]+)\)'
                foreach ($match in $matches) {
                    $TokenPath = [PSCustomObject]@{
                        ObjectPath = "$Path.$($property.Name)"
                        Token      = $match.Value
                    }
                    ("Get-ObjecttokenPath: " + ($TokenPath | Format-Table | Out-String)) | Write-Debug
                    $TokenPath | Write-Output
                }
            }
        }
    }
}
