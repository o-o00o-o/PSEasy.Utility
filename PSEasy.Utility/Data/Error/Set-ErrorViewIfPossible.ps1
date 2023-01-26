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
function Set-ErrorViewIfPossible {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        <#Category#>'PSAvoidGlobalVars',<#CheckId#>'',
        Justification = 'ErrorView uses globals'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        <#Category#>'PSUseDeclaredVarsMoreThanAssignments',<#CheckId#>'',
        Justification = 'global variable for use by the system'
    )]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $View = 'FullView' # this one includes stack trace
    )

    if (Get-Module -ListAvailable ErrorView) {
        # We must import first
        if ($PSCmdlet.ShouldProcess('$View')) {
            Import-Module ErrorView
            Write-Verbose "Setting `$ErrorView = $View"
            #TODO change to use Set-ErrorView from ErrorView module
            $global:ErrorView = $View
        }
    } else {
        Write-Verbose "ErrorView module not available so not setting `$ErrorView"
    }
}
