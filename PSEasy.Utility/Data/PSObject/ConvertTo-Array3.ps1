function ConvertTo-Array3 {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][PSCustomObject]$InputObject,
        [Parameter()][Hashtable]$AddProperties,
        [Parameter()][String]$AddPropertyNameAs = 'Name',
        [Parameter()][int]$Depth = 1, # incompatible with $PropertyNameFirst
        [Parameter()][switch]$PropertyNameFirst # useful if you want property name to be first even if you don't have a format ps1xml for the given type
    )
    begin {

    }

    process {
        $propEnum = $InputObject.PSObject.Properties.GetEnumerator()
        $hasOneProperty = $propEnum.MoveNext()
        if ($hasOneProperty -and $propEnum.Current.value -is [PSCustomObject]) {
            # we have at least one property and its value is a PSCustomObject
            if ($propEnum.current.value.PSObject.Properties.GetEnumerator().MoveNext()) {
                foreach($property in $InputObject.PSobject.Properties) {
                    Write-Debug $property.name

                    if (-not $PropertyNameFirst) {
                        $object = ConvertTo-Json $property.value -Depth $Depth -WarningAction SilentlyContinue | ConvertFrom-Json #

                        $object | Add-Member -NotePropertyName $AddPropertyNameAs -NotePropertyValue $property.name -force

                    } else {
                        $childProperties = [ordered]@{}
                        foreach ($childProperty in $property.value.psobject.properties) {
                            if ($childProperty.name -ne $AddPropertyNameAs) { # ignore the existing named property to prevent Add-Member error later
                                $childProperties.add($childProperty.name, $childProperty.value)
                            }
                        }

                        $childProperties | Format-List | Out-String | Write-Debug

                        $object =
                            # build it this way so that our name is always first
                            [PSCustomObject]@{
                                "$AddPropertyNameAs" = $property.name
                            } | Add-Member -NotePropertyMembers $childProperties -passthru
                            # Add-Member -in $object -NotePropertyName $AddPropertyNameAs -NotePropertyValue $property.name –PassThru -force

                    }

                    # copy typenames so that formats are honoured
                    foreach ($typeName in $property.value.PSObject.TypeNames) {
                        if (-not $object.PSObject.TypeNames.Contains($TypeName)) {
                            $object.PSObject.TypeNames.Add($TypeName)
                        }
                    }

                    if ($AddProperties) {
                        $object | Add-Member -NotePropertyMembers $AddProperties
                    }

                    Write-Output ($object)
                }

                # foreach ($property in $AddProperties.GetEnumerator()) {
                #     Add-Property -PropertyName $property.Name -Expression ([ScriptBlock]::Create("'$($property.Value)'"))
                # }
            }

            # Write-Output (
            #     $InputObject.PSObject.Properties |
            #     Where-Object { $_.value.GetType().Name -eq 'PSCustomObject' } |
            #     Select-Object @selectPropertyParam -ExpandProperty value
            # )

        }
        # elseif ($hasOneProperty -and $propEnum.Current.value -is [string]) {
        #     Write-Output (
        #         $InputObject.PSObject.Properties |
        #         Where-Object { $_.value.GetType().Name -eq 'String' } |
        #         Select-Object -Property Name, Value
        #     )
        # }
    }

    end {}
}
