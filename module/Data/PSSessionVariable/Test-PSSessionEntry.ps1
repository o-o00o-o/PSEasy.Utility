<#
.SYNOPSIS
Tests if we already have a value for this Session

.NOTES
Use with Add-PSSessionVariableEntry

.EXAMPLE
$SessionLogVariableName = 'SessionWideUniqueName'
$filePath = Join-Path (Join-Path (Join-Path $DependencyFolder 'Depend-NuGet') $NugetPackageName) $PathToDll
if (-not (& "$PSScriptRoot\Test-PSSessionVariableEntry.ps1" -VariableName $SessionLogVariableName -Value $filePath)) {
    .. do something that you only want to happen once per session
    & "$PSScriptRoot\Add-PSSessionVariableEntry.ps1" -VariableName $SessionLogVariableName -Value $filePath
}
#>
function Test-PSSessionEntry {
    param(
        [parameter(Mandatory)]
        [string] $GlobalVariableName,
        [parameter(Mandatory)]
        [string] $CollectionName,
        [parameter(Mandatory)]
        [string] $Value
    )
    try {
        $collection = Initialize-PSSessionVariable -GlobalVariableName $GlobalVariableName -CollectionName $CollectionName
        return $collection.Contains($Value)
    } catch {
        throw
    }
}
