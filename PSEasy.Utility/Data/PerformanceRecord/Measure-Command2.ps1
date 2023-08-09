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
General notes
#>#>
function Measure-Command2 {
    param(
        [Parameter(Position = 1)][ScriptBlock]$Expression,
        [Parameter()][System.Collections.Generic.Dictionary[String, PSCustomObject]] $PerformanceStore,
        [Parameter()][bool]$RecordPerformance,
        [Parameter()][string]$Stage = $null,
        [Parameter()][string]$Entity = $null,
        [Parameter()][ValidateSet('Host', 'Verbose', '')][string]$WriteTo
    )
    $performanceParams = @{
        PerformanceStore  = $PerformanceStore
        RecordPerformance = $RecordPerformance
        Stage = $Stage
        Entity = $Entity
    }
    Add-PerformanceRecord @performanceParams -WriteTo $WriteTo
    Write-Output ($Expression.InvokeReturnAsIs())
    Complete-PerformanceRecord @performanceParams
}
