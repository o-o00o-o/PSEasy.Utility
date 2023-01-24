<#<#
.SYNOPSIS
Will find the current or parent folder that has a folder with the given name in.

.DESCRIPTION
Useful for finding log folders/ .git folders etc

.OUTPUTS
the Item or null if not found. The caller should handle if an item was expected but null.

.NOTES
General notes
#>#>
function Find-Item {
    param(
        # starting path. If not given will use current location
        [Parameter()][string]$Path,
        # for future use. Up goes up through parent directories until it finds a folder with the item name in. Down currently not supported.
        [Parameter()][ValidateSet('Up')][string]$Direction = 'Up',
        # the item name to find
        [Parameter(Mandatory)][string]$ItemName,
        # Only find Directories with the given ItemName
        [Parameter()][switch]$Directory,
        # Return the parent of the found item (e.g. .git)
        [Parameter()][switch]$Parent
    )
    $currentPath = $null

    if ($Path) {
        $startingPath = Get-Item -literalPath $Path -force
    }
    else {
        $startingPath = Get-Item -literalPath (Get-Location) -force
    }

    if ($Directory) {
        $PathType = 'Container'
    }
    else {
        $PathType = 'Any'
    }

    $foundFolder = $null
    do {
        if ($null -eq $currentPath) {
            $currentPath = $startingPath
        }
        else {
            if ($Direction -eq 'Up') {
                $currentPath = $currentPath.Parent
            }
            else {
                throw "Only Direction Up currently supported"
            }
        }

        Write-Debug "Checking $currentPath for $ItemName PathType $PathType"
        if (Test-Path -literalPath (Join-Path -Path $currentPath -ChildPath $ItemName) -PathType $PathType) {
            $foundFolder = $currentPath
        }
    } while ($null -eq $foundFolder -and $null -ne $currentPath.parent)

    if ($foundFolder) {
        if ($Parent) {
            Write-Output (Split-Path (Get-ChildItem $foundFolder $ItemName -Force) -Parent)
        }
        else {
            Write-Output (Get-ChildItem $foundFolder $ItemName -Force)
        }
    } else {
        Write-Verbose "Unable to Find item $ItemName in $($Path.FullName) direction $Direction"
    }
}
