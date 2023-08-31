function ConvertTo-Array2 {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][PSCustomObject]$InputObject,
        [Parameter()][Hashtable]$AddProperties = @{},
        [Parameter()][String]$AddPropertyNameAs = 'Name'
    )
    begin {}

    process {
        $propEnum = $InputObject.PSObject.Properties.GetEnumerator()
        $hasOneProperty = $propEnum.MoveNext()
        if ($hasOneProperty -and $propEnum.Current.value -is [PSCustomObject]) {
            # we have at least one property and its value is a PSCustomObject
            if ($propEnum.current.value.PSObject.Properties.GetEnumerator().MoveNext()) {
                $selectPropertyParam = @{
                    Property = [System.Collections.Generic.List[PSCustomObject]]::new(1)
                }

                function Add-Property {
                    param(
                        $PropertyName,
                        [scriptblock]$Expression
                    )

                    if ($PropertyName) {
                        # and the first property has other properties
                        $alreadyHasProperty = $propEnum.current.value.PSObject.Properties[$PropertyName]

                        if ($alreadyHasProperty) {
                            # Write-Warning "$PropertyName already exists, so not adding"
                        }
                        else {
                            $null = $selectPropertyParam.Property.Add( @{
                                    e = $Expression
                                    l = $PropertyName
                                })
                        }
                    }
                }
                Add-Property -PropertyName $AddPropertyNameAs -Expression { $_.name }

                foreach ($property in $AddProperties.GetEnumerator()) {
                    Add-Property -PropertyName $property.Name -Expression ([ScriptBlock]::Create("'$($property.Value)'"))
                }
            }

            Write-Output (
                $InputObject.PSObject.Properties |
                Where-Object { $_.value.GetType().Name -eq 'PSCustomObject' } |
                Select-Object @selectPropertyParam -ExpandProperty value
            )

        }
        elseif ($hasOneProperty -and $propEnum.Current.value -is [string]) {
            Write-Output (
                $InputObject.PSObject.Properties |
                Where-Object { $_.value.GetType().Name -eq 'String' } |
                Select-Object -Property Name, Value
            )
        }
    }

    end {}
}
