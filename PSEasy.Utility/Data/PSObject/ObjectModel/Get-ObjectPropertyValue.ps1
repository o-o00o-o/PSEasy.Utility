function Get-ObjectPropertyValue {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(<#Category#>'PSAvoidUsingInvokeExpression', <#CheckId#>'', Justification = 'We are protecting the call to ensure that it is safe before Invoking', Scope='function')]
    param(
        [Parameter(Mandatory)][Alias('InputObject')][PSCustomObject]$ObjectModel,
        [Parameter(Mandatory)][string]$Path,
        # array of known secret paths to check against for extra checking
        [Parameter()][string[]]$KnownSecrets = @()
    )
    # TODO change this to walking up the properties
    # Also check we are PSCustomObject all the way to prevent mistakes forgetting to convert hashtable to pscustobject
    # Only execute this if we think it is safe to prevent injection attacks
    if (Test-ObjectModelPathIsSafe -ObjectModel $ObjectModel -Path $path -KnownSecrets $KnownSecrets) {
        $out = Invoke-Expression "`$ObjectModel.$Path"
        if ($out.GetType().Name -eq 'PropertyName') {
            $out = $out.Value
        }
        return $out
    }
}
Set-Alias -Name Get-ObjectModelValue -Value Get-ObjectPropertyValue
