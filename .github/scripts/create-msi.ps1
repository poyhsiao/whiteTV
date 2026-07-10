param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found: $SourceDir"
    exit 1
}

# Install WiX via chocolatey if not present
$CandleExe = $null

# Search everywhere for candle.exe
$AllDrives = @("C:\", "D:\")
foreach ($drive in $AllDrives) {
    if (Test-Path $drive) {
        $found = Get-ChildItem $drive -Recurse -Filter "candle.exe" -ErrorAction SilentlyContinue -Depth 6 |
            Where-Object { $_.DirectoryName -like "*wix*" } |
            Select-Object -First 1 -ExpandProperty FullName
        if ($found) { $CandleExe = $found; break }
    }
}

if (-not $CandleExe) {
    Write-Host "Installing WiX via chocolatey..."
    choco install wixtoolset -y --no-progress
    Start-Sleep -Seconds 30
    # Search again after install
    foreach ($drive in $AllDrives) {
        if (Test-Path $drive) {
            $found = Get-ChildItem $drive -Recurse -Filter "candle.exe" -ErrorAction SilentlyContinue -Depth 6 |
                Where-Object { $_.DirectoryName -like "*wix*" } |
                Select-Object -First 1 -ExpandProperty FullName
            if ($found) { $CandleExe = $found; break }
        }
    }
}

if (-not $CandleExe) {
    Write-Host "ERROR: candle.exe not found after exhaustive search"
    exit 1
}
Write-Host "Found candle.exe: $CandleExe"
$env:PATH = "$(Split-Path $CandleExe);$env:PATH"

# Build MSI
$files = Get-ChildItem $SourceDir -Recurse -File
Write-Host "Found $($files.Count) files"
$fileRefs = ""
foreach ($f in $files) {
    $rel = $f.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    $fileRefs += "        <File Name='$($f.Name)' Source='$rel' />`n"
}

$xmlContent = "<?xml version=""1.0""?>`n<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">`n  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">`n    <Package InstallerVersion=""200"" Compressed=""yes"" />`n    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />`n    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">`n      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">`n$fileRefs      </Directory>`n    </Directory>`n  </Product>`n</Wix>"

$wxsPath = Join-Path $PWD "Product.wxs"
$xmlContent | Out-File -FilePath $wxsPath -Encoding UTF8NoBOM
Write-Host "Running candle..."
& $CandleExe -nologo -out "$OutputPath" $wxsPath
Write-Host "Exit code: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $OutputPath)) { exit 1 }
Write-Host "SUCCESS: $OutputPath"
