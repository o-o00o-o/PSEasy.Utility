function Get-NullIf {
    param(
        [Parameter(Position = 1)]$InputObject,
        [Parameter(Position = 2)]$NullIfValue
    )
    if ($InputObject -eq $NullIfValue) {
        Write-Output $null
    } else {
        Write-Output $InputObject
    }
}
