function Set-ObjectProperty {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][Alias('InputObject')][PSCustomObject]$ObjectModel,
        # expects each key to have the path to the item in the object model
        [Parameter(ParameterSetName = 'Hashtable', Mandatory)][hashtable]$Hashtable,
        [Parameter(ParameterSetName = 'Single', Mandatory)][string]$Path,
        [Parameter(ParameterSetName = 'Single')][object]$Value,
        [Parameter()][switch]$SecretsOnly
    )
    function Set-ObjectModelValueSingle {
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory)][PSCustomObject]$ObjectModel,
            [Parameter(Mandatory)][string]$Path,
            [Parameter()][object]$Value,
            [Parameter()][switch]$SecretsOnly
        )

        if ($SecretsOnly.IsPresent -and $Value.GetType().Name -ne "SecureString") {
            throw "SecretsOnly specified but non SecureString value given"
        }
        $propertyName = ($path.Split('.'))[-1]
        Write-Debug "`$propertyName:$propertyName"
        if (-not $path.Contains('.')) {
            if ($PSCmdlet.ShouldProcess('Set value')) {
                $ObjectModel | Add-member NoteProperty -Name $propertyName -Value $Value -force
            }
        }
        else {
            $baseObjectPath = $path.Substring(0, $path.LastIndexOf('.'))
            Write-Debug "`$baseObjectPath:$baseObjectPath"
            if ($PSCmdlet.ShouldProcess('Set value')) {
                Get-ObjectModelValue -ObjectModel $ObjectModel -Path $baseObjectPath |
                Add-member NoteProperty -Name $propertyName -Value $Value -force
            }
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Single') {
        $splat = @{
            ObjectModel = $ObjectModel
            SecretsOnly = $SecretsOnly
            Path        = $Path
            Value       = $Value
        }
        Set-ObjectModelValueSingle @splat
    }
    else {
        foreach ($_item in $Hashtable.GetEnumerator()) {
            $splat = @{
                ObjectModel = $ObjectModel
                SecretsOnly = $SecretsOnly
                Path        = $_item.Key
                Value       = $_item.Value
            }
            Set-ObjectModelValueSingle @splat
        }
    }

}
# add alias Set-ObjectModelValue for Set-ObjectProperty
Set-Alias -Name Set-ObjectModelValue -Value Set-ObjectProperty
