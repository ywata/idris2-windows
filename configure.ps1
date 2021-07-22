#
# Make sure that the configuration is placed in the root directory!
#

$configBuilder = [System.Text.StringBuilder]""

$idrisVersion = "0.4.0"

$rootPath = $pwd.Path
# PATH
$idrisPath = $rootPath + "\.idris2"
# IDRIS2_DATA
$idrisData = $idrisPath + "\idris2-" + $idrisVersion + "\support"
# IDRIS2_LIBS
$idrisLibs = $idrisPath + "\idris2-" + $idrisVersion + "\lib"
# IDRIS2_PREFIX
$idrisPrefix = $idrisPath
# IDRIS2_PATH
$idrisAppPath = $idrisPath + "\bin\idris2_app"

# Add these to PATH
$schemePath = $rootPath + "\chez\bin\ta6nt"
$idrisBinPath = $idrisPath + "\bin"

[void]$configBuilder.AppendLine("@echo off")
[void]$configBuilder.AppendLine("set PATH=$idrisAppPath;%PATH%")
[void]$configBuilder.AppendLine("set PATH=$schemePath;%PATH%")

[void]$configBuilder.AppendLine("rem set IDRIS2_PATH=$idrisPath")
[void]$configBuilder.AppendLine("set IDRIS2_PREFIX=$idrisPrefix")
[void]$configBuilder.AppendLine("rem set IDRIS2_LIBS=$idrisLibs")
[void]$configBuilder.AppendLine("rem set IDRIS2_DATA=$idrisData")
[void]$configBuilder.AppendLine("`"$schemePath/scheme.exe`" --program `"$($idrisAppPath + '\idris2.so')`" %*")

$outFile = $idrisBinPath + "\idris2.cmd"

Set-Content -Path $outFile -Value $configBuilder.ToString()
Write-Output "The configuration was created in:"
Write-Output $outFile
