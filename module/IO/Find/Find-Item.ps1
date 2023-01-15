<#<#
.SYNOPSIS
Will find the current or parent folder that has a folder with the given name in.

.DESCRIPTION
Useful for finding log folders/ .git folders etc


.OUTPUTS
the Item or null if not found

.NOTES
General notes
#>#>
function Find-Item {
    param(
        # starting path
        [Parameter()][string]$Path = $null,
        # for future use. Up goes up through parent directories until it finds a folder with the item name in
        [Parameter()][ValidateSet('Up')][string]$Direction = 'Up',
        # the item name to find
        [Parameter(Mandatory)][string]$ItemName,
        [Parameter()][switch]$Directory,
        [Parameter()][switch]$Parent
    )
    # find the first parent with .git folder
    $currentPath = $null

    if ($Path) {
        $startingPath = Get-Item -literalPath $Path -force
    } else {
        $startingPath = Get-Item -literalPath (Get-Location) -force
    }

    if ($Directory) {
        $PathType = 'Container'
    } else {
        $PathType = 'Any'
    }

    $foundFolder = $null
    do {
        if ($null -eq $currentPath) {
            $currentPath = $startingPath
        } else {
            if ($Direction -eq 'Up') {
                $currentPath = $currentPath.Parent
            } else {
                throw "Only Direction Up currently supported"
            }
        }

        Write-Debug "Checking $currentPath for $ItemName PathType $PathType"
        if (Test-Path -literalPath (Join-Path -Path $currentPath -ChildPath $ItemName) -PathType $PathType) {
            $foundFolder = $currentPath
        }
    } while ($null -eq $foundFolder -and $null -ne $currentPath.parent)

    if ($Parent) {
        Write-Output (Split-Path (Get-ChildItem $foundFolder $ItemName -Force) -Parent)
    } else {
        Write-Output (Get-ChildItem $foundFolder $ItemName -Force)
    }
}
