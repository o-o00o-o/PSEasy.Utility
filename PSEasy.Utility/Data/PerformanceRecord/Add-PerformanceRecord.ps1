function Add-PerformanceRecord {
    param(
        [System.Collections.Generic.Dictionary[String, PSCustomObject]] $PerformanceStore,
        [bool]$RecordPerformance,
        [string]$Stage = $null,
        [string]$Entity = $null,
        [Parameter()][ValidateSet('Host', 'Verbose', '')][string]$WriteTo
    )
    if ($RecordPerformance) {
        $PerformanceStore.Add(
            (Get-PerformanceRecordKey -Stage $Stage -Entity $Entity),
            [PSCustomObject]@{
                Stage     = $Stage
                Entity    = $Entity
                WriteOut  = $WriteTo
                Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            })

        if ($WriteTo) {

            $msg = "START: $(Get-PerformanceRecordMessage -Stage $Stage -Entity $Entity)"

            if ($WriteTo -eq 'Host') {
                Write-Host $msg -ForegroundColor Blue
            } elseif ($WriteTo -eq 'Verbose') {
                Write-Verbose $msg
            }
        }
    }

}
