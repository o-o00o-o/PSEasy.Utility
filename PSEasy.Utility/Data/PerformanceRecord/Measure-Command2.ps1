<#<#
.SYNOPSIS
Improves the original Measure-Command by adding the ability to store the performance
into a performance store

.DESCRIPTION

.EXAMPLE

    $performance = Get-PerformanceStore
    $performanceParams = @{
        PerformanceStore  = $performance
        RecordPerformance = $true
    }
    Measure-Command2 {
        Add-Templates -Model $Model -TemplateConfigFile $useTemplateConfigFile -TemplateFolder $useTemplateFolder } @performanceParams -Stage 'Add-Templates'

    # show the performance by stage and Entity
    Get-PerformanceRecord -By Stage -PerformanceStore $Model.performance
    Get-PerformanceRecord -By Entity -PerformanceStore $Model.performance

.NOTES
A consequence of using this is that it will complicate your stack traces on output
which is often a good reason not to use it in scripts

Really need to find a way to solve that but not sure how to post an error without it
coming from this

#>#>
function Measure-Command2 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 1)][ScriptBlock]$Expression,
        [Parameter(Mandatory)][System.Collections.Generic.Dictionary[String, PSCustomObject]] $PerformanceStore,
        [Parameter()][bool]$RecordPerformance = $true,
        [Parameter()][string]$Stage = $null,
        [Parameter()][string]$Entity = $null,
        [Parameter()][ValidateSet('Host', 'Verbose', '')][string]$WriteTo
    )
    $performanceParams = @{
        PerformanceStore  = $PerformanceStore
        RecordPerformance = $RecordPerformance
    }

    if ($Stage) { $performanceParams.Stage = $Stage }
    if ($Entity) { $performanceParams.Entity = $Entity }

    $null = Add-PerformanceRecord @performanceParams -WriteTo $WriteTo
    try {
        Write-Output ($Expression.InvokeReturnAsIs())
    }
    catch {
        # would love to suppress this function from the stack trace so that we are invisible and directly point to the real exception
        $PSCmdlet.WriteError( [Management.Automation.ErrorRecord]::new($_.Exception.InnerException, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject ))
    }
    Complete-PerformanceRecord @performanceParams
}
