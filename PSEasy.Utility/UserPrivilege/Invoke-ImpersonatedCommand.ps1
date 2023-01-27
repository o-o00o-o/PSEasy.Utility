#requires -version 7.0
<#<#
.SYNOPSIS
Short description

.DESCRIPTION

Cobbled together
https://stackoverflow.com/questions/46535321/run-start-process-with-switch-netonlytype-9-logon

Invoke-Impersonate -User

.PARAMETER User
Parameter description

.PARAMETER Domain
Parameter description

.PARAMETER Password
Parameter description

.PARAMETER NetOnly
Parameter description

.PARAMETER Script
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>#>
function Invoke-ImpersonatedCommand {
    param(
        # user can be either domain\user or user@domain
        [Parameter(Mandatory, ParameterSetName = 'cred')][pscredential]$Credential,
        [Parameter(Mandatory, ParameterSetName = 'separate')][string]$User,
        [Parameter(ParameterSetName = 'separate')][string]$Domain,
        [Parameter(Mandatory, ParameterSetName = 'separate')][SecureString]$Password,
        # will only use the credentials for remote activity. Useful when accessing a non-trusted domain
        [Parameter()][Switch]$NetOnly,
        # The script to execute
        [Parameter(Mandatory)][ScriptBlock]$Script,
        # If Async is set then we will not wait for completion otherwise we will wait and the command will be created as a new operation
        [Parameter()][Switch]$Async
    )

    function Get-UserAndDomain {
        param(
            [Parameter(Mandatory)]$User,
            [Parameter()]$Domain
        )

        if ($User -match '^(?:(?<DomainBefore>[^\\]+)\\)?(?<User>[^@]+)(?:@(?<DomainAfter>.+))?$') {
            if ($Domain) {
                if ($User -contains '@' -or $User -contains '\') {
                    throw "domain $Domain was given and $User was in unexpected format. Should be username only"
                }
                $foundDomain = $Domain
                $foundUser = $User
            }
            elseif ($matches.DomainBefore) {
                if ($DomainBefore -contains '@') {
                    throw "$User was in unexpected format. Should be either username (with domain provided as separate argument), domain\username or username@domain"
                }
                $foundDomain = $matches.DomainBefore
                $foundUser = $matches.User
            }
            else {
                $foundDomain = ''
                $foundUser = $User
            }
        }
        else {
            throw "$User was in unexpected format. Should be either username (with domain provided as separate argument), domain\username or username@domain"
        }
        $out = [PSCustomObject]@{
            Domain = $foundDomain
            User = $foundUser
        }
        Write-Verbose ($out | Format-List | Out-String)
        Write-Output $out
    }

    if ($PSCmdlet.ParameterSetName -eq 'cred') {
        $UserAndDomain = Get-UserAndDomain -User $Credential.Username
        $Password = $Credential.Password
    }
    else {
        $UserAndDomain = Get-UserAndDomain -User $User -Domain $Domain
    }
    $User = $UserAndDomain.User
    $Domain = $UserAndDomain.Domain

    # https://learn.microsoft.com/en-us/dotnet/api/system.security.principal.windowsidentity.runimpersonated?view=net-7.0#system-security-principal-windowsidentity-runimpersonated(microsoft-win32-safehandles-safeaccesstokenhandle-system-action)
    $ImpersonationLib = Add-Type -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition @"
[DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool LogonUser(String lpszUsername, String lpszDomain, String lpszPassword, int dwLogonType, int dwLogonProvider, out Microsoft.Win32.SafeHandles.SafeAccessTokenHandle phToken);
"@ -PassThru
    # [System.IntPtr]$userToken = [System.IntPtr]::Zero
    $safeAccessUserToken = [Microsoft.Win32.SafeHandles.SafeAccessTokenHandle]::new()
    if ($NetOnly) {
        $LogonType = 9 # net only LOGON32_LOGON_NEW_CREDENTIALS
    }
    else {
        $LogonType = 2 # LOGON32_LOGON_INTERACTIVE full login
    }

    $success = $ImpersonationLib::LogonUser($User, # UserName
        $Domain, # Domain
        "$($Password | ConvertFrom-SecureString -AsPlainText)", # Password
        $LogonType, # LogonType
        0, # LOGON32_PROVIDER_DEFAULT
        [ref]$safeAccessUserToken)

    if ($success -eq $false) {
        [int]$ret = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() # this must come immediately after the win32 call (no write-hosts etc)
        Write-Host "Failure to execute logon user. Error Code $ret"
        throw [System.ComponentModel.Win32Exception]::new($ret)
    }

    Write-Verbose "Before impersonation: UserName: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    $adjustedScript = @"
Write-Host "Starting Invoke-CommandImpersonated as `$([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
$($Script.ToString())
Write-Host "Completed Invoke-CommandImpersonated"
"@
$adjustedScriptBlock = [scriptblock]::Create($adjustedScript)
    if (-not $Async) {
        [Security.Principal.WindowsIdentity]::RunImpersonated($safeAccessUserToken, $adjustedScriptBlock)
    }
    else {
        # for some reason this still behaves as synchronous. Need further investigation
        #$action = [System.Threading.Tasks.Task]::new($adjustedScriptBlock) # this can be run with runsyncrhonouse
        $action = [System.Func[System.Threading.Tasks.Task]]$adjustedScriptBlock
        # [Security.Principal.WindowsIdentity]::RunImpersonatedAsync($safeAccessUserToken, ([System.Func[ScriptBlock]]$adjustedScriptBlock))
        [Security.Principal.WindowsIdentity]::RunImpersonatedAsync($safeAccessUserToken, [System.Func[System.Threading.Tasks.Task]]$action)
    }
    # New user.
    # Write-Host "After impersonation: UserName: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)" -ForegroundColor Cyan


    # # Return to original user.
    # $context.Undo()
    # $context.Dispose()
    # # Old user.
    # Write-Host "After undoing impersonation: UserName: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
}
