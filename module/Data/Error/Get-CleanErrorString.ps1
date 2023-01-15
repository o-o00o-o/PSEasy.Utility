function Get-CleanErrorString {
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        if ($InputObject) {
            $getErrorString = $InputObject | Get-Error | Out-String
        } else {
            $getErrorString = Get-Error | Out-String
        }
        # string green text start and end and inflate embedded \n 's
        return $getErrorString.Replace('[92m', '').Replace('[0m', '').Replace('\n', "`r`n")
    }
}
