<#
.SYNOPSIS
Use this to bulk rename files

.DESCRIPTION
Will combine the RegexPrefix, Find and RegexSuffix into a regex case-sensitive compare on the whole filename (including extension)

use with care.
 - Try on a small folder and don't recurse first to make sure it does what you expect.
 - Use -whatif and/or -nogit to see if it does what you expect

Initially this was designed to rename the systemService part of our stashes so it is in camelCase.
However GIT (in our windows configuration) doesn't cope with renames where only case is different

Designed specifically to cope with renaming files where only case is different.
This is tricky with GIT as it wont detect a difference if only case has changed,
so we rename through another change by adding !!! to the filename also

.EXAMPLE

--------------------------
1. Rename in a 2 stage process from Salesforce to salesforce and keep GIT consistent

$renameParams = @{
    Folder = '.\somePath\'
    Find = '([_.]|\b|^)Salesforce([_.])'
    Replace = '$1salesforce$2'
}
.\script\Rename-GitFile.ps1 @renameParams

--------------------------
2. Rename stash folders, files and contents of files

## Set the following variables and run the full example (can run individually if you like)
$folder = '.\somePath\'
$replacePairs = @(
    [PSCustomObject]@{Original = 'Mds'; Replace = 'mds'}
    [PSCustomObject]@{Original = 'Salesforce'; Replace = 'salesforce'}
    [PSCustomObject]@{Original = 'DwFtp'; Replace = 'dwFtp'}
)

foreach ($replacePair in $replacePairs)
{
    ## 2.1 rename folders
    $renameParams = @{
        Folder = "$folder\\Source"
        Find = "$($replacePair.Original)(\..*)"
        Replace = "$($replacePair.replace)`$1"
        Directory = $true
        CaseOnlyChange = $true
    }
    .\script\Rename-GitFile.ps1 @renameParams

    ## 2.2 rename files (everywhere)
    $renameParams = @{
        Folder = $folder
        Find = "(.+(?:\.|_))$($replacePair.Original)((?:\.|_).+)"
        Replace = "`$1$($replacePair.Replace)`$2"
        Recurse = $true
        CaseOnlyChange = $true
    }
    .\script\Rename-GitFile.ps1 @renameParams

    ## 2.3 rename contents of files
    foreach ($file in (Get-ChildItem $folder -include '*.sql','*.json' -recurse))
    {
        $pattern = "(\.|_|\[)$($replacePair.Original)(\.|_)"
        $contents = Get-Content $file -raw
        if ($contents -cMatch $pattern) {
            $contents -cReplace $pattern,"`$1$($replacePair.Replace)`$2" | Out-File $file -NoNewline
        }
    }
    git add $Folder
    git commit -m 'completed rename contents'
}
celestra # fix database project

--------------------------------

.NOTES

Remember you will need to run celestra in many cases to ensure that the auto files are built with correct casing

You will also be able to use vscodes find in files with similar regex to easily rename objects
#>
function Rename-GitFileWithRegex {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        <#Category#>'PSShouldProcess',<#CheckId#>'',
        Justification = 'called functions handle it'
    )]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # path to folder to rename
        [string]$Folder,
        # whether to recurse from folder through subfolders
        [switch]$Recurse,
        # case-sensitive Find string.
        [string]$Find,
        # replace string use $1/$2 etc to replace with brackets
        [string]$Replace,
        # use this switch if renaming directories
        [switch]$Directory
    )
    Set-StrictMode -version 2
    $ErrorActionPreference = 'Stop'

    try {
        $2stageRename = $true # if you don't want this just use Rename-Files

        # this will allow renaming a set of files case sensitively and it will work with git correctly
        # rename with a safe additional character so that it isn't only case that has changed
        $stage1Match = $Find
        $stage1Replace = '!!!$0'
        $stage2Match = "!!!$Find"
        $stage2Replace = $Replace

        $RenameParams = @{
            Folder     = $Folder
            Directory  = $Directory.IsPresent
            Recurse    = $Recurse.IsPresent
            Find       = $stage1Match
            Replace    = ($2stageRename ? $stage1Replace : $stage2Replace)
            GitMessage = 'rename stage 1 of 2'
        }
        Rename-FileWithRegex @RenameParams

        if ($2stageRename) {
            $RenameParams.Find = $stage2Match
            $RenameParams.Replace = $stage2Replace
            $RenameParams.GitMessage = 'rename stage 2 of 2'
            Rename-FileWithRegex @RenameParams
        }
    } catch {
        throw
    }
}
