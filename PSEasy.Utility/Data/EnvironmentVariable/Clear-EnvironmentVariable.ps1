function Clear-EnvironmentVariable {
    param(
        [string]$Name
    )
    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::User)) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::User)
    }
    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Process)) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Process)
    }
    if ([System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Machine)) {
        [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Machine)
    }

}
