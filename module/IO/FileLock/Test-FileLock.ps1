function Test-FileLock {
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )
    if (Test-Path -Path $Path) {
        $oFile = New-Object System.IO.FileInfo $Path
        try {
            $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            if ($oStream) {
                $oStream.Close()
                $oStream.Dispose()
            }
            return $false # no lock
        } catch {
            return $true # file is locked by a process.
        } finally {
        }
    } else {
        return $false
    }
}
