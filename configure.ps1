# The script assumes the file exits in .idris2/bin
# To run this script
# Powershell.exe -ExecutionPolicy Bypass -File this.ps1


$idrisVersion = "0.4.0"

# The script assumes sha256sum exists in $hashBin
$hashBinPath = "C:\msys64\usr\bin"

$scriptDirPath = $PSScriptRoot
$archiveRoot = (get-item $scriptDirPath).parent.parent.FullName
$idrisPrefix = $archiveRoot + "\.idris2"
$idrisBinPath = $idrisPrefix + "\bin"
$idrisLibPath = $idrisPrefix + "\lib"
# $idrisData is not used at thismoment
#$idrisData = $idrisPrefix + "/idris2-" + $idrisVersion
$schemePath  = $archiveRoot + "\chez\bin\ta6nt"

# Create script contents. I with we have here document.
function Idris2-Cmd-String{
    param(
	$appName
    )
    $idrisAppPath = $idrisBinPath + "\" + $appName + "_app\"
    $CMD = @"
set PWSHCMD=`"$idrisBinPath\$appName.ps1`"
powershell -ExecutionPolicy Bypass -File `%PWSHCMD`%
"@
    Write-Output $CMD
}

function Idris2-PS1-String {
    param(
	$appName
    )
    $idrisAppPath = "$idrisBinPath\$appName" + "_app"
    $CMD = @"
`$env:Path += `";$schemePath`"
`$env:Path += `";$hashBinPath`"
`$env:Path += `";$idrisAppPath`"

`$env:IDRIS2_PREFIX = `"$idrisPrefix`"
`$env:IDRIS2_LIB = `"$idrisLibPath`"
`&`"$schemePath/scheme.exe`" --program `"$idrisAppPath/$appName.so`" `$args
"@
    $configBuilder = [System.Text.StringBuilder]""
    [void]$configBuilder.AppendLine("@echo off")
    [void]$configBuilder.AppendLine("set PATH=$schemePath;%PATH%;" + $hashBin)
    [void]$configBuilder.AppendLine("set PATH=$idrisAppPath;%PATH%")
    [void]$configBuilder.AppendLine("set PATH=%PATH%;" + "C:\msys64\usr\bin")
    [void]$configBuilder.AppendLine("set IDRIS2_PREFIX=$idrisPrefix")
#    [void]$configBuilder.AppendLine("set IDRIS2_LIB=$idrisPrefix" + "\lib")
    [void]$configBuilder.AppendLine("`"$schemePath/scheme.exe`" --script $idrisAppPath" + "/" + $appName + ".so" +  " %*")
    Write-Output $CMD
}

function Idris2-OldCmd-String {
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
    [void]$configBuilder.AppendLine("`"$schemePath/scheme.exe`" --program $idrisAppPath" + "/" + $appName + ".so" +  " %*")
    Write-Output $configBuilder.ToString()
}

function Create-Idris2-Script {
    param(
	$Path,
	$Contents
    )
    Set-Content -Path $Path -Value $Contents
    Write-Host "The configuration was created in:$Path"
    Write-Host "$Contents"
    Write-Output $Path
}

Write-Host "We expect sha256sum or its replacement is in $hashBin"

# We consider _app is created by idris2 to store scheme object file.
$apps = Get-ChildItem -Path *_app | % {$_.ToString()} | % {Split-Path -Path $_ -Leaf} | %{$_.SubString(0, $_.Length -4)}

# apps contains base name without _app.
$apps | %{
  $cmd = Idris2-Cmd-String $_
  Create-Idris2-Script -Path "$idrisBinPath\$_.cmd" -Contents $cmd
  $ps1 = Idris2-PS1-String $_
  Create-Idris2-Script -Path "$idrisBinPath\$_.ps1" -Contents $ps1
  $oldCmd = Idris2-OldCmd-String $_
  Create-Idris2-Script -Path "$idrisBinPath\$_-.cmd" -Contents $oldCmd
}

