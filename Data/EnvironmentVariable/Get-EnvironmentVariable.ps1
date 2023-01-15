function Get-EnvironmentVariable {
    param(
        [string]$Name,
        [System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::User
    )
    Write-Output ([System.Environment]::GetEnvironmentVariable($Name, $Target))
}
