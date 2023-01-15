function Test-UserPrivilegeAdmin
{
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)

    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
      Write-Output $true
    } else {
      Write-Output $false
    }
 }
