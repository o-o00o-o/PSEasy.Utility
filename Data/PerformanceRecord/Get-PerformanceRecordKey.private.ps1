function Get-PerformanceRecordKey {
    param(
        [string]$Stage,
        [string]$Entity
    )
    Write-Output "$($Stage)|$($Entity)"
}
