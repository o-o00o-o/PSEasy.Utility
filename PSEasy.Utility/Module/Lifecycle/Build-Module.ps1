<#
.SYNOPSIS
Generic method to build an efficient DRY powershell module

.DESCRIPTION
Powershell Modules are hard work. There is a lot of double work going on where there doesn't need to be between the psd1 and the psm1 file

Each module is required to have a ".Build-Module.config.json" file in the root of the module folder.

    ``` json
    {
        "Manifest": {
            "Guid": "731e2d99-2143-4aaa-b0bb-4648124addfd",
            "Author": "Brett Gerhardi",
            "Description": "Build, Push and Get Powershell Modules",
            "RequiredModules": [
                "PSEasy.Utility"
            ]
        },
        "File": {
            "FileSpec": "*-*.ps1",
            "ExcludeSpec": [
                "*.Tests.ps1",
                "Import-ModuleFunction.ps1"
            ],
            /* "PublicOnlyIfIndicated" or "'PublicByDefault" */
            "ExportMode": "PublicByDefault"
        }
    }
    ```
It is also recommended to have a .version file with the current version number of the module (e.g. 1.0.0)

When this is run it will

- identify all the files indicated by the filespec and exclude spec and combine with the Manifest details to build the psm1 and psd1 file
- Test the scripts
    - Function filenames should match Function names
- Test the manifest is good
- Run PSScriptAnalyzer to ensure that this is good to publish
- Optionally Load the module into a new PS session to test errors and performance
- Optionally Import the module in the current session for testing

.PARAMETER Load
    Imports the module in a separate PowerShell session
    and measure how fast it imports. If the module cannot be imported it throws
    an error.

.PARAMETER Import
    Imports the newly built module into the current powershell session

.EXAMPLE

> Build-Module .\src\PSEasy.Module -load -import

.LINK
Install-ModuleFromFolder

#>
function Build-Module {
    param(
        [parameter(ValueFromPipeline)][ValidateNotNullOrEmpty()][string[]]$ModulePath = $pwd,
        [parameter()][switch] $Load,
        # [parameter()][switch] $Clean,
        [parameter()][switch] $Import
        # [Parameter(Mandatory)][ValidateSet('Major', 'Minor', 'Patch', 'None')][string]$VersionIncrementType,
        #[parameter()][string] $PublishToFeed too difficult until we have nuget in the path
    )

    begin {
        Set-StrictMode -Version 2
        $ErrorActionPreference = "Stop"
    }

    process {
        # $outputPath = Join-Path $ModulePath 'bin'
        foreach ($_modulePath in $ModulePath) {
            $moduleDirectory = Get-Item $_modulePath
            $moduleName = Split-Path $_modulePath -Leaf
            $psdFile = "$moduleName.psd1"
            $psmFile = "$moduleName.psm1"
            #$psbFile = "$moduleName.build.ps1"
            $configFilename = '.Build-Module.config.json'
            $configPath = Join-Path $moduleDirectory $configFilename
            if (-not (Test-Path $configPath)) {
                throw "Please provide a file named $configFilename"
            }

            # get this modules config
            $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

            # get the moduleManifest static values as a hashtable so we can build the splat
            $ModuleManifestArgs = $config.Manifest | ConvertTo-Json | ConvertFrom-Json -AsHashtable

            # identify the files according to the config instruction
            $files =
            Get-ChildItem $ModulePath -filter $config.File.FileSpec -File -Recurse -Exclude ($config.File.ExcludeSpec)

            # test files and establish public files
            $files |
            Test-Script -PassThru |
            Add-ModuleManifestExport -ExportMode $config.File.ExportMode -ModuleManifestArgs $ModuleManifestArgs

            # add values that we own
            $moduleManifestPath = "$_modulePath\$psdFile"
            Set-HashTableItem -ht $ModuleManifestArgs -k 'Path' -v $moduleManifestPath
            Set-HashTableItem -ht $ModuleManifestArgs -k 'RootModule' -v $psmFile
            Set-HashTableItem -ht $ModuleManifestArgs -k 'ModuleVersion' -v (Get-ModuleVersion -ModulePath $_modulePath)
            # these we will leave as they are if they have been set by the build script
            Set-HashTableItem -ht $ModuleManifestArgs -k 'FunctionsToExport' -v @() -safe
            Set-HashTableItem -ht $ModuleManifestArgs -k 'AliasesToExport' -v @() -safe
            Set-HashTableItem -ht $ModuleManifestArgs -k 'CmdletsToExport' -v @() -safe

            # Create manifest
            $ModuleManifestArgs.GetEnumerator() | Format-Table | Out-String | Write-Debug
            New-ModuleManifest @ModuleManifestArgs

            # fix the file so it doesn't have trailing whitespace (creates warnings wth ScriptAnalyzer below)
            (Get-Content -Path $moduleManifestPath | ForEach-Object {$_.TrimEnd()}) | Set-Content -Path $moduleManifestPath

            # build psm1 file with super-fast . notation, makes importing fastest
            $sb = [System.Text.StringBuilder]::new()
            $null = $sb.AppendLine('# Automatically generated from Build-Module')
            $null = $sb.AppendLine('# =========================================')
            foreach ($f in $files) {
                $null = $sb.AppendLine(@"
. "`$PSScriptRoot\$([System.IO.Path]::GetRelativePath($moduleDirectory.FullName, $f.FullName))"
"@
                )
            }
            $sb.ToString() | Set-Content "$_modulePath\$psmFile" -Encoding UTF8 -force

            $null = Test-ModuleManifest -Path $moduleManifestPath

            $analyzerResults = Invoke-ScriptAnalyzer -Path $_modulePath -Recurse
            if ($analyzerResults) {
                Write-Host 'Script Analyzer issues'
                $analyzerResults | Select-Object ScriptName, Line, Message, RuleName, Severity | Format-Table | Out-String | Write-Host
            } else {
                Write-Host 'No script Analyzer issues found'
            }

            # load test
            if ($Load) {
                $powershell = Get-Process -Id $PID | Select-Object -ExpandProperty Path
                & $powershell -noProfile -c "'Load: ' + [decimal]::Round((Measure-Command { Import-Module '$_modulePath' -ErrorAction Stop}).TotalMilliseconds, 0) + 'ms'"
                if (0 -ne $LastExitCode) {
                    throw "load failed!"
                }
            }

            # import into our session
            if ($Import) { Import-Module "$ModulePath\" -Force -Verbose -Global}

        }
    }
    end {

    }
}
