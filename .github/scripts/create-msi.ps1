param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
$debug = @()

function Add-Debug($msg) {
    $debug += $msg
    Write-Host $msg
}

Add-Debug "SourceDir: $SourceDir"
Add-Debug "OutputPath: $OutputPath"
if (-not (Test-Path $SourceDir)) {
    Add-Debug "ERROR: SourceDir not found"
    $debug | Out-File -FilePath "$env:TEMP\msi_debug.txt"
    exit 1
}

# Find WiX candle.exe
$CandleExe = $null
$searchPaths = @(
    "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin\candle.exe",
    "${env:ProgramFiles(x86)}\WiX Toolset v3.10\bin\candle.exe",
    "C:\ProgramData\chocolatey\bin\candle.exe",
    "C:\ProgramData\chocolatey\lib\wix\tools\bin\candle.exe"
)
foreach ($p in $searchPaths) {
    if (Test-Path $p) {
        $CandleExe = $p
        Add-Debug "Found candle at: $CandleExe"
        break
    }
}

if (-not $CandleExe) {
    Add-Debug "Installing WiX via chocolatey..."
    choco install wixtoolset -y --no-progress 2>&1 | ForEach-Object { Add-Debug "choco: $_" }
    Start-Sleep -Seconds 30
    foreach ($p in $searchPaths) {
        if (Test-Path $p) {
            $CandleExe = $p
            Add-Debug "Found candle after install: $CandleExe"
            break
        }
    }
}

if (-not $CandleExe) {
    Add-Debug "Searching for candle.exe in C:\ProgramData..."
    $candidates = Get-ChildItem "C:\ProgramData" -Filter "candle.exe" -Recurse -ErrorAction SilentlyContinue -Depth 4 | Select-Object -First 5
    foreach ($c in $candidates) {
        Add-Debug "  Candidate: $($c.FullName)"
    }
    $CandleExe = $candidates | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $CandleExe) {
    Add-Debug "ERROR: candle.exe not found"
    $debug | Out-File -FilePath "$env:TEMP\msi_debug.txt"
    exit 1
}

# Build WXS
$files = Get-ChildItem $SourceDir -Recurse -File
Add-Debug "Files to package: $($files.Count)"
$fileRefs = ""
foreach ($f in $files) {
    $rel = $f.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    $fileRefs += "        <File Name='$($f.Name)' Source='$rel' />`n"
}

$xmlContent = "<?xml version=""1.0""?>`n<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">`n  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">`n    <Package InstallerVersion=""200"" Compressed=""yes"" />`n    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />`n    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">`n      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">`n$fileRefs      </Directory>`n    </Directory>`n  </Product>`n</Wix>"

$wxsPath = Join-Path $env:TEMP "Product.wxs"
$xmlContent | Out-File -FilePath $wxsPath -Encoding UTF8NoBOM
Add-Debug "WXS written: $wxsPath"

# Run candle
$env:PATH = "$(Split-Path $CandleExe);$env:PATH"
Add-Debug "Running candle from: $CandleExe"
try {
    $result = & $CandleExe -nologo -out $OutputPath $wxsPath 2>&1
    foreach ($line in $result) {
        Add-Debug "candle: $line"
    }
    Add-Debug "candle exit: $LASTEXITCODE"
} catch {
    Add-Debug "ERROR running candle: $_"
}

if ((Test-Path $OutputPath) -and (Get-Item $OutputPath).Length -gt 0) {
    Add-Debug "SUCCESS: $OutputPath ($(int.KB) KB)"
} else {
    Add-Debug "ERROR: MSI not created"
}

$debug | Out-File -FilePath "$env:TEMP\msi_debug.txt"
if ((Test-Path $OutputPath) -ne $true) { exit 1 }
