#Requires -Version 5.0
<#
.SYNOPSIS
    Tests to see if we have any passwords embedded in source code

.NOTES
Desperate need of some parameter sets

.EXAMPLE

#>
function Test-ContentNoPassword {
    Param(
        $RootPath = '.',
        $FileList,
        $FilePath,
        $FileContent,
        $Include,
        $Exclude
    )
    $ErrorActionPreference = 'Stop'
    $includeExclude = @{
        Include = $Include
        Exclude = $Exclude
    }
    function Test-NoPassword {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
            <#Category#>'PSReviewUnusedParameter',<#CheckId#>'FilePath',
            Justification = 'it is being used - false warning'
        )]
        param(
            $Contents,
            $FilePath
        )
        $Contents |
        Select-String -Pattern 'password=(?!"")' |
        ForEach-Object {
            throw "Possible Password in $($FilePath). Please remove before committing. Line:$($_.LineNumber)"
        }
    }

    if ($FileContent) {
        if (Get-Item -Path $FilePath @includeExclude) {
            Test-NoPassword -Contents $FileContent -FilePath $FilePath
        }
    } else {
        if ($FileList) {
            $files = Get-Item -Path $FileList
        } else {
            $files = Get-ChildItem $RootPath -Recurse @includeExclude
        }
        foreach ($file in $files) {
            Test-NoPassword -Contents ($file | Get-Content) -FilePath $file.FullName
        }
    }
}
