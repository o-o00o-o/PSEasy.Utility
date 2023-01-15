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
function Initialize-PSSessionVariable {
param(
    [parameter(Mandatory)]
    [string] $GlobalVariableName,
    [parameter(Mandatory)]
    [string] $CollectionName
)
try {
    if (-not (Test-Path "variable:global:$GlobalVariableName")) {
        Set-Variable -Scope 'Global' -Name $GlobalVariableName -Value ([PSCustomObject]@{}) -WhatIf:$false -Confirm:$false
    }
    $globalVariable = (Get-Variable -Scope 'Global' -Name $GlobalVariableName).Value
    if (-not ($globalVariable.PSObject.Properties[$CollectionName])) {
        $globalVariable | Add-Member $CollectionName ([System.Collections.Generic.HashSet[string]]::new([StringComparer]::InvariantCultureIgnoreCase))
    }
    Write-Output ($globalVariable.PSObject.Properties[$CollectionName].Value) -NoEnumerate
} catch {
    throw
}
}
