param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found: $SourceDir"
    exit 1
}

# Find or install WiX candle.exe
$CandleExe = $null

# Check standard install locations
$StandardPaths = @(
    "C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe",
    "C:\Program Files (x86)\WiX Toolset v3.10\bin\candle.exe",
    "C:\Program Files (x86)\WiX Toolset\bin\candle.exe"
)
foreach ($p in $StandardPaths) {
    if (Test-Path $p) { $CandleExe = $p }
}

# Try chocolatey location
if (-not $CandleExe) {
    $chocoCandle = "C:\ProgramData\chocolatey\lib\wixtoolset\tools\bin\candle.exe"
    if (Test-Path $chocoCandle) { $CandleExe = $chocoCandle }
}

# Download WiX v3.11 portable if not found
if (-not $CandleExe) {
    Write-Host "Downloading WiX v3.11..."
    $wixDir = "$env:TEMP\wix311"
    $zipUrl = "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311.zip"
    $zipPath = "$env:TEMP\wix311.zip"
    New-Item -ItemType Directory -Force -Path $wixDir | Out-Null
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -TimeoutSec 120 -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $wixDir -Force
        $CandleExe = "$wixDir\bin\candle.exe"
        Write-Host "WiX downloaded to: $CandleExe"
    } catch {
        Write-Host "ERROR: Failed to download WiX: $_"
        exit 1
    }
}

if (-not (Test-Path $CandleExe)) {
    Write-Host "ERROR: candle.exe not found"
    exit 1
}
Write-Host "Using candle.exe: $CandleExe"
$env:PATH = "$(Split-Path $CandleExe);$env:PATH"

# List source files
$files = Get-ChildItem $SourceDir -Recurse -File
Write-Host "Found $($files.Count) files in $SourceDir"

# Build WiX XML
$fileRefs = ""
foreach ($f in $files) {
    $rel = $f.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    $fileRefs += "        <File Name='$($f.Name)' Source='$rel' />`n"
}

$xmlContent = "<?xml version=""1.0""?>`n" +
"<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">`n" +
"  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">`n" +
"    <Package InstallerVersion=""200"" Compressed=""yes"" />`n" +
"    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />`n" +
"    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">`n" +
"      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">`n" +
"$fileRefs" +
"      </Directory>`n" +
"    </Directory>`n" +
"  </Product>`n" +
"</Wix>"

$wxsPath = Join-Path $PWD "Product.wxs"
$xmlContent | Out-File -FilePath $wxsPath -Encoding UTF8NoBOM
Write-Host "WXS written to: $wxsPath"

# Build MSI
Write-Host "Running candle..."
& $CandleExe -nologo -out "$OutputPath" $wxsPath
Write-Host "candle exit code: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: candle failed with code $LASTEXITCODE"
    exit 1
}
Write-Host "SUCCESS: MSI created at $OutputPath"
