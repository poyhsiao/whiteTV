param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Continue"
if (-not (Test-Path $SourceDir)) {
    Write-Host "ERROR: SourceDir not found: $SourceDir"
    Get-ChildItem . -Depth 3 | Select-Object FullName | Out-Host
    exit 1
}

# Find or install WiX
$CandleExe = $null

# Try dotnet tool first
$dotnetWix = dotnet tool path --global wix 2>$null
if ($dotnetWix -and (Test-Path "$dotnetWix\candle.exe")) {
    $CandleExe = "$dotnetWix\candle.exe"
    Write-Host "Found WiX dotnet tool at: $CandleExe"
}

# Try common install paths
if (-not $CandleExe) {
    $SearchPaths = @(
        "C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe",
        "C:\Program Files (x86)\WiX Toolset v3.10\bin\candle.exe",
        "C:\Program Files (x86)\WiX Toolset\bin\candle.exe",
        "C:\ProgramData\chocolatey\lib\wixtoolset\tools\bin\candle.exe",
        "C:\ProgramData\chocolatey\lib\wix\tools\bin\candle.exe"
    )
    foreach ($path in $SearchPaths) {
        if (Test-Path $path) {
            $CandleExe = $path
            Write-Host "Found WiX at: $CandleExe"
            break
        }
    }
}

# Install WiX dotnet tool if not found
if (-not $CandleExe) {
    Write-Host "Installing WiX dotnet tool..."
    dotnet tool install --global wix 2>$null
    $CandleExe = dotnet tool path --global wix
    $CandleExe = "$CandleExe\candle.exe"
    Write-Host "Installed WiX at: $CandleExe"
}

if (-not (Test-Path $CandleExe)) {
    Write-Host "ERROR: candle.exe not found after all attempts"
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
Write-Host "Building MSI with candle.exe from: $CandleExe"
candle -nologo -out "$OutputPath" "Product.wxs"
Write-Host "MSI candle exit code: $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "MSI created: $OutputPath"
