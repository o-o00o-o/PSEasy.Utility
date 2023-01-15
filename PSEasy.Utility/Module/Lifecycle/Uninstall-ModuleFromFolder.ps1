function Uninstall-ModuleFromFolder {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "The path to the folder containing the module that you want to install")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ModuleName
    )
    begin {
        Set-StrictMode -Version 2.0
        $UserModulePath = Get-ModuleUserFolder
    }

    process {
        foreach ($_ModuleName in $ModuleName) {
            if (-not (Test-Path $UserModulePath)) {
                Write-Host "User Module Path $UserModulePath doesn't exist"
            } else {
                $ModulePath = Join-Path $UserModulePath $_ModuleName
                if (Test-Path $ModulePath) {
                    Write-Host "User Module Path $ModulePath Removed"
                    Remove-Item $ModulePath -Recurse -force
                } else {
                    Write-Host "User Module Path $ModulePath doesn't exist, nothing to remove"
                }
            }
        }
    }

    end {

    }
}
