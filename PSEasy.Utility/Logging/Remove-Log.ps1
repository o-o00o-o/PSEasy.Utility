function Remove-Log {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # in order to find the folder to log to we are given the root folder pattern to traverse up to
        [parameter()][string]$PreferredFolder = 'log',
        [parameter(Mandatory)][string]$ApplicationName,

        # cleanup logs older than 5 days (enough for a long bank holiday weekend)
        [Parameter()]
        [int]
        $DaysOld = 5
    )
    $logFolder = Get-LogFolder -PreferredFolder $PreferredFolder -ApplicationName $ApplicationName
    $logsToDelete = @(Get-ChildItem -Path $logFolder | Where-object { $_.CreationTime -lt (Get-Date).AddDays(-$daysOld) })
    if ($logsToDelete) {
        Write-Host "Removing $($logsToDelete.Count) logs older than $daysOld days"
        $logsToDelete | Remove-Item -ErrorAction SilentlyContinue 1>$null # error may happen if this is running in parallel with others
    }
}
