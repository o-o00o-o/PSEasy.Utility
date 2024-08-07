#
# Module manifest for module 'PSEasy.Utility'
#
# Generated by: Brett Gerhardi
#
# Generated on: 07/08/2024
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSEasy.Utility.psm1'

# Version number of this module.
ModuleVersion = '1.6.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '2f7008be-ffb1-4be7-a41e-27de2c006c94'

# Author of this module
Author = 'Brett Gerhardi'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) Brett Gerhardi. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Lightweight army of helpers for general powershell activities'

# Minimum version of the PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('ErrorView')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Compress-ArchiveFolder', 'Invoke-CpuArtificialWorkload',
               'Get-CredentialSilently', 'Clear-EnvironmentVariable',
               'Get-EnvironmentVariable', 'Set-EnvironmentVariable',
               'Get-CleanErrorString', 'Set-ErrorViewIfPossible',
               'Invoke-GenericMethod', 'Get-Hash', 'Add-HashtableItem',
               'Remove-HashtableItem', 'Set-HashTableItem', 'Add-PerformanceRecord',
               'Complete-PerformanceRecord', 'Get-PerformanceRecord',
               'Get-PerformanceStore', 'Measure-Command2', 'Get-ObjectModelValue',
               'Set-ObjectModelValue', 'Test-ObjectModelPathIsSafe',
               'Add-MemberIfNotExist', 'ConvertTo-Array', 'ConvertTo-Array2',
               'ConvertTo-Array3', 'ConvertTo-FlatObject', 'ConvertTo-Hashtable',
               'ConvertTo-HashtableBased', 'Edit-ConvertDateTimePropertyToString',
               'Remove-Property', 'Test-HasProperty', 'Add-PSSessionEntry',
               'Initialize-PSSessionVariable', 'Test-PSSessionEntry',
               'ConvertTo-AesKey', 'Test-SecureStringEmpty',
               'Get-HashtableFromRemainingArgument', 'Get-NullIf',
               'Get-NullIfDBNull', 'Format-Xml', 'Test-ContentNoPassword',
               'Test-ContentNoTab', 'Get-FileLockProcess', 'Test-FileLock',
               'Find-Item', 'Rename-FileWithRegex', 'Rename-GitFileWithRegex',
               'Get-LogPath', 'Remove-Log', 'Start-Logging', 'Stop-Logging',
               'Get-Assembly', 'Build-Module', 'Get-ModuleUserFolder',
               'Get-ModuleVersion', 'Install-ModuleFromFolder',
               'Invoke-ModuleFunction', 'Set-ModuleVersion',
               'Uninstall-ModuleFromFolder', 'Add-ModuleManifestExport',
               'Test-Script', 'Invoke-CommandAs', 'Invoke-PwshAs', 'Invoke-RunAs',
               'Start-Impersonate', 'Stop-Impersonate', 'Test-UserPrivilegeAdmin'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'PSEdition_Core'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/o-o00o-o/PSEasy.Utility'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

