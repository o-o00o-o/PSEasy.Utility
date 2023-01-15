function Get-ModuleUserFolder {
    Write-Output @(($env:PSModulePath.Split(';')) | where-object { $_ -like '*\Users\*' })[0]
}
