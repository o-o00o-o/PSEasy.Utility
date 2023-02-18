function Stop-Impersonate {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    # need to test whether this is enough or not.. it may be that we need to persist the created identity as a module variable
    if ($PSCmdlet.ShouldProcess('Undo Impersonation')) {
        [Security.Principal.WindowsIdentity]::GetCurrent().Undo()
    }
}
