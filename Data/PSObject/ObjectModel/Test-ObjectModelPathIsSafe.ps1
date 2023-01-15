# IsPathSafe.
# As we are using Invoke-Expression, we protect against injection here by ensuring that the Path is just a object path e.g. config.path etc
# we also check to make sure that it actually returns something
# Secrets only flag additionally checks that the path is a SecureString and exists in our SecretConfig
# Will return true or false
# if false may  return a warning with the details of the issue if it is just not available
function Test-ObjectModelPathIsSafe {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(<#Category#>'PSAvoidUsingInvokeExpression', <#CheckId#>'', Justification = 'We are protecting the call to ensure that it is safe before Invoking')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(<#Category#>'PSReviewUnusedParameter', <#CheckId#>'ObjectModel', Justification = 'we are using it if you look carefully enough')]

    param(
        # PSObject with the object model to test
        [Parameter(Mandatory)][PSObject]$ObjectModel,
        # the path to check e.g Blah.Blah2
        [Parameter(Mandatory)][string]$Path,
        # array of known secret paths to check against for extra checking
        [Parameter()][string[]]$KnownSecrets = @()
    )
    $return = $false
    if ($Path -imatch '^[a-zA-Z0-9_\.]+$') {
        if ($KnownSecrets -and -not $KnownSecrets -contains $path) {
            Write-Warning "$Path not a known secret. Did you add it to the master secrets list?"
        } else {
            Set-StrictMode -off
            $value = (Invoke-Expression "`$ObjectModel.$Path")
            Set-StrictMode -version 2
            if ($null -ne $value) {
                $returnedTypeName = $value.GetType().Name
                if ($returnedTypeName -eq "PSCustomObject" -or $returnedTypeName -eq "SecureString" -or $returnedTypeName -eq "String") {
                    if ($KnownSecrets -and $returnedTypeName -ne 'SecureString') {
                        Write-Warning "$Path expects type SecureString but was $returnedTypeName. Skipping"
                    } else {
                        $return = $true
                    }
                } elseif ($returnedTypeName -eq "PropertyName") {
                    if ($KnownSecrets.IsPresent -and $value.Value.GetType().Name -ne 'SecureString') {
                        Write-Warning "$Path expects type SecureString but was $($value.Value.GetType().Name). Skipping"
                    } else {
                        $return = $true
                    }
                } else {
                    Write-Warning "$Path returned type $returnedTypeName which was not expected so skipped"
                }
            }
        }
    } else {
        Write-Warning "$Path not considered safe by Regex and so skipped"
    }
    $return
}
