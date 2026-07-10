param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found: $SourceDir"
    exit 1
}

# Find candle.exe in common WiX install locations
$CandleExe = $null
$SearchPaths = @(
    "C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe",
    "C:\Program Files (x86)\WiX Toolset v3.10\bin\candle.exe",
    "C:\Program Files (x86)\WiX Toolset\bin\candle.exe",
    "C:\ProgramData\chocolatey\lib\wixtoolset\tools\bin\candle.exe",
    "C:\ProgramData\chocolatey\lib\wix\tools\bin\candle.exe",
    "C:\ProgramData\chocolatey\bin\candle.exe"
)
foreach ($path in $SearchPaths) {
    if (Test-Path $path) {
        $CandleExe = $path
        break
    }
}

# Search broader chocolatey directory
if (-not $CandleExe) {
    $chocoPaths = Get-ChildItem "C:\ProgramData\chocolatey\lib" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "candle.exe" } | ForEach-Object { $_.FullName }
    }
    if ($chocoPaths) {
        $CandleExe = $chocoPaths[0]
    }
}

if (-not $CandleExe) {
    Write-Host "ERROR: candle.exe not found in any known location"
    Write-Host "Searched: $($SearchPaths -join ', ')"
    exit 1
}
$WIX = Split-Path $CandleExe
Write-Host "Found WiX at: $WIX"
$env:PATH = "$WIX;$env:PATH"

$files = Get-ChildItem $SourceDir -Recurse -File
$fileRefs = ($files | ForEach-Object {
    $rel = $_.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    "        <File Name='$($_.Name)' Source='$rel' />"
}) -join "`n"

$xmlContent = "<?xml version=""1.0""?>" + "`n" +
"<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">" + "`n" +
"  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">" + "`n" +
"    <Package InstallerVersion=""200"" Compressed=""yes"" />" + "`n" +
"    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />" + "`n" +
"    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">" + "`n" +
"      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">" + "`n" +
"$fileRefs" + "`n" +
"      </Directory>" + "`n" +
"    </Directory>" + "`n" +
"  </Product>" + "`n" +
"</Wix>"

$xmlContent | Out-File -FilePath "Product.wxs" -Encoding UTF8
Write-Host "Building MSI..."
candle -nologo -out "$OutputPath" "Product.wxs"
Write-Host "MSI exit code: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "MSI created: $OutputPath"
