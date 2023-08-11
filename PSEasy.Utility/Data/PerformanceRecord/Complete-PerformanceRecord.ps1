
function Complete-PerformanceRecord {
    param(
        [System.Collections.Generic.Dictionary[String, PSCustomObject]] $PerformanceStore,
        [bool]$RecordPerformance = $true,
        [string]$Key,
        [string]$Stage,
        [string]$Entity
    )
    if ($RecordPerformance) {
        if (-not $Key) {
            $Key = (Get-PerformanceRecordKey -Stage $Stage -Entity $Entity)
        }
        $item = $PerformanceStore[$Key]
        if (-not $item) {
            throw "couldn't find item in performance store for key: $Key"
        }
        $item.Stopwatch.Stop()

        if ($item.WriteOut) {
            $msg = "DONE: $(Get-PerformanceRecordMessage -Stage $item.Stage -Entity $item.Entity). Duration: $($item.Stopwatch.Elapsed)"

            if ($item.WriteOut -eq 'Host') {
                Write-Host $msg -ForegroundColor Blue
            } elseif ($item.WriteOut -eq 'Verbose') {
                Write-Verbose $msg
            }
        }

    }
}
