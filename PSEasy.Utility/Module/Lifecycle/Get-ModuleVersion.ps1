function Get-ModuleVersion {
    param(
        [Parameter(Mandatory)][string]$ModulePath
    )
    $versionFilePath = (Join-Path $ModulePath '.version')
    if (-not (Test-Path $versionFilePath)) {
        [System.Management.Automation.SemanticVersion]$cVer = [System.Management.Automation.SemanticVersion]::new('0.0.1')
        #Set-Content -Path $versionFilePath -value $nVer.ToString() -Force
    } else {
        [System.Management.Automation.SemanticVersion]$cVer = [System.Management.Automation.SemanticVersion]::Parse((Get-Content $versionFilePath))
    }
    Write-Output $cVer
}
