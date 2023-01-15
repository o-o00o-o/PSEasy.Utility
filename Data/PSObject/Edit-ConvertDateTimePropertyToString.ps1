<#<#
.SYNOPSIS
Updates all properties with Datetime to string

.DESCRIPTION
Useful before calling ConvertTo-Json as otherwise you get useless (/Date(3242343242) type expressions that are not human readable)

.PARAMETER InputObject
PSCustomObject with date properties

.EXAMPLE

[PSCustomObject]@{Now = [DateTime]::Now} | ConvertTo-Json
returns
{
    "Now":  "\/Date(1621357679896)\/"
}

[PSCustomObject]@{Now = [DateTime]::Now} | Edit-ConvertDateTimePropertyToString | ConvertTo-Json
returns
{
    "Now":  "2021-05-18T18:12:29.4340724+01:00"
}

[PSCustomObject]@{Now = [DateTime]::Now},[PSCustomObject]@{Now = [DateTime]::Now} | Edit-ConvertDateTimePropertyToString | ConvertTo-Json


#>
function Edit-ConvertDateTimePropertyToString {
  param(
    [Parameter(Position=1,ValueFromPipeline)]
    [PSCustomObject]
    $InputObject
  )
  process {
    foreach ($property in $InputObject.PSObject.Properties) {
      if($property.Value -is [DateTime] -or $property.Value -is [DateTimeOffset]) {
        $property.Value = $property.Value.ToString("o")
      }
    }
    Write-Output $InputObject
  }
}
