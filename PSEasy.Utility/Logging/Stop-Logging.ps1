function Stop-Logging {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification ='We would never want this to be prevented')]
    [CmdletBinding()]
    param()
    try {
        $null = Stop-Transcript
    }
    catch {
        Write-Warning "Unable to Stop-Transcript. $($_.Exception.Message)"
    }
}
