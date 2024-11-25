function Update-ObjectWithTokenReplacement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][PSCustomObject]$InputObject,
        # any properties with this name (wildcards supported) will be excluded (including children). Default is '*splat' which can have infinite nested objects
        [Parameter()][string[]]$ExcludeNameSpec = '*splat',
        # the object to use to replace the token
        [Parameter()][PSCustomObject]$ReplacementObject = $InputObject
    )
    try {

        $TokenPaths = Get-ObjectTokenPath -InputObject $InputObject -ExcludeNameSpec $ExcludeNameSpec
        $TokenPaths | Format-Table -AutoSize -Wrap | Out-String | Write-Verbose

        foreach ($group in ($TokenPaths | Group-Object TokenName)) {
            $Token = $group.Name
            $Replacement = Get-ObjectPropertyValue -InputObject $ReplacementObject -Path $Token

            if ($null -eq $Replacement) {
                Write-Warning "Token $($Token) not found in ReplacementObject"
            }
            else {
                foreach ($item in $group.Group) {
                    $newValue = $item.Value.Replace($item.Token, $Replacement)
                    Write-Verbose "Replacing $($Token) with $($Replacement) in $($item.ObjectPath) to make $($newValue) from $($item.Value)"
                    Set-ObjectProperty -InputObject $InputObject -Path $item.ObjectPath -Value $newValue
                }
            }
        }
    }
    catch {
        throw
    }
}
