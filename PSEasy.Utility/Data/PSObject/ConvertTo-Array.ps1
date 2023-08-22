<#<#
.SYNOPSIS
Converts a given PSCustomObject's properties into an array of PSCustomObjects.

.DESCRIPTION
Often it makes more sense to create a json/PSCustomObject structure that has property names instead of an array even though you want to loop through it sometimes also.

Could be because you want to ensure each one is unique or navigate to a property easily by dot notation by name e.g. object.myproperty.connectionstring

This function deconstructs a PSObject and converts each property into an array member of a PSCustomObject type.

To allow understanding the resulting array, we add a Name (or _Name) property with the original property name to it.

We also ignore Name, _Name values from further array construction. This allows 2 calls to Get-ArrayFromPSObject without getting a useless Name member

e.g.
> ConvertTo-Array -InputObject (ConvertTo-Array($context.dependencies))[1]

version   usedFor Name
-------   ------- ----
2.8.5.208 deploy  NuGet

Notice this doesn't have an additional array element 1 that is just Name = Name which it would if IgnoreProperties was cleared

.EXAMPLE

1. Shows that we ignore the name property that we added before when we are added twice.
   (Note this could probably be done in a smarter way - like )

  > library\ConvertTo-Array -InputObject (library\ConvertTo-Array -InputObject $context.dependencies )[1]

  version   scripts Notes                                                     Name
  -------   ------- -----                                                     ----
  2.8.5.208 {}      Nothing is using this and it is slow so disabling for now NuGet

  vs
  > library\ConvertTo-Array -InputObject (library\ConvertTo-Array -InputObject $context.dependencies )[1] -IgnoreProperties @()

  version   scripts Notes                                                     Name
  -------   ------- -----                                                     ----
  2.8.5.208 {}      Nothing is using this and it is slow so disabling for now NuGet
                                                                              Name


.NOTES

