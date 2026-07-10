param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found: $SourceDir"
    exit 1
}

# Find or install WiX candle.exe
$CandleExe = $null
$WixDir = "$env:TEMP\wix311"
$ZipUrl = "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311.zip"
$ZipPath = "$env:TEMP\wix311.zip"

# Check if already downloaded
$SearchPaths = @(
    "C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe",
    "C:\Program Files (x86)\WiX Toolset v3.10\bin\candle.exe",
    "$WixDir\bin\candle.exe"
)
foreach ($path in $SearchPaths) {
    if (Test-Path $path) {
        $CandleExe = $path
        Write-Host "Found WiX at: $CandleExe"
        break
    }
}

# Download WiX v3.11 if not found
if (-not $CandleExe) {
    Write-Host "Downloading WiX v3.11..."
    New-Item -ItemType Directory -Force -Path $WixDir | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -TimeoutSec 60 -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $WixDir -Force
    $CandleExe = "$WixDir\bin\candle.exe"
    Write-Host "Downloaded WiX to: $CandleExe"
}

if (-not (Test-Path $CandleExe)) {
    Write-Host "ERROR: candle.exe not found at: $CandleExe"
    exit 1
}

$WIX = Split-Path $CandleExe
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
Write-Host "Building MSI with: $CandleExe"
& $CandleExe -nologo -out "$OutputPath" "Product.wxs"
Write-Host "MSI exit code: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "MSI created: $OutputPath"
