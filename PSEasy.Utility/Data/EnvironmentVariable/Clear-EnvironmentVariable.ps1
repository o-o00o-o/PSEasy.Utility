function Clear-EnvironmentVariable {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][string]$Name,
        [parameter()][string]$Target
    )
    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::User) -and
        (   -not $Target -or
          $Target -eq [System.EnvironmentVariableTarget]::User
         )) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::User)
    }

    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Process) -and
    (   -not $Target -and
        $Target -eq [System.EnvironmentVariableTarget]::Process
     )) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Process)
    }

    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Machine) -and
    (   -not $Target -or
        $Target -eq [System.EnvironmentVariableTarget]::Machine
     )) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Machine)
    }

}
