# The script assumes the file exits in .idris2/bin
# To run this script
# Powershell.exe -ExecutionPolicy Bypass -File this.ps1


$idrisVersion = "0.4.0"

# The script assumes sha256sum exists in $hashBin
$hashBin = "C:\msys64\usr\bin"

$scriptDirPath = $PSScriptRoot
$archiveRoot = (get-item $scriptDirPath).parent.parent.FullName
$idrisPrefix = $archiveRoot + "\.idris2"
$idrisBinPath = $idrisPrefix + "\bin"
# $idrisData is not used at thismoment
#$idrisData = $idrisPrefix + "/idris2-" + $idrisVersion
$schemePath  = $archiveRoot + "\chez\bin\ta6nt"

# Create script contents. I with we have here document.
function Idris2-Cmd-String {
    param(
	$appName
    )
    $idrisAppPath = $idrisBinPath + "\" + $appName + "_app\"

    $configBuilder = [System.Text.StringBuilder]""
    [void]$configBuilder.AppendLine("@echo off")
    [void]$configBuilder.AppendLine("set PATH=$schemePath;%PATH%;" + $hashBin)
    [void]$configBuilder.AppendLine("set PATH=$idrisAppPath;%PATH%")
    [void]$configBuilder.AppendLine("set PATH=%PATH%;" + "C:\msys64\usr\bin")
    [void]$configBuilder.AppendLine("set IDRIS2_PREFIX=$idrisPrefix")
#    [void]$configBuilder.AppendLine("set IDRIS2_LIB=$idrisPrefix" + "\lib")
    [void]$configBuilder.AppendLine("`"$schemePath/scheme.exe`" --script $idrisAppPath" + "/" + $appName + ".so" +  " %*")
    Write-Output $configBuilder.ToString()
}

function Create-Idris2-Cmd {
    param(
	$Path,
	$Contents
    )
    Set-Content -Path $Path -Value $Contents
    Write-Output "The configuration was created in:"
    Write-Output $path
}

Write-Host "We expect sha256sum or its replacement is in " $hashBin

# We consider _app is created by idris2 to store scheme object file.
$apps = Get-ChildItem -Path *_app | % {$_.ToString()} | % {Split-Path -Path $_ -Leaf} | %{$_.SubString(0, $_.Length -4)}

# apps contains base name without _app.
$apps | %{
  $cmd = Idris2-Cmd-String $_
  Create-Idris2-Cmd -Path ($idrisBinPath + "\" + $_ + ".cmd") -Contents $cmd
}

