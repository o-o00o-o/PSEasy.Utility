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
        # remove console command characters and inflate embedded \n 's
        return $getErrorString.Replace('\n', "`r`n") -Replace '\[[0-9;]+m', ''
    }
}
