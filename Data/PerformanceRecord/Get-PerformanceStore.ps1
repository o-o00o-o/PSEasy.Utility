function Get-PerformanceStore {
    param(
        [int]$InitialCapacity = 10000
    )
    Write-Output ([System.Collections.Generic.Dictionary[String, PSCustomObject]]::new($InitialCapacity, [StringComparer]::CurrentCultureIgnoreCase))
}
