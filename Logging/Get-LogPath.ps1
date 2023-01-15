function Get-LogPath {
    param (
        # in order to find the folder to log to we are given the root folder pattern to traverse up to
        [parameter(Mandatory)][string]$ApplicationName,
        [parameter()][string]$PreferredFolder = 'log',
        [parameter(Mandatory)][string]$CommandName
    )
    $logFolder = Get-LogFolder -PreferredFolder $PreferredFolder -ApplicationName $ApplicationName

    Write-Output (Join-Path -Path $logFolder -ChildPath ("$CommandName $([DateTime]::Now.ToString('yyyy-MM-dd HH-mm-ss')).log"))
}
