
function Start-Logging {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # will try to find a log folder in the current or parent folder that we have permission to write to, otherwise will write to the users temporary folder
        [parameter()]
        [string]
        $PreferredFolder = 'log',

        [parameter(Mandatory)]
        [string]
        $ApplicationName,

        [parameter(Mandatory)]
        [string]
        $CommandName,

        [parameter()]
        [string[]]
        # Allows passing in a caller Callstack from another process (e.g. when we call from Invoke-BuildDeploy)
        $CallStack,

        [parameter()]
        [string]
        $CallStackRootLine,

        [parameter()]
        [switch]
        $NoRemoveLog
    )
    try {
        if (-not $NoRemoveLog) {
            Remove-Log -PreferredFolder $PreferredFolder -ApplicationName $ApplicationName
        }
    } catch {
        # our mission is to start-logging, so if we can't cleanup - not the end of the world
        $_ | Get-Error | Out-String | Write-Warning
    }

    # check if we have permissions - otherwise don't log
    $logPath = (Get-LogPath -PreferredFolder $PreferredFolder -CommandName $CommandName -ApplicationName $ApplicationName)
    try {
        Start-Transcript -LiteralPath $logPath -NoClobber -IncludeInvocationHeader
        # get the original command line being executed so it is at the top of the log

        if (-not $CallStack) {
            $CallStack = (Get-PSCallStack | Foreach-Object {$_.InvocationInfo.Line})
        }

        $StackString = [System.Text.StringBuilder]::new()

        for ($i = -2; #
            $i -ge $CallStack.Length * -1; # exclude ourselves
            $i-- ) {
            $null = $StackString.Append(" > $($CallStack[$i])")
        }

        if ($CallStackRootLine) {
            "EXECUTING ROOT COMMAND LINE : $($CallStackRootLine)" | Write-Host -ForegroundColor DarkBlue
        } else {
            "EXECUTING COMMAND LINE $([Environment]::NewLine)$($StackString.ToString())" | Write-Host  -ForegroundColor DarkBlue
        }
    } catch {
        Write-Warning "Unable to Start-Transcript for $logPath. $($_.Exception.Message)"
    }
}