#>#>
function ConvertTo-Array {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression','', Justification = "The class is statically created so is safe. We will move this into the module now we have one")]
param(
    [Parameter(Position = 1, ValueFromPipeline)][PSCustomObject]$InputObject
    , # For each child item of the object given, add the given name with the value. They all end up with the same values.
    # E.g. @{Blah="Blah"} would mean that every item in the resulting array will have a Blah member with a value "Blah"
    [Parameter(Position = 2)][Hashtable]$AddProperties = @{}
    , # Add Property Name to collections as property name
    [Parameter(Position = 3)][String]$AddPropertyNameAs = 'Name'
    <# readonly will not change the InputObject (i.e. add the name type). You can still modify the object by referring to the original structure again
     e.g. we can create a new NewValue property like this
      foreach ($property in (ConvertTo-Array $myObject -readonly)) {$myObject.($property.Name) | Add-Member 'NewValue' 'blah'}
     with readonly not set you can do this, but you are stuck then with the additional Name property
      foreach ($property in (ConvertTo-Array $myObject -readonly)) {$property | Add-Member 'NewValue' 'blah'}
    FIXISSUE, nested arrays don't seem to work correctly with this method.. e.g.
      This works (shows correct type)
        $vegadw.GetArray($vegadw.starTables.FactTrackedSales.fields) | Where-Object {
                         $_.PSObject.Properties['references'] -and
                         $_.references.PSObject.Properties['olad']
                    } | foreach {$_.references.olad} | foreach{$_ | gm}
      This doesn't (shows string)
        $vegadw.starTables.FactTrackedSales.fields.ToArray2()) | Where-Object {
                         $_.PSObject.Properties['references'] -and
                         $_.references.PSObject.Properties['olad']
                    } | foreach {$_.references.olad} | foreach{$_ | gm}
    #>
    # Currently broken so disabled
    # [Parameter()][Switch]$ReadOnly
)
process {
    try {
        # TODO: Library should be a module. The class can then be part of that module and we don't need to us invoke-expression. We can also then switch back to comparing GetType() directly rather than falling back to the name

        if (-not ([appdomain]::currentdomain.GetAssemblies() | where-object { $_.ManifestModule -like "*Vega?VegaDW?library?classes?PropertyName.ps1" })) {
            # add class if we are missing it


            Invoke-Expression -Command ( # Get-Content "$PSScriptRoot\classes\PropertyName.ps1" -raw) # this didn't work as it is consumed by Add-PSCustomObjectHelperMethods still.. need to remove that and convert all callers to use library
                @'
    class PropertyName {
      # unfortunately it seems that we can't extend value types here (otherwise we would just extend system.string, so this is the next best thing)
      [string] $Value

      PropertyName([string]$Value) {
          $this.Value = $Value
      }

      hidden static [PropertyName] op_Implicit([string]$Value) {
          return [PropertyName]::new($Value)
      }

      hidden static [String] op_Implicit([PropertyName]$PropertyName) {
          return $PropertyName.Value
      }

      [string] ToString() {
          return $this.Value
      }

      [bool] Equals([System.Object] $obj) {
          return $this.Value -eq $obj.ToString()
      }
    }
'@
            )
        }
        foreach ($property in $InputObject.PSObject.Properties) {
            if ($property.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject') {
                foreach ($childProperty in $property.Value.PSObject.properties) {
                    if ($childProperty | Where-Object { $_.Name -eq $AddPropertyNameAs -and $_.Value.GetType().Name -ne 'PropertyName' -and $_.Value -ne $property.Value.$AddPropertyNameAs }) {
                        throw "We already have a property in the property $($property.Name) called $($childProperty.Name) with a different value $($childProperty.Value), please indicate a different PropertyName with the AddPropertyNameAs parameter"
                    }
                }
            }
        }

        foreach ($property in $InputObject.PSObject.Properties) {

            # if the child item is already a PSCustomObject then we can just add a member
            if ($null -eq $property.Value) {
                continue
            } elseif (($property.Value.GetType() -eq [System.Management.Automation.PSCustomObject]) ) {
                # TODO This currently doesn't work with types correctly so removing for now.
                # if ($ReadOnly.IsPresent) {
                #   # We would really like to not change the existing object by cloning it so we don't add Name and other properties. The problem is that we don't have the outer
                #   $current = $property.Value | ConvertTo-Json | ConvertFrom-Json # Clone the PSCustomObject (only properties, any methods will be gone)

                #   # copy any types it doesn't already have so we can pass off as this object (note this might not be strictly correct to do this... but leaving for now)
                #   foreach ($typeName in $property.value.psObject.TypeNames) {
                #     if ($typeName -notin $current.PSObject.TypeNames) {
                #       Write-Verbose "Adding missing type $typeName "
                #       $current.PSObject.TypeNames.Insert(0,$typeName)
                #     }
                #   }
                # } else {
                $current = $property.Value
                # }

                if (-not ($current.PSObject.Properties | Where-Object { $_.Name -eq $AddPropertyNameAs -and $_.Value.GetType().Name -eq 'PropertyName' })) {
                    # we haven't already added this (e.g. in a previous non-readonly call))
                    if ($AddPropertyNameAs) {
                        $current | Add-Member NoteProperty $AddPropertyNameAs ([PropertyName]$property.Name) -force
                    }
                }

                foreach ($addprop in $AddProperties.GetEnumerator()) {
                    $current | Add-Member NoteProperty $addprop.Name $addprop.Value -force
                }
                Write-Output $current # return the transformed item into the pipeline
            } else {
                # otherwise we need to create a PSCustomObject with name and value members
                if ($property.Value.GetType().Name -ne 'PropertyName') {
                    $current = [PSCustomObject]@{$AddPropertyNameAs = ([PropertyName]$property.Name) ; Value = $property.Value }
                    Write-Output $current # return the transformed item into the pipeline
                }
            }
        }
    } catch {
        throw
    }
}
}
