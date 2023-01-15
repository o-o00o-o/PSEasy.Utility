function Get-FileLockProcess {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        # Specifies a path to the file to be modified
        [Parameter(Mandatory = $true)]
        $path ,
        # don't sanitise the output
        [switch]$Raw
    )
    #adding using reflection to avoid file being locked
    $bytes = [System.IO.File]::ReadAllBytes($($PSScriptRoot + "\lib\LockedProcess.dll"))
    [System.Reflection.Assembly]::Load($bytes) | Out-Null
    $process = @{}
    $path = Get-Item -Path $path
    if ($path.PSIsContainer) {
        Get-ChildItem -Path $path -Recurse | ForEach-Object {
            $TPath = $_
            try { [IO.File]::OpenWrite($TPath.FullName).close() }
            catch {
                if (! $TPath.PSIsContainer) {
                    $resp = $([FileUtil]::WhoIsLocking($TPath.FullName))
                }
                foreach ($k in $resp.Keys) {
                    if (! $process.ContainsKey($k)) {
                        $process.$k = $resp.$k
                    }
                }
            }
        }
    } else {
        $process = $([FileUtil]::WhoIsLocking($path.FullName))
    }
    #adding additional details to the hash
    $processList = @()
    foreach ($id in $process.Keys) {
        $temp = @{}
        $temp.Name = $process.$id
        $proc = Get-CimInstance Win32_Process -Filter $("ProcessId=" + $id)
        $proc = Invoke-CimMethod -InputObject $proc -MethodName GetOwner
        if ($proc.Domain -ne "") {
            $temp.Owner = $proc.Domain + "\" + $proc.User
        } else {
            $temp.Owner = $proc.User
        }
        $temp.PID = $id
        $processList += $temp
    }
    if ($Raw) {
        $processList
    } else {
        $processList.ForEach({ [PSCustomObject]$_ }) | Format-Table -AutoSize
    }
}
