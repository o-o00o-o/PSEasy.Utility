<#<#
.SYNOPSIS
Gets a Hash from a string (rather than a file)

.EXAMPLE

.NOTES

.LINK
Get-FileHash

#>#>
function Get-Hash {
    param(
        [Parameter()]
        [string]$Text,

        [Parameter()]
        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
        [string]$Algorithm
    )
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($Text)
    $writer.Flush()
    $stringAsStream.Position = 0
    Write-Output (Get-FileHash -InputStream $stringAsStream -Algorithm $Algorithm).Hash
}
