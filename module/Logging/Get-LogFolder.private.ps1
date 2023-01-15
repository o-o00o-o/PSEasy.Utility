function Get-LogFolder {
    param (
        # in order to find the folder to log to we are given the root folder pattern to traverse up to
        [parameter()][string]$PreferredFolder = 'log',
        [parameter(Mandatory)][string]$ApplicationName
    )
    $havePermissions = $false

    if ($PreferredFolder) {
        $logFolder = Find-item -Directory -ItemName $PreferredFolder
        # check we can write to it
        if ($logFolder) {
            $testFilename = [guid]::NewGuid()
            try {
                $null = New-Item $testFilename -WhatIf:$false -Confirm:$false
                $havePermissions = $true
            }
            catch {
                Write-Warning "Found log folder $($logFolder.FullName) however we couldn't write a file to it so we are falling back to the temp folder. ($_)"
            }
            finally {
                $null = Remove-Item $testFilename -WhatIf:$false -Confirm:$false
            }
        }
    }

    if (-not $logfolder -or -not $havePermissions) {
        $logFolder = Join-Path $ENV:TEMP $ApplicationName
        # create the folder
        $null = New-Item $logfolder -force -ItemType Directory
    }

    Write-Output $logFolder
}
