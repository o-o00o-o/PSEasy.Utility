<#
.SYNOPSIS
Adds a table-valued parameter to a SQL command

.DESCRIPTION
Adds a table-valued parameter (TVP) to a SQL command. The parameter must be a DataTable.

.EXAMPLE
splat = @{
    ParameterName = "@MyTvp"
    TypeName = "dbo.MyTvpType"
    Value = (Get-Process | Select @{Name="Id"; Expression={$_.Id}}, @{Name="Name"; Expression={$_.Name}} | Out-DataTable)
}
$command | Add-SqlParameterTvp @splat

#>
function Add-SqlParameterTvp {
    [CmdletBinding()]
    param(
        # The SQL command to add the parameter to
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Data.SqlClient.SqlCommand]
        $Command,

        # The parameter name (should start with @)
        [Parameter(Mandatory)]
        [string]
        $ParameterName,

        # The SQL type name for the TVP (including schema)
        [Parameter(Mandatory)]
        [string]
        $TypeName,

        # The DataTable value to pass as the TVP
        [Parameter(Mandatory)]
        [System.Data.DataTable]
        $Value
    )

    process {
        $param = [System.Data.SqlClient.SqlParameter]::new()
        $param.ParameterName = $ParameterName
        $param.TypeName = $TypeName
        $param.SqlDbType = [System.Data.SqlDbType]::Structured
        $param.Direction = [System.Data.ParameterDirection]::Input

        if ($null -eq $Value -or $Value.Rows.Count -eq 0) {
            Write-Verbose "No rows in TVP $ParameterName, setting value to empty DataTable"
            $param.Value = [System.Data.DataTable]::new()
        }
        else {
            $param.Value = $Value
        }

        $null = $Command.Parameters.Add($param)
    }
}
