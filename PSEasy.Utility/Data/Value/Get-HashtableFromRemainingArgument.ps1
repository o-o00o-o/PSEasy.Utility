<#
.SYNOPSIS
Converts a "ValueFromRemainingArguments" into a hashtable

.PARAMETER Value
Parameter description

.EXAMPLE
Get-HashtableFromRemainingArguments -simplepar value1 -arraypar value2,value3 -switchpar

Name                           Value
----                           -----
switchpar                      True
arraypar                       value2 value3
simplepar                      value1

.NOTES
see https://stackoverflow.com/questions/27764394/get-valuefromremainingarguments-as-an-hashtable

#>
function Get-HashtableFromRemainingArgument {
    param(
        [Parameter(ValueFromRemainingArguments)][string[]]$Value
    )

    #Convert vars to hashtable
    $htvars = @{}
    $Value | ForEach-Object {
        if ($_ -match '^-') {
            #New parameter
            $lastvar = $_ -replace '^-'
            $htvars[$lastvar] = $true
        }
        else {
            #Value
            $htvars[$lastvar] = $_
        }
    }

    #Return hashtable
    Write-Output $htvars
}
