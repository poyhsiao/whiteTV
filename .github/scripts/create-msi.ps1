param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
Write-Host "SourceDir: $SourceDir"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found"
    exit 1
}

# Install WiX v3 via chocolatey with verbose output
Write-Host "Installing WiX..."
$install = choco install wixtoolset -y --no-progress 2>&1 | Out-String
Write-Host $install

# Find candle.exe
$CandleExe = $null
Get-ChildItem "C:\" -Recurse -Filter "candle.exe" -ErrorAction SilentlyContinue -Depth 5 |
    Where-Object { $_.DirectoryName -like "*wix*" } |
    Select-Object -First 1 -ExpandProperty FullName |
    ForEach-Object { $CandleExe = $_ }

if (-not $CandleExe) {
    Write-Host "ERROR: candle.exe not found"
    exit 1
}
Write-Host "Found: $CandleExe"

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

Write-Host "Building..."
& $CandleExe -nologo -out $OutputPath $wxs 2>&1 | Write-Host
Write-Host "Exit: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "SUCCESS: $OutputPath"
