<#
.SYNOPSIS
Imports all functions for a module for the situation that you don't yet
have the providers and credential managers setup yet to install the module normally

.NOTES

We should reduce the frequency of this problem by publishing this to the ubiquitous Powershell Gallery


.EXAMPLE

Chicken and Egg problem - at the beginning we don't have Build-Module so

> Build-Module .\src\PSEasy.Module\

returns error

Build-module: The term 'Build-module' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

so we can run with the bootstrap option that simply gets all ps1 files into the current session

> . .\src\PSEasy.Module\Module\Import-ModuleFunction.ps1
> Build-Module .\src\PSEasy.Module\

Now it succeeds and you can now import and cycle normally using the module itself

> Import-Module .\src\PSEasy.Module\ -Verbose -force -PassThru
> Build-Module .\src\PSEasy.Module\

#>

param(
    # this is the path of the module itself, pass this if you aren't bootstrapping for PSEasy.Module itself
    [string]$ModulePath = "$PSScriptRoot\..\.."
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -version 2
$config = Get-Content -Path (Join-Path $ModulePath '.Build-Module.config.json') -Raw | ConvertFrom-Json

$Files = Get-ChildItem $ModulePath -filter $config.File.FileSpec -File -Recurse -Exclude ($config.File.ExcludeSpec)

$Files | ForEach-Object {
    # skip me to prevent infinite loop
    if ($PSCommandPath -ne $_.FullName) {
        Write-Host "Importing $($_.FullName)"
        . $_
    }
} # get all functions into this session so they can be used
