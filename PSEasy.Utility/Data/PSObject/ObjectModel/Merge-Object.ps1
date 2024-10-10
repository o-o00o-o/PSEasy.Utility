
<#
.SYNOPSIS

Merges one PSCustomObject into another, recursively.

.DESCRIPTION

Merges one PSCustomObject into another, recursively. If a property exists in both the target and source objects, the value of the source object will be used. If the property is a PSCustomObject, the function will recursively merge the properties of the PSCustomObject.

The Target object will be left with all properties from itself + any properties from the Source object that it did not already have.

The final values will be decided by the CollisionWinner parameter. By default the target object properties will always win in the case of a collision (both objects have a value). If you want the source object to win, you can set the CollisionWinner parameter to 'Source'.

.EXAMPLE

$target = [PSCustomObject]@{
    Name = "John"
    Age = 30
    Address = [PSCustomObject]@{
        Street = "123 Main St"
        City = "Anytown"
    }
}

$source = [PSCustomObject]@{
    Age = 35
    Address = [PSCustomObject]@{
        City = "Othertown"
        ZipCode = "12345"
    }
    Email = "john.doe@example.com"
}

Merge-Object -Target $target -Source $source

##############################################

$target = [PSCustomObject]@{
    Name = "John"
    Age = 30
    Address = [PSCustomObject]@{
        Street = "123 Main St"
        City = "Anytown"
        Details = [PSCustomObject]@{
            Type = "Residential"
        }
    }
}

$source = [PSCustomObject]@{
    Age = 35
    Address = [PSCustomObject]@{
        City = "Othertown"
        ZipCode = "12345"
        Details = [PSCustomObject]@{
            Type = "Commercial"
            Code = "A1"
        }
    }
    Email = "john.doe@example.com"
}

Merge-Object -Target $target -Source $source -CollisionWinner 'Target'

DEBUG: Target property 'Age' already exists. Keeping existing value.
DEBUG: Recursively merging source property 'Address' into target.
DEBUG: Target property 'City' already exists. Keeping existing value.
DEBUG: Adding new NoteProperty 'ZipCode' with value '12345' to the target.
DEBUG: Recursively merging source property 'Details' into target.
DEBUG: Target property 'Type' already exists. Keeping existing value.
DEBUG: Adding new NoteProperty 'Code' with value 'A1' to the target.
DEBUG: Adding new NoteProperty 'Email' with value 'john.doe@example.com' to the target.
#>
function Merge-Object {
    param(
        [Parameter(Mandatory)][PSCustomObject]$Target,
        [Parameter(Mandatory)][PSCustomObject]$Source,
        [Parameter()][ValidateSet('Target','Source')][string]$CollisionWinner = 'Target'
    )
    foreach ($sourceProperty in $Source.PSObject.Properties) {
        $targetProperty = $Target.PSObject.Properties[$sourceProperty.Name]

        if ($sourceProperty.Value -is [PSCustomObject]) {
            if (-not $targetProperty) {
                Write-Debug "Merge-Objevt: Adding new NoteProperty '$($sourceProperty.Name)' with an empty PSCustomObject to the target."
                Add-Member -InputObject $Target -MemberType NoteProperty -Name $sourceProperty.Name -Value ([PSCustomObject]@{})
            }
            Write-Debug "Merge-Objevt: Recursively merging source property '$($sourceProperty.Name)' into target."
            Merge-Object -Target $Target.$($sourceProperty.Name) -Source $sourceProperty.Value -CollisionWinner $CollisionWinner
        } else {
            if (-not $targetProperty) {
                Write-Debug "Merge-Objevt: Adding new NoteProperty '$($sourceProperty.Name)' with value '$($sourceProperty.Value)' to the target."
                Add-Member -InputObject $Target -MemberType NoteProperty -Name $sourceProperty.Name -Value $sourceProperty.Value
            } else {
                if ($CollisionWinner -eq 'Source') {
                    Write-Debug "Merge-Objevt: Overwriting target property '$($sourceProperty.Name)' with value '$($sourceProperty.Value)' as SourceWins is set."
                    $Target.$($sourceProperty.Name) = $sourceProperty.Value
                } else {
                    Write-Debug "Merge-Objevt: Target property '$($sourceProperty.Name)' already exists. Keeping existing value."
                }
            }
        }
    }
}
