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

}
