param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
Write-Host "SourceDir: $SourceDir"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found"
    exit 1
}

# Install wix dotnet tool
Write-Host "Installing WiX dotnet tool..."
dotnet tool install --global wix --version 3.0.0 2>&1 | Out-Null
$wixPath = dotnet tool path --global wix 2>$null
$CandleExe = Join-Path $wixPath "candle.exe"
Write-Host "WiX path: $CandleExe"

if (-not (Test-Path $CandleExe)) {
    Write-Host "ERROR: candle.exe not found"
    exit 1
}

$files = Get-ChildItem $SourceDir -Recurse -File
Write-Host "Files: $($files.Count)"

$fileRefs = ""
foreach ($f in $files) {
    $rel = $f.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    $fileRefs += "        <File Name='$($f.Name)' Source='$rel' />`n"
}

$xml = "<?xml version=""1.0""?>`n<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">`n  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">`n    <Package InstallerVersion=""200"" Compressed=""yes"" />`n    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />`n    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">`n      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">`n$fileRefs      </Directory>`n    </Directory>`n  </Product>`n</Wix>"

$wxs = Join-Path $env:TEMP "Product.wxs"
$xml | Out-File -FilePath $wxs -Encoding UTF8

Write-Host "Building MSI..."
& $CandleExe -nologo -out $OutputPath $wxs 2>&1
Write-Host "Exit: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "SUCCESS"
