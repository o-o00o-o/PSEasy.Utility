<#
.SYNOPSIS
Includes all PowerShell script files in the specified path into the current session, excluding test scripts.

WILL NOT WORK for any caller outside this module (. includes are applied into the current scope of the caller function, which is the module in this case) - if this is needed, copy and paste this function into your own Initialize script

.PARAMETER Path
The path containing the functions to include. Is recursive

.EXAMPLE

. Invoke-DotInclude -Path "$root\SendAlerts\"

.NOTES
remember to call with . to include the functions into the current session

IMPORTANT - running this anywhere else will not include the functions into the current session, it will include into the module context which will mean they are still not available.

Generally you should copy and paste this into your own function - and try to create a proper module with a manifest and functions that are imported properly
#>
function Invoke-DotInclude {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][string[]]$Exclude

    )
    $Exclude += '*.Tests.ps1'
    Get-ChildItem $Path -Filter '*-*.ps1' -File -Recurse -Exclude $Exclude |
    ForEach-Object {
        Write-Debug "Including $_"
        . $_
    } # get all functions into this session so they can be used
}
