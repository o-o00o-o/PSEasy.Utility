function Test-SecureStringEmpty {
    param(
        [Parameter(Position = 1)]
        [SecureString]
        $SecureString
    )
    try {
        # get the insecure string so we can tell if we put nothing in the secure string (ConvertFrom-SecureString will error in this case)
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SecureString)
        $insecureInput = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
        if ($insecureInput -ne '') {
            Write-Output $false
        } else {
            Write-Output $true
        }
    } catch {
        throw
    }
}
