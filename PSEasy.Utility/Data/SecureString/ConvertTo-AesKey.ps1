<#
.SYNOPSIS
Converts a secure string to a 32bit AES Key for use with ConvertFrom/To-SecureString

.PARAMETER StringPassword
The secure string password to convert to the key

.EXAMPLE
$ApplicationKey = ConvertTo-AesKey (Get-SecureString)
#>
function ConvertTo-AesKey {
  param (
      [SecureString]$StringPassword
  )
  $InsecureString = ($StringPassword | ConvertFrom-SecureString -AsPlainText)
  # pad to 32 chars with 0
  $InsecureString = "$InsecureString$([string]::new("0",32 - $InsecureString.Length))"
  $encoder = new-object System.Text.UTF8Encoding
  Write-Output $encoder.GetBytes($InsecureString)
}
