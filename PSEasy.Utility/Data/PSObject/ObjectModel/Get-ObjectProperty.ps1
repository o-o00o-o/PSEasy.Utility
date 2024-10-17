
<#
.SYNOPSIS
Recursively gets properties where the name matches a specified pattern

.DESCRIPTION


.EXAMPLE

#>
function Get-ObjectProperty {
    param(
        # The PSCustomObject to get properties from
        [Parameter(Mandatory)][PSCustomObject]$InputObject,
        # return properties from the InputObject with this name (wildcards supported)
        [Parameter()][string]$NameSpec,
        # any properties with this name (wildcards supported) will be excluded (including children). Default is '*splat' which can have infinite nested objects
        [Parameter()][string]$ExcludeNameSpec = '*splat',
        # The path of the current object. Empty if this is the root object
        [Parameter()][string]$Path = '',
        # Only properties of the specified type will be returned
        [Parameter()][string[]]$MemberType = 'NoteProperty'
    )
    foreach ($property in $InputObject.PSObject.Properties | Where-Object { $_.MemberType -in $MemberType }) {
        if ($property.Name -like $ExcludeNameSpec) {
            Write-Debug "Get-ObjectProperty: $($property.Name) is excluded"
            continue
        }

        $currentPath = "$($Path ? "$Path." : '' )$($property.Name)"
        if ($property.Value -is [PSCustomObject]) {
            Write-Debug "Get-ObjectProperty: $($property.Name) is a PSCustomObject"
            Get-ObjectProperty -InputObject ($InputObject.$($Property.name)) -NameSpec $NameSpec -ExcludeNameSpec $ExcludeNameSpec -Path $currentPath
        }
        else {
            if ($property.Name -like $NameSpec) {
                $TokenPath = [PSCustomObject]@{
                    ObjectPath = $currentPath
                    Name       = $property.Name
                    Value      = $property.Value
                }
                ("Get-ObjectProperty: " + ($TokenPath | Format-Table | Out-String)) | Write-Debug
                $TokenPath | Write-Output
            }
            else {
                Write-Debug "Get-ObjectProperty: $($property.Name) is not a match"
            }
        }
    }
}
