function Set-ObjectModelValue {
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
    } else {
        $baseObjectPath = $path.Substring(0, $path.LastIndexOf('.'))
        Write-Debug "`$baseObjectPath:$baseObjectPath"
        if ($PSCmdlet.ShouldProcess('Set value')) {
            Get-ObjectModelValue -ObjectModel $ObjectModel -Path $baseObjectPath | Add-member NoteProperty -Name $propertyName -Value $Value -force
        }
    }
}
