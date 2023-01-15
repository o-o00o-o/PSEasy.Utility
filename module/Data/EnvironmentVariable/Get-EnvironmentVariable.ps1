<#<#
.SYNOPSIS
Gets the value for an Environment Variable

.DESCRIPTION

.EXAMPLE
get-environmentvariable -name 'path' -Verbose
C:\Users\bgerhardi\AppData\Local\Microsoft\WindowsApps;C:\Users\bgerhardi\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\bgerhardi\AppData\Local\Programs\Azure Data Studio\bin;C:\Users\bgerhardi\.dotnet\tools;C:\Users\bgerhardi\AppData\Local\Microsoft\WindowsApps;C:\Users\bgerhardi\AppData\Local\Programs\Fiddler;C:\Users\bgerhardi\AppData\Roaming\npm
.NOTES
It seems that this clashes with a module-less function that exists on Azure Devops pipelines Microsoft Agents
with the following definition.

We will Clobber it with -AllowClobber but ours is backwardly compatible so it will use Machine target scope
if the parameter -Variable is used (or no named at all)

Name        : Get-EnvironmentVariable
CommandType : Function
Definition  : param($variable)

                  return [System.Environment]::GetEnvironmentVariable($variable, "Machine")

#>#>
function Get-EnvironmentVariable {
    [CmdletBinding(DefaultParameterSetName = 'AdoPipeline')]
    param(
        [Parameter(ParameterSetName = 'OurMode', Mandatory)][string]$Name,
        [Parameter(ParameterSetName = 'AdoPipeline', Position = 1, Mandatory)][string]$Variable,
        [Parameter()][System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::User
    )
    $MyInvocation.BoundParameters | Format-List | Out-String | Write-Debug
    if ($PSCmdlet.ParameterSetName -eq 'AdoPipeline' -and -not $MyInvocation.BoundParameters.ContainsKey('Target')) {
        Write-Verbose 'Detected Ado Pipeline mode, switching Target to be Machine scope environment variable'
        $Target = [System.EnvironmentVariableTarget]::Machine
    }

    if ($Variable) {
        $Name = $Variable
    }

    Write-Verbose "Getting Environment Variable $Name for $Target scope"

    Write-Output ([System.Environment]::GetEnvironmentVariable($Name, $Target))
}
