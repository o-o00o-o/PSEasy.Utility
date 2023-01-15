<#
.SYNOPSIS
Records a value for a Session variable to allow testing for it

.NOTES
Use with Test-PSSessionVariableEntry

.EXAMPLE
$SessionLogVariableName = 'SessionWideUniqueName'
$filePath = Join-Path (Join-Path (Join-Path $DependencyFolder 'Depend-NuGet') $NugetPackageName) $PathToDll
if (-not (& "$PSScriptRoot\Test-PSSessionVariableEntry.ps1" -VariableName $SessionLogVariableName -Value $filePath)) {
    .. do something that you only want to happen once per session
    & "$PSScriptRoot\Add-PSSessionVariableEntry.ps1" -VariableName $SessionLogVariableName -Value $filePath
}
#>
function Add-PSSessionEntry {
    param(
        [parameter(Mandatory)]
        [string] $GlobalVariableName, # = 'VegaDependencies'
        [parameter(Mandatory)]
        [string] $CollectionName,
        [parameter(Mandatory)]
        [Alias('Value')]
        [string[]] $Values
    )
    try {
        $collection = Initialize-PSSessionVariable -GlobalVariableName $GlobalVariableName -CollectionName $CollectionName
        foreach ($value in $Values) {
            $null = $collection.Add($Value)
        }
    } catch {
        throw
    }
}
