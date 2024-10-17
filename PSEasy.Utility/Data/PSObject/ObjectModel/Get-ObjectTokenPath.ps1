
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
        [Parameter()][string[]]$ExcludeNameSpec = '*splat',
        # the object to use to replace the token
        [Parameter()][string[]]$ReplacementObject = $InputObject
    )
    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Name -like $ExcludeNameSpec) {
            Write-Debug "Get-ObjectTokenPath: $($property.Name) is excluded"
            continue
        }

        $currentPath = "$($Path ? "$Path." : '' )$($property.Name)"
        if ($property.Value -is [PSCustomObject]) {
            Get-ObjectTokenPath -InputObject ($InputObject.$($Property.name)) -Path $currentPath -ExcludeNameSpec $ExcludeNameSpec
        }
        else {
            if ($property.Value -is [string]) {
                if ($property.Value -match '\$\(([^)]+)\)') {

                    $TokenPath = [PSCustomObject]@{
                        ObjectPath = "$Path.$($property.Name)"
                        TokenName  = $matches.1
                        Token      = $matches.0
                        Value      = $property.Value
                    }
                ("Get-ObjectTokenPath: " + ($TokenPath | Format-Table | Out-String)) | Write-Debug
                    $TokenPath | Write-Output
                }
            }
        }
    }
}
