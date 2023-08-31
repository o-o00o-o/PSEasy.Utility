<#<#
.SYNOPSIS
Increments the version in both module files (nuspec and psm1)

.DESCRIPTION

.PARAMETER ModulePath
Parameter description

.PARAMETER VersionIncrementType
Parameter description

.EXAMPLE


.NOTES
General notes
#>#>
function Set-ModuleVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][string]$ModulePath = $pwd,
        [Parameter(Mandatory)][ValidateSet('Major', 'Minor', 'Patch', 'None')][string]$VersionIncrementType
    )

    $versionFilePath = (Join-Path $ModulePath '.version')
    $moduleName = (Split-Path $ModulePath -Leaf)
    $moduleDefinitionPath = (Join-Path $ModulePath "$moduleName.psd1")
    $nuspecPath = (Join-Path $ModulePath "$moduleName.nuspec")

    if (-not (Test-Path $versionFilePath)) {
        throw 'Cannot find .version file for this module. This is required'
    }

    [System.Management.Automation.SemanticVersion]$cVer = Get-ModuleVersion -ModulePath $ModulePath
    $nMajor = $cVer.Major + ($VersionIncrementType -eq 'Major')
    $nMinor = if ($VersionIncrementType -eq 'Major') { 0 } else { $cVer.Minor + ($VersionIncrementType -eq 'Minor') }
    $nPatch = if ($VersionIncrementType -eq 'Minor') { 0 } else { $cVer.Patch + ($VersionIncrementType -eq 'Patch') }

    $nVer = [System.Management.Automation.SemanticVersion]::new($nMajor, $nMinor, $nPatch)

    # module definition ps file
    # Note that this regex can get confused with other module version specifications (e.g. RequiredModules)
    # We assume that this is a new line with no spaces before it..
    # this is tricky as Update-ModuleManifest is buggy and it is a powershell code structure instead of a json
    # doc.. so limited simple options
    $moduleDefinitionRegex = "(?<Preamble>\nModuleVersion\s*=\s*)'(?<Major>\d+).(?<Minor>\d+).(?<Patch>\d+)'"
    $moduleDefinitionReplace = "`${Preamble}'$($nVer.Major).$($nVer.Minor).$($nVer.Patch)'"

    (Get-Content $moduleDefinitionPath -raw) -replace $moduleDefinitionRegex, $moduleDefinitionReplace |
    Out-File $moduleDefinitionPath -NoNewline

    # nuspec xml file
    $nuspecRegex = "(?<Preamble>\<version\>)(?<Major>\d+).(?<Minor>\d+).(?<Patch>\d+)(?<Appendix>\</version\>)"
    $nuspecReplace = "`${Preamble}$($nVer.Major).$($nVer.Minor).$($nVer.Patch)`${Appendix}"
    (Get-Content $nuspecPath -raw) -replace $nuspecRegex, $nuspecReplace |
    Out-File $nuspecPath -NoNewline

    # finally write version file
    set-content -Path $versionFilePath -value $nVer.ToString() -Force
}
