#Requires -modules ErrorView
<#<#
.SYNOPSIS
If ErrorView module is installed then set the Error view

.DESCRIPTION
It is usually useful to have the full stack trace included in any error

On workstations typically this is best set in your profile.
For Azure Devops tasks however you need to set at the top of each script you want it to apply to

.EXAMPLE
Set-ErrorView -ErrorView 'FullView'

.NOTES
Requires Install-Module ErrorView has happened
#>#>
function Set-ErrorView {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $ErrorView = 'FullView' # this one includes stack trace
    )

    if (Get-Module -ListAvailable ErrorView) {
        # We must import first
        if ($PSCmdlet.ShouldProcess('$ErrorView')) {
            Import-Module ErrorView
            $ErrorView = 'FullView'
        }
    }
}
