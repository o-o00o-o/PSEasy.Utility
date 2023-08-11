function Get-PerformanceRecordMessage {
    param(
        [string]$Stage,
        [string]$Entity
    )
    Write-Output "$([string]::Join(' | ', (($Stage, $Entity) | where-Object {$_})))"
}
