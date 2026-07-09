param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "SilentlyContinue"
if (-not (Test-Path $SourceDir)) { exit 0 }
$WIX = "C:\Program Files (x86)\WiX Toolset v3.11\bin"
if (-not (Test-Path $WIX)) {
    Write-Host "WiX not found, skipping MSI"
    exit 0
}
$env:PATH = "$WIX;$env:PATH"
$files = Get-ChildItem $SourceDir -Recurse -File
$fileRefs = ($files | ForEach-Object {
    $rel = $_.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
    "        <File Name='$($_.Name)' Source='$rel' />"
}) -join "`n"
$WXS = "<?xml version=`"1.0`"?>
<Wix xmlns=`"http://schemas.microsoft.com/wix/2006/wi`">
  <Product Name=`"whiteTV`" Id=`"*`" UpgradeCode=`"*`" Language=`"1033`" Version=`"$Version`" Manufacturer=`"whiteTV`">
    <Package InstallerVersion=`"200`" Compressed=`"yes`" />
    <Media Id=`"1`" Cabinet=`"whiteTV.cab`" EmbedCab=`"yes`" />
    <Directory Id=`"ProgramFilesFolder`" Name=`"PFiles`">
      <Directory Id=`"INSTALLFOLDER`" Name=`"whiteTV`">
$fileRefs
      </Directory>
    </Directory>
  </Product>
</Wix>"
$WXS | Out-File -FilePath "Product.wxs" -Encoding UTF8
candle -nologo -ext WixUIExtension -dVersion="$Version" -dSourceDir="$SourceDir" -out "$OutputPath" "Product.wxs"
Write-Host "MSI exit code: $LASTEXITCODE"
