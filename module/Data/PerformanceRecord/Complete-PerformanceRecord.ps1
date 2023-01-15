
function Complete-PerformanceRecord {
    param(
        [System.Collections.Generic.Dictionary[String, PSCustomObject]] $PerformanceStore,
        [bool]$RecordPerformance,
        [string]$Stage,
        [string]$Entity
    )
    if ($RecordPerformance) {
        $item = $PerformanceStore[(Get-PerformanceRecordKey -Stage $Stage -Entity $Entity)]
        $item.Stopwatch.Stop()

        if ($item.WriteOut) {
            $msg = "DONE: $(Get-PerformanceRecordMessage -Stage $Stage -Entity $Entity). Duration: $($item.Stopwatch.Elapsed)"

            if ($item.WriteOut -eq 'Host') {
                Write-Host $msg -ForegroundColor Blue
            } elseif ($item.WriteOut -eq 'Verbose') {
                Write-Verbose $msg
            }
        }

    }
}
