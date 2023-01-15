function Test-ContentNoTab {
    param(
        $FilePath,
        $fileContent,
        $Exclude
    )

    # check for tabs
    $noTabFiles = @{ # perhaps we should switch this for whitelist rather than blacklist
        Exclude = $Exclude
    }

    if (Get-Item -Path $filePath @noTabFiles) {
        $fileContent |
        Select-String -Pattern '\t' |
        ForEach-Object {
            throw "Tab character(s) in $FilePath. Please change to 4 spaces. Line:$($_.LineNumber)"
        }
    }

}
