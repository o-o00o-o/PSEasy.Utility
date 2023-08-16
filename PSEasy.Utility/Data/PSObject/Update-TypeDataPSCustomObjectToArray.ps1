<#
.SYNOPSIS
    Creates the following Methods on all PSCustomObjects in this session
     - ToArray
#>

Update-TypeData -TypeName "System.Management.Automation.PSCustomObject" -WhatIf:$false -MemberType ScriptMethod -Force -MemberName "ToArray" -Value { #$ConvertToArrayOfPropertiesScript
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Position = 1)][string]$AddPropertyNameAs = 'Name'
    )
    ConvertTo-Array -InputObject $this -AddPropertyNameAs $AddPropertyNameAs #-ReadOnly
}

# world like to use ConvertTo-Array for this but because it works on a pipeline we can't detect 0 members
Update-TypeData -TypeName "System.Management.Automation.PSCustomObject" -WhatIf:$false -MemberType ScriptMethod -Force -MemberName "HasProperties" -Value { #$ConvertToArrayOfPropertiesScript
    [OutputType([bool])]
    param()
    Write-Output (Test-HasProperty -InputObject $this)
}

# It really would be better to not have to put () at the end but it doesn't work as a property
#    This actually hangs the whole system. We think due to https://github.com/PowerShell/PowerShell/issues/5797
# Update-TypeData -TypeName "System.Management.Automation.PSCustomObject" -MemberType ScriptProperty -Force -MemberName "ToArray" -Value { #$ConvertToArrayOfPropertiesScript
#     & "$PSScriptRoot\ConvertTo-Array.ps1" -InputObject $this -ReadOnly
#}

# this is an option for a temporary workaround for the ConvertTo-Array optimisation - we used to use a custom object with a Value property to store the name value but we now just use a string for performance. Add a dummy Value property so that existing scripts continue to work for now
# update-TypeData -TypeName "System.String" -MemberType ScriptProperty -MemberName 'Value' -Value {
#     [OutputType([string])]
#     param()
#     Write-Output ($this)
# }
