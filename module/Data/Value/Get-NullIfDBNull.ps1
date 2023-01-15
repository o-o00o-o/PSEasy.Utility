function Get-NullIfDBNull {
    param(
        [Parameter(Position = 1)]$InputObject
    )
    if ($InputObject -is [System.DBNull]) {
        Write-Output $null
    } else {
        Write-Output $InputObject
    }
}
