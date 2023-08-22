# PSEasy.Utility

A bunch of basic Powershell utility functions that should be in Powershell directly (useful for most people) Includes the following highlights

- Powershell Module development helpers
- PSObject helpers
    - ConvertTo-Array (also available as .ToArray2() function on all PSCustomObjects) to easily loop through properties
    - ConvertTo-FlatObject for easy comparison
    - ObjectModel functions to work with nested PSCustomObjects efficiently
    - Hashtable functions
- PerformanceRecord for performance tracing
- Logging for simple capturing output to a file
- File Helpers
    - Find-Item - easily find a parent folder with certain characteristics
    - Rename-FileWithRegex - rename with regex replace
    - File Locking helpers - test file lock and find process that locked it
- Environment Variable helpers
- Credential and Hash key helpers
- File content testing (useful for git precommit hooks)
- Compression function that will replicate folder structure
- Xml formatter

## How to get the module

``` powershell
Install-Module PSEasy.Utility
```

## How to create and test a new module

- Create a "..Build-Module.config.json" file in the module root e.g.

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

    - Manifest properties are static values that will be put into the psd1 file as is
    - File properties are to determine the files to include/exclude and how to decide those files to export

- Put your functions into a folder structure \<MyModule>\\\<MyFunctions>
    - Files or folders with private or public in the name will always be private or public. You can indicate a default when building to deal with the others
    - No scripts, all files should contain functions

- Validate and Build the psd1/psm1 files by running ```Build-Module```

    ``` powershell
    Build-Module .\module\PSEasy.Utility\
    ```

    - Import switch to import directly into the current session (note that any scripts with #requires for this module will reload the installed version - so useful for local testing only)
    - Load switch ensures that it can be loaded into a new session correctly

- Locally install the module

    ``` powershell
    Install-ModuleFromFolder .\module\PSEasy.Utility\
    ```

    > Note this doesn't increment the version and will just overwrite the existing version. Useful for testing without generating loads of version numbers

- Now publish it
    - You can use either the standard ```Publish-Module``` to publish to Powershell Gallery or see PSEasy.Module for publishing to ADO artifact feed
    - If you use ```Publish-Module``` then you can use the ```Set-ModuleVersion``` to increment the version in all the places necessary

    e.g.

    ``` powershell
    Set-ModuleVersion -modulepath '.\module\PSEasy.Module\' -VersionIncrementType Patch
    Publish-Module -path '.\module\PSEasy.Module\' -Verbose -NuGetApiKey 'Your key here' -whatif
    # then run without whatif if no errors
    ```

## Notes for working on this library

Of course there is a bit of a chicken and egg problem using Build-Module for this module if you are changing the code in Build-Module

To workaround that use

``` powershell
. src\module\Lifecycle\Import-ModuleFunction
```
