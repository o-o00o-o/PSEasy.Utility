function Get-PerformanceRecord {
    param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[String, PSCustomObject]]
        $PerformanceStore,

        [Parameter(Mandatory)]
        [ValidateSet('Stage', 'Entity')]
        $By,

        [Parameter()]
        [ValidateSet('TotalDuration (ms)', 'Name')]
        $OrderBy
        )
        function totalDuration {
            Write-Output (
                @{
                    Name       = 'TotalDuration (ms)'
                    Expression = { ($_.Group | Measure-Object { $_.Stopwatch.ElapsedMilliseconds } -Sum).Sum }
                }
            )
        }

        function avgDuration {
            Write-Output (
                @{
                    Name       = 'AverageDuration (ms)'
                    Expression = { ($_.Group | Measure-Object { $_.Stopwatch.ElapsedMilliseconds } -Average).Average }
                }
            )
        }
    if ($By -eq 'Stage') {
        $group = $PerformanceStore.Values |
        Group-Object Stage
    } elseif ($By -eq 'Entity') {
        $group = $PerformanceStore.Values |
        Where-Object Entity -ne '' |
        Group-Object { ($_.Entity.Split(' \ '))[0] }
    } else {
        throw "invalid by parameter '$by'"
    }

    Write-Host ([string]::new('-', 80)) -ForegroundColor Blue

    Write-Host "Performance by $By ordered by $orderBy" -ForegroundColor Blue

    $group |
    Select-Object name, count, (totalDuration), (avgDuration) |
    Sort-Object $orderBy |
    Format-Table Name,
        count,
        @{Expression = 'TotalDuration (ms)' ; FormatString = '#,##0' },
        @{Expression = 'AverageDuration (ms)' ; FormatString = '#,##0.00' } |
    Out-String | Write-Host -ForegroundColor Blue

    Write-Host ([string]::new('-', 80)) -ForegroundColor Blue

}
