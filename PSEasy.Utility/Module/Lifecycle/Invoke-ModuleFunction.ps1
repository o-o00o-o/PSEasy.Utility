<#<#
.SYNOPSIS
Executes any function in a module (including private ones)

.DESCRIPTION
When debugging modules it is very useful to be able to execute private (non exported) functions
in-place rather than changing their accessibility

.PARAMETER ModuleName
The Module name e.g. PSEasy.Utility

.PARAMETER ScriptBlock
The function to execute in the context of the module. e.g. Get-LogPath @blah

.EXAMPLE
# execute private function in a module (debugging/testing)
Invoke-ModuleFunction 'PSEasy.Utility' {Get-LogPath @blah}

.NOTES
General notes
#>#>
function Invoke-ModuleFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 1)][string]$ModuleName,
        [Parameter(Mandatory, Position = 2)][scriptBlock]$ScriptBlock
    )

    $mod = Get-Module -Name $ModuleName | Import-Module -PassThru
    & $mod $ScriptBlock
}
