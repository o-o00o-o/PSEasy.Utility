function Get-ObjectModelValue {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(<#Category#>'PSAvoidUsingInvokeExpression', <#CheckId#>'', Justification = 'We are protecting the call to ensure that it is safe before Invoking', Scope='function')]
    param(
        [Parameter(Mandatory)][PSCustomObject]$ObjectModel,
        [Parameter(Mandatory)][string]$Path,
        # array of known secret paths to check against for extra checking
        [Parameter()][string[]]$KnownSecrets = @()
    )
    # Only execute this if we think it is safe to prevent injection attacks
    if (Test-ObjectModelPathIsSafe -ObjectModel $ObjectModel -Path $path -KnownSecrets $KnownSecrets) {
        $out = Invoke-Expression "`$ObjectModel.$Path"
        if ($out.GetType().Name -eq 'PropertyName') {
            $out = $out.Value
        }
        return $out
    }
}
