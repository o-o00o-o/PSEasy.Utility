BeforeAll {
    $TestPSPath = $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    Write-Information $TestPSPath -InformationAction Continue

    if (-not ([appdomain]::currentdomain.GetAssemblies() | where-object { $_.ManifestModule -like "*Vega?VegaDW?library?classes?PropertyName.ps1" })) {
        # add class if we are missing it
        . "$PSScriptRoot\classes\PropertyName.ps1"
    }
    Set-StrictMode -Version 2
}

Describe "library\ConvertTo-Array testinput1" {
    BeforeEach {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = "Script Analyzer doesn't deal with scope blocks well. Pester allows these variables to be used in other child scopes and we do use them, so the warning is incorrect")]
        # we reset this each test as unless in readonly mode, this will be changed
        $testInput1 = @'
        {
            "Name": "TestObject1",
            "Fields": {
                "Field1":{
                    "DataType": "string"
                },
                "Field2":{
                    "DataType": "int"
                }
            }
        }
'@ | ConvertFrom-Json

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = "Script Analyzer doesn't deal with scope blocks well. Pester allows these variables to be used in other child scopes and we do use them, so the warning is incorrect")]
        $testInput2 = @'
        {
            "Name": "TestObject2",
            "Fields": {
                "Name":{
                    "DataType": "string"
                },
                "Age":{
                    "DataType": "int"
                }
            }
        }
'@ | ConvertFrom-Json

    }

    It "returns name,datatype array for testInput1.fields" {
        $expected = @(
            [PSCustomObject]@{
                DataType = "string"
                Name     = [PropertyName]("Field1")
            },
            [PSCustomObject]@{
                DataType = "int"
                Name     = [PropertyName]("Field2")
            }
        )
        $actual = (& $TestPSPath -InputObject $testInput1.fields)
        try {
            @($actual), @($expected) | Test-Equality | Should -BeTrue
        } catch {
            Write-Information "Expected`n`r$($expected | ConvertTo-Json)" -InformationAction Continue
            Write-Information "Actual`n`r$($actual | ConvertTo-Json)" -InformationAction Continue
            throw
        }
    }

    It "returns name,datatype array for testInput2.fields" {
        $expected = @(
            [PSCustomObject]@{
                DataType = "string"
                Name     = [PropertyName]("Name")
            },
            [PSCustomObject]@{
                DataType = "int"
                Name     = [PropertyName]("Age")
            }
        )
        $actual = (& $TestPSPath -InputObject $testInput2.fields)
        try {
            @($actual), @($expected) | Test-Equality | Should -BeTrue
        } catch {
            Write-Information "Expected`n`r$($expected | ConvertTo-Json)" -InformationAction Continue
            Write-Information "Actual`n`r$($actual | ConvertTo-Json)" -InformationAction Continue
            throw
        }
    }

    It "returns exception for testInput1 with default Name PropertyName" {
        { (& $TestPSPath -InputObject $testInput2) } | Should -Throw 'We already have a property in the property Fields called Name, please indicate a different PropertyName with the AddPropertyNameAs parameter'
    }

    It "returns Custom Name for the top level" {
        $expected = @(
            [PSCustomObject]@{
                Value   = "TestObject2"
                Section = [PropertyName]("Name")
            },
            [PSCustomObject]@{
                Name    = [PSCustomObject]@{DataType = "string" }
                Age     = [PSCustomObject]@{DataType = "int" }
                Section = [PropertyName]("Fields")
            }
        )
        $actual = (& $TestPSPath -InputObject $testInput2 -AddPropertyNameAs 'Section')
        try {
            @($actual), @($expected) | Test-Equality | Should -BeTrue
        } catch {
            Write-Information "Expected`n`r$($expected | ConvertTo-Json)" -InformationAction Continue
            Write-Information "Actual`n`r$($actual | ConvertTo-Json)" -InformationAction Continue
            throw
        }
    }
    It "Ignores already added Custom Names" {
        $expected = @(
            [PSCustomObject]@{
                Value   = "TestObject1"
                Section = [PropertyName]("Name")
            },
            [PSCustomObject]@{
                Field1  = [PSCustomObject]@{DataType = "string" }
                Field2  = [PSCustomObject]@{DataType = "int" }
                Section = [PropertyName]("Fields")
            }
        )
        $actual = (& $TestPSPath -InputObject $testInput1 -AddPropertyNameAs 'Section')
        $actual = (& $TestPSPath -InputObject $testInput1 -AddPropertyNameAs 'Section') # call twice
        try {
            @($actual), @($expected) | Test-Equality | Should -BeTrue
        } catch {
            Write-Information "Expected`n`r$($expected | ConvertTo-Json)" -InformationAction Continue
            Write-Information "Actual`n`r$($actual | ConvertTo-Json)" -InformationAction Continue
            throw
        }
    }

}
