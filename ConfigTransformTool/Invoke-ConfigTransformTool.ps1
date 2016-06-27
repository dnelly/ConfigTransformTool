[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    # Parameter help description
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $SourceConfigFile,
    # Parameter help description
    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $TransformConfigFile,
    # Parameter help description
    [Parameter(Mandatory = $true, Position = 2)]
    [string]
    $SourcePath

)

Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

function ValidateParameters () {
    Write-Host "Validating parameters"
    if ((Test-Path -Path $SourcePath) -eq $false) {
        $exitcode = $LASTEXITCODE
        Write-Host $exitcode
        Write-Host "The source directory $SourcePath cannot be found!" -ForegroundColor Red
        throw [System.IO.FileNotFoundException] "The source directory $SourcePath cannot be found!"
        exit $exitcode 
    }
    else
    {
        Write-Host "The source directory $SourcePath was found!" -BackgroundColor Green
        Get-ChildItem -Path $SourcePath -Recurse | ForEach-Object {Write-Host $_.FullName -ForegroundColor Green}
    }

    if ((Test-Path -Path ($SourcePath.TrimEnd("*","\") + "\*") -Include $SourceConfigFile -PathType Leaf) -eq $false) {
        $exitcode = $LASTEXITCODE
        Write-Host $exitcode
        Write-Host "The source file $SourceConfigFile cannot be found!" -ForegroundColor Red
        throw [System.IO.FileNotFoundException] "The source file $SourceConfigFile cannot be found!"
        exit $exitcode 
    }
    else
    {
        Write-Host "The source directory $SourceConfigFile was found!" -ForegroundColor Green
    }

    if ((Test-Path -Path ($SourcePath.TrimEnd("*","\") + "\*") -Include $TransformConfigFile -PathType Leaf) -eq $false) {
        $exitcode = $LASTEXITCODE
        Write-Host $exitcode
        Write-Host "The source file $TransformConfigFile cannot be found!" -ForegroundColor Red
        throw [System.IO.FileNotFoundException] "The source file $TransformConfigFile cannot be found!"
        exit $exitcode 
    }
    else
    {
        Write-Host "The source directory $TransformConfigFile was found!" -ForegroundColor Green
        
    }

    Write-Host "Parameters are valid"

}

function FindCTTFile () {
    if ((Test-Path -Path .\tools\* -Include "ctt.exe" -PathType Leaf) -eq $false) {
        $exitcode = $LASTEXITCODE
        Write-Host $exitcode
        Write-Host "The Config Transformation Tool ctt.exe was not found!" -ForegroundColor Red
        throw [System.IO.FileNotFoundException] "The Config Transformation Tool ctt.exe was not found!"
        exit $exitcode 
    }
    return $cttFileInfo = Get-ChildItem -Path . -Recurse -Include "ctt.exe"
}


ValidateParameters


Write-Host "Locating the Config Transform Tool (CTT.EXE)"
$cttFile = FindCTTFile
Write-Host "Tool found!"



try {
    Write-Host "Beginning Transformation"
    $destinationFile = [System.IO.Path]::Combine($SourcePath,"transformed.config")
    $sourcefile = [System.IO.Path]::Combine($SourcePath,$SourceConfigFile)
    $targetFile = [System.IO.Path]::Combine($SourcePath,$TransformConfigFile)
    #Start-Process -FilePath $cttFile.FullName -ArgumentList ("s:$sourcefile","t:$targetFile","d:$destinationFile","pw", "i", "v") -PassThru -NoNewWindow -Wait -Verbose
    $results = Invoke-Expression "$cttFile s:$sourcefile t:$targetFile d:$destinationFile pw i v" -ev ex
    $results
    if ($ex.Count -gt 0) {
        Write-Host "Error occurred"
        Write-Error -Message "$ex"
    }

    [System.IO.File]::Replace($destinationFile,$sourcefile,"$sourcefile.bak")
    
    Write-Host "Refreshing the directory."
    ([System.IO.DirectoryInfo]$SourcePath).Refresh()
    Write-Host "Transformation Complete."

}
catch [System.Exception] {
    Write-Error -Message "An Error occurred" -Exception $_.Exception
}


#Trace-VstsEnteringInvocation $MyInvocation