param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
$log = @()
function log($msg) { $script:log += $msg; Write-Host $msg }

log "SourceDir: $SourceDir"
if (-not (Test-Path $SourceDir)) {
    log "ERROR: SourceDir not found"
    $script:log | Out-File -FilePath "$env:TEMP\msi_debug.txt"
    exit 1
}

# Try to find WiX candle.exe from common paths
$CandleExe = $null
$searchPaths = @(
    "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin\candle.exe",
    "${env:ProgramFiles(x86)}\WiX Toolset v3.10\bin\candle.exe",
    "C:\ProgramData\chocolatey\bin\candle.exe",
    "C:\ProgramData\chocolatey\lib\wix\tools\bin\candle.exe"
)
foreach ($p in $searchPaths) {
    if (Test-Path $p) { $CandleExe = $p; break }
}

# Try chocolatey install if not found
if (-not $CandleExe) {
    log "Installing WiX via chocolatey..."
    choco install wixtoolset -y --no-progress 2>&1 | ForEach-Object { log $_ }
    Start-Sleep -Seconds 20
    foreach ($p in $searchPaths) {
        if (Test-Path $p) { $CandleExe = $p; break }
    }
}

if (-not $CandleExe) {
    # Search more broadly
    log "Searching for candle.exe..."
    $found = Get-ChildItem "C:\ProgramData" -Filter "candle.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $CandleExe = $found.FullName }
}

if (-not $CandleExe) {
    log "ERROR: candle.exe not found"
    $script:log | Out-File -FilePath "$env:TEMP\msi_debug.txt"
    exit 1
}
log "Found candle: $CandleExe"

# Build WXS
$files = Get-ChildItem $SourceDir -Recurse -File
log "Files: $($files.Count)"
$fileRefs = ""
foreach ($f in $files) {
    $rel = $f.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    $fileRefs += "        <File Name='$($f.Name)' Source='$rel' />`n"
}

$xml = "<?xml version=""1.0""?>`n<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">`n  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">`n    <Package InstallerVersion=""200"" Compressed=""yes"" />`n    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />`n    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">`n      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">`n$fileRefs      </Directory>`n    </Directory>`n  </Product>`n</Wix>"

$wxs = Join-Path $env:TEMP "Product.wxs"
$xml | Out-File -FilePath $wxs -Encoding UTF8NoBOM
log "WXS written: $wxs"

# Build MSI
log "Running candle..."
$env:PATH = "$(Split-Path $CandleExe);$env:PATH"
$output = & $CandleExe -nologo -out $OutputPath $wxs 2>&1
foreach ($line in $output) { log $line }
log "Exit: $LASTEXITCODE"

if ((Test-Path $OutputPath) -and (Get-Item $OutputPath).Length -gt 0) {
    log "SUCCESS: $OutputPath"
} else {
    log "ERROR: MSI not created or empty"
    exit 1
}

$script:log | Out-File -FilePath "$env:TEMP\msi_debug.txt"
