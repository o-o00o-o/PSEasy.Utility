function Test-HasProperty {
    [OutputType([bool])]
    param(
        [Parameter(Position = 1, ValueFromPipeline)][PSCustomObject]$InputObject
    )
    Write-Output ($InputObject.PSObject.Properties.GetEnumerator().MoveNext())
}
