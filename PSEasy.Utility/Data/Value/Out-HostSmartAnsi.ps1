
<#
.SYNOPSIS
Provides the same colouring as Write-Output does but to the host instead.

.DESCRIPTION
Write-Output performs differently to Write-Host when it is passed an object because Write-Host converts everything to a string. When you provide an object or collection you really want to see the contents, not the datatype. To handle this you typically do something like $blah | Format-List | Out-String | Write-Host (or $blah | Format-List | Out-Host which is virtually identical)

However when you use that method you lose any colouring that you would normally get, that is provided by the Powershell formatter that adds ANSI colour indicators to the output.

However you don't want these ANSI codes when the host isn't a terminal that can interpret these ANSI codes - as it becomes noisy.

This function attempts to solve this problem with a simple call

.PARAMETER InputObject
The object that you want to send to the host

.EXAMPLE

try {
    throw 'blah'
}
catch {
    $_ | Get-Error | Out-HostSmartAnsi
}

.NOTES

Solution achieved thanks to https://stackoverflow.com/questions/78845668/is-there-any-way-to-send-the-nice-colouring-that-write-output-achieves-through-w/78845689#78845689

#>
function Out-HostSmartAnsi {
    [CmdletBinding()]
    Param(
        # The object to print
        [Parameter(ValueFromPipeline)]
        [object]
        $InputObject
    )
    $previousOutputRendering = $PSStyle.OutputRendering
    $PSStyle.OutputRendering = [Console]::IsOutputRedirected ? 'PlainText' : 'ANSI'
    $InputObject | Out-Host
    $PSStyle.OutputRendering = $previousOutputRendering

}
