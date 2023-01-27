<#<#
.SYNOPSIS
Run Powershell Script as a different user with simplified argument passing

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>#>
function Invoke-PowershellAsUser {
    [CmdletBinding()]
    param (
        [Parameter()][pscredential]$Credential,
        [Parameter()][switch]$NoProfile,
        [Parameter()][switch]$NoExit,
        [Parameter()][string]$Script,
        [Parameter(ParameterSetName = 'ArgsAsHashtable')][hashtable]$Splat,
        [Parameter(ParameterSetName = 'ArgsAsRemainingArgs', ValueFromRemainingArguments)][string[]]$RemainingArguments
        <#
        ## TODO consider adding a scriptblock param that uses EncodedCommand so it doesn't have trouble with nested quoting
        For example:

        $command = 'dir "c:\program files" '
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        pwsh -encodedcommand $encodedCommand
        #>
    )
    # Import-Module RunAs
    $pwshArgs = [System.Collections.Generic.List[String]]::new()
    $null = $pwshArgs.Add('-NonInteractive')
    if ($NoProfile) {
        $null = $pwshArgs.Add('-NoProfile')
    }
    if ($NoExit) {
        $null = $pwshArgs.Add('-NoExit')
    }
    $null = $pwshArgs.Add('-File')
    $null = $pwshArgs.Add($Script)
    if ($PSCmdlet.ParameterSetName -eq 'ArgsAsRemainingArgs') {
        $null = $pwshArgs.Add($RemainingArguments)
    }
    else {
        foreach ($item in $Splat.GetEnumerator()) {
            $null = $pwshArgs.Add("-$($Item.Key)")
            $null = $pwshArgs.Add($Item.Value)
        }
    }
    # RunAs -Env -User $Credential -Program pwsh -Arguments $pwshArgs
    Invoke-RunAs -User $Credential -Program pwsh -Arguments $pwshArgs -verbose:([bool]$PSBoundParameters['Verbose'])
}
