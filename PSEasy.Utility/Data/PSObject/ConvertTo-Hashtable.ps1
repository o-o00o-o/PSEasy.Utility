# stolen from https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable
# converts your nested PSObject array into a nested Hashtable array
# IMPORTANT Depth doesn't work correctly right now
function ConvertTo-Hashtable {
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [Parameter()]
        [nullable[int]]
        # DO NOT USE - DOESN'T WORK
        $Depth = $null
    )
    begin {

    }

    process {
        try {
            if ($null -eq $InputObject) { return $null }

            if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
                if ($Depth -ne $null) {
                    $Depth--
                }

                if ($Depth -ge 0) {
                    Write-Output $InputObject -NoEnumerate
                } else {
                    $collection = @(
                        foreach ($object in $InputObject) {
                            if ($Depth -eq $null) {
                                ConvertTo-Hashtable -InputObject $object
                            } else {
                                ConvertTo-Hashtable -InputObject $object -Depth $Depth
                            }
                        }
                    )

                    Write-Output $collection -NoEnumerate
                }
            } elseif ($InputObject -is [psobject]) {

                if ($Depth -ge 0) {
                    $InputObject
                } else {
                    $hash = @{ }

                    foreach ($property in $InputObject.PSObject.Properties) {
                        if ($Depth -eq $null) {
                            $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
                        } else {
                            $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value -Depth $Depth
                        }
                    }

                    $hash
                }
            } else {
                $InputObject
            }
        } catch {
            Write-Error "$_`n$(' ' * 80)`n$($_.ScriptStackTrace)$(if ($_ | Get-Member | Where-Object {$_.Name -eq 'Exception'}) {"`n$(' ' * 80)`n" + $_.Exception.ToString()})"
        }
    }
}
