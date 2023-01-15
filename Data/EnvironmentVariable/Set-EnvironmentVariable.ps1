function Set-EnvironmentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param(
        [string]$Name,
        [string]$Value,
        [System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::User
    )
    if ((Get-EnvironmentVariable -Name $Name -Target $Target) -ne $Value) {
        Write-Host "Setting Environment Variable $Name. " -NoNewline
        Write-Host "NOTE: These will only take effect after restart of services/console" -ForegroundColor Magenta
        [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }
}
