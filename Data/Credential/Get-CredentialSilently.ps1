<#
.SYNOPSIS
Gets a credential without prompting the user

.DESCRIPTION
https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Security/Get-Credential?view=powershell-7.3#example-4

.PARAMETER UserName
Parameter description

.PARAMETER Password
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-CredentialSilently {
    param(
        [string]$UserName,
        [SecureString]$Password
    )
    New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
}
