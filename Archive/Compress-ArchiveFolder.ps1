# This allows creation of part of a folder structure that standard Compress-Archive doesn't do
function Compress-ArchiveFolder
{
  [CmdletBinding()]
  Param(
    [parameter()][string]$DestinationPath,
    [parameter()][string]$RelativePositionPath,
    [parameter(ValueFromPipeline)][psobject[]]$Files
  )
  begin {
    #build list of files to compress
    # $files = @(Get-ChildItem -Path .\procedimentos -Recurse | Where-Object -Property Name -EQ procedimentos.xlsx);
    # $files += @(Get-ChildItem -Path .\procedimentos -Recurse | Where-Object -Property Name -CLike procedimento_*_fs_*_d_*.xml);
    # $files += @(Get-ChildItem -Path .\procedimentos -Recurse | Where-Object -Property FullName -CLike *\documentos_*_fs_*_d_*);
    Set-StrictMode -version 2
    $filesFullPath = @()
   }

  process {
    # exclude directory entries and generate fullpath list
    foreach ($file in $files) {
      $filesFullPath += ($file | Get-ChildItem | Where-Object -Property Attributes -CContains Archive | ForEach-Object -Process {Write-Output -InputObject $_.FullName})
    }
  }

  end {
    try {
      #create zip file
      $zip = [System.IO.Compression.ZipFile]::Open($DestinationPath, [System.IO.Compression.ZipArchiveMode]::Create)
      Push-Location $RelativePositionPath

      #write entries with relative paths as names
      foreach ($fname in $filesFullPath) {
          $rname = $(Resolve-Path -Path $fname -Relative) -replace '\.\\',''
          Write-Verbose "adding to archive $rname "
          $zentry = $zip.CreateEntry($rname)
          $zentryWriter = New-Object -TypeName System.IO.BinaryWriter $zentry.Open()
          $zentryWriter.Write([System.IO.File]::ReadAllBytes($fname))
          $zentryWriter.Flush()
          $zentryWriter.Close()
      }
    }
    catch {
      Write-Error "$_`n$(' ' * 80)`n$($_.ScriptStackTrace)$(if ($_ | Get-Member | Where-Object {$_.Name -eq 'Exception'}) {"`n$(' ' * 80)`n" + $_.Exception.ToString()})"
    }
    finally {
      if (Get-Variable 'zentryWriter') {
        $zentryWriter.Dispose()
      }
      if (Get-Variable 'zip') {
        $zip.Dispose()
      }
      Pop-Location
    }
  }
}
