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
        echo $exitcode
        Write-Host "The source directory $SourcePath cannot be found!" -BackgroundColor Red
        exit $exitcode 
    }
    else
    {
        Write-Host "The source directory $SourcePath was found!" -BackgroundColor Green
    }

    if ((Test-Path -Path ($SourcePath.TrimEnd("*","\") + "\*") -Include $SourceConfigFile -PathType Leaf) -eq $false) {
        $exitcode = $LASTEXITCODE
        echo $exitcode
        Write-Host "The source file $SourceConfigFile cannot be found!" -BackgroundColor Red
        exit $exitcode 
    }
    else
    {
        Write-Host "The source directory $SourceConfigFile was found!" -BackgroundColor Green
    }

    if ((Test-Path -Path ($SourcePath.TrimEnd("*","\") + "\*") -Include $TransformConfigFile -PathType Leaf) -eq $false) {
        $exitcode = $LASTEXITCODE
        echo $exitcode
        Write-Host "The source file $TransformConfigFile cannot be found!" -BackgroundColor Red
        exit $exitcode 
    }
    else
    {
        Write-Host "The source directory $TransformConfigFile was found!" -BackgroundColor Green
    }

}

function FindCTTFile () {
    if ((Test-Path -Path .\tools -Include "ctt.exe" -PathType Leaf) -eq $false) {
        $exitcode = $LASTEXITCODE
        echo $exitcode
        Write-Host "The Config Transformation Tool ctt.exe was not found!" -BackgroundColor Red
        exit $exitcode 
    }
    return $cttFileInfo = Get-ChildItem -Path . -Recurse -Include "ctt.exe"
}


Write-Host "Validating Parameters"
ValidateParameters
Write-Host "Parameters are valid"

Write-Host "Locating the Config Transform Tool (CTT.EXE)"
$cttFile = FindCTTFile
Write-Host "Tool found!"



try {
    Write-Host "Beginning Transformation"
    $destinationFile = [System.IO.Path]::Combine($SourcePath,"transformed.config")
    Start-Process -FilePath $cttFile.FullName -ArgumentList (s:$SourceConfigFile t:$TransformConfigFile d:$destinationFile) -Wait
    [System.IO.File]::Replace($destinationFile,$SourceConfigFile,"$SourceConfigFile + .bak")

    Write-Host "Transformation Complete."

}
catch [System.Exception] {
    $exitCode = $LASTEXITCODE
    exit $exitCode
}


Trace-VstsEnteringInvocation $MyInvocation