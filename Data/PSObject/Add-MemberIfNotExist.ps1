function Add-MemberIfNotExist {
    [CmdletBinding(PositionalBinding)]
    param(
        [Parameter(Position=1)][PSCustomObject] $Container,
        [Parameter(Position=2)][string]         $ItemName,
        [Parameter(Position=3)][PSCustomObject] $Item
    )

    if (-not $Container.PSObject.Properties[$ItemName]) {
        Write-Verbose "adding $ItemName to $($Container.PSObject.TypeNames[0])"
        $Container | Add-Member $ItemName $Item
    }
}
