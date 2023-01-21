function Clear-EnvironmentVariable {
    param(
        [string]$Name,
        [System.EnvironmentVariableTarget]$Target
    )
    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::User -and
        (   $Target -eq [System.EnvironmentVariableTarget]::User -or
            -not $Target
         ))) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::User)
    }

    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Process) -and
    (   $Target -eq [System.EnvironmentVariableTarget]::Process -or
        -not $Target
     )) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Process)
    }

    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Machine) -and
    (   $Target -eq [System.EnvironmentVariableTarget]::Machine -or
        -not $Target
     )) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Machine)
    }

}
