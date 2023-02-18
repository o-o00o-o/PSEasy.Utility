<##https://stackoverflow.com/questions/46535321/run-start-process-with-switch-netonlytype-9-logon
#>
function Start-Impersonate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $User,
        $Domain,
        [SecureString]$Password,
        [Switch]$NetOnly
    )
    $ImpersonationLib = Add-Type -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition @"
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool DuplicateToken(IntPtr token, int impersonationLevel, ref IntPtr duplication);

[DllImport("kernel32.dll")]
public static extern Boolean CloseHandle(IntPtr hObject);
"@ -PassThru
    [System.IntPtr]$userToken = [System.IntPtr]::Zero

    if ($NetOnly) {
        $Type = 9 # net only LOGON32_LOGON_NEW_CREDENTIALS
    } else {
        $Type = 2 # LOGON32_LOGON_INTERACTIVE full login
    }

    $success = $ImpersonationLib::LogonUser($User, # UserName
        $Domain,   # Domain
        $Password, #Password
        $Type, # LogonType
        0, # LOGON32_PROVIDER_DEFAULT
        [ref]$userToken)

    if ($success -eq $false) {
        Write-Host 'Failure to execute logon user.'
        Exit
    }

    $Identity = New-Object Security.Principal.WindowsIdentity $userToken
    # Close open handles.
    if ($userToken -ne [System.IntPtr]::Zero) {
        $null = $ImpersonationLib::CloseHandle($userToken)
        $userToken = [System.IntPtr]::Zero
    }

    # Current user.
    Write-Host "Before impersonation: UserName:
$([Security.Principal.WindowsIdentity]::GetCurrent().Name)" -ForegroundColor Cyan
    # Do the impersonation.
    # $context = $Identity.Impersonate()
    if ($PSCmdlet.ShouldProcess('Start Impersonation')) {
        Write-Output $Identity.Impersonate()
    }
    # New user.
    # Write-Host "After impersonation: UserName: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)" -ForegroundColor Cyan


    # # Return to original user.
    # $context.Undo()
    # $context.Dispose()
    # # Old user.
    # Write-Host "After undoing impersonation: UserName: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
}
