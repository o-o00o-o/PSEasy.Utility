function Get-ScriptNature {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)][System.IO.FileInfo[]]$File
    )

    begin {
        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"
    }

    process {
        foreach ($_file in $File) {
            $out = @{
                File       = $File
            }

            $contents = Get-Content $_file -raw
            $functionFromContentsRegex = 'function\s+(?<FunctionName>[a-zA-Z0-9-]+)\s*{'
            if ($contents -match $functionFromContentsRegex) {
                Set-HashTableItem -ht $out -k ScriptType -v 'function'
                Set-HashTableItem -ht $out -k ScriptFunctionName -v $matches.FunctionName

                $filenameRegex = '^(?<FunctionName>[a-zA-Z0-9-]+)(\.(?<Qualifier>[a-zA-Z]+))?\.ps1$'
                if ($_file.Name -notMatch $filenameRegex) {
                    throw "$($file.FullName) not in expected format $($filenameRegex)"
                }
                Set-HashTableItem -ht $out -k FilenameFunctionName -v $matches.FunctionName

                if ($matches.Contains('Qualifier')) {
                    $FilenameQualifier = $matches.Qualifier
                } else {
                    $FilenameQualifier = ''
                }
                Set-HashTableItem -ht $out -k FilenameQualifier -v $FilenameQualifier

                if (
                    $filenameQualifier -eq 'public' -or
                    $_file.FullName -like '*\public\*'
                ) {
                    $AccessibilityIndicator = 'public'
                } elseif (
                    $filenameQualifier -eq 'private' -or
                    $_file.FullName -like '*\private\*'
                ) {
                    $AccessibilityIndicator = 'private'
                } else {
                    $AccessibilityIndicator = 'none'
                }

                Set-HashTableItem -ht $out -k AccessibilityIndicator -v $AccessibilityIndicator
            } else {
                Write-Verbose "couldn't find a function name in $($file.FullName) using $($functionFromContentsRegex)"
                Set-HashTableItem -ht $out -k ScriptType -v 'Unknown'
            }

            Write-Output ([PSCustomObject]$out)
        }
    }


end {

}
}
