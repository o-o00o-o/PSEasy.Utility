<#
.SYNOPSIS
Uses Regex to find and replace

.EXAMPLE

$splat = @{
    Folder = .\src\VegaDW.Database\Model\Source\PartnerPlatform.dbo.Partners\
    Regex = '(stash\.)([_a-zA-Z0-9]+)_(\.sql)'
    RegexReplace = '$1CLEANUP_$2$3'
}
.\script\Rename-File.ps1 @splat -whatif

.NOTES
If renaming case-only you need to use Rename-GitFileWithRegex as Git is case sensitive but windows isn't
#>
function Rename-FileWithRegex {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Folder,
        [switch]$Recurse,
        [string]$Find,
        [string]$Replace,
        # if provided will commit automatically to git
        [string]$GitMessage,
        [switch]$Directory
    )
    $files = @(Get-ChildItem $Folder -Recurse:($Recurse.IsPresent) -Directory:($Directory.IsPresent) | Where-Object { $_.Name -cMatch $Find })
    if ($files.Count -gt 0) {
        foreach ($file in $files) {
            $newName = $file.Name -cReplace $Find, $Replace
            Write-Verbose "renaming $($file.FullName) to $newName"
            Rename-Item -Path $file.FullName -NewName $newName -PassThru
        }
        if ($GitMessage -and $PSCmdlet.ShouldProcess("add and commit to git")) {
            # commit to git
            git add $Folder
            git commit -m $GitMessage
        }
    }
}
