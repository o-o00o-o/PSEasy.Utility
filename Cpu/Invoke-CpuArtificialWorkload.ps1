function Invoke-CpuArtificialWorkload {
    [CmdletBinding(PositionalBinding = $true, SupportsShouldProcess = $true )]
    <#
.SYNOPSIS
    This creates an artificial workload to test a system under load

.DESCRIPTION
    Useful for putting a load onto a system to see if performance/exceptions happens
    e.g. race conditions

.NOTES
    Originally borrowed from https://www.robvit.com/windows_server/generate-cpu-load-with-powershell/

#>
    Param(
        [Parameter()]
        [int]
        # multiplies the number of threads per Logical Processor (beware things will get really slow!)
        $ThreadsPerLogicalProcessor = 1
    )
    $NumberOfLogicalProcessors = Get-CimInstance win32_processor | Select-Object -ExpandProperty NumberOfLogicalProcessors

    foreach ($core in 1..($NumberOfLogicalProcessors * $ThreadsPerLogicalProcessor)) {
        start-job -ScriptBlock {

            $result = 1;
            foreach ($loopnumber in 1..2147483647) {
                $result = 1;

                foreach ($loopnumber1 in 1..2147483647) {
                    $result = 1;

                    foreach ($number in 1..2147483647) {
                        $result = $result * $number
                    }
                }
                $result
            }
        }
    }

    Read-Host "Press any key to exit..."
    Stop-Job *
}
