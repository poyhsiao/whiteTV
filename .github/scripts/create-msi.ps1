param([string]$Version, [string]$SourceDir, [string]$OutputPath)
$ErrorActionPreference = "Stop"
$debug = @()
$failed = $false

function D($msg) {
    $debug += $msg
    Write-Host "[DBG] $msg"
}

D "=== MSI Build Started ==="
D "SourceDir: $SourceDir"
D "OutputPath: $OutputPath"

try {
    if (-not (Test-Path $SourceDir)) {
        throw "SourceDir not found: $SourceDir"
    }

    # Install wix CLI if not present
    D "Checking for wix CLI..."
    $wixCmd = Get-Command wix -ErrorAction SilentlyContinue
    if (-not $wixCmd) {
        D "Installing wix CLI..."
        dotnet tool install --global wix 2>&1 | ForEach-Object { D "dotnet: $_" }
        $env:PATH = "$env:PATH;$env:USERPROFILE\.dotnet\tools"
        $wixCmd = Get-Command wix -ErrorAction SilentlyContinue
    }
    if (-not $wixCmd) {
        throw "wix CLI not found after install"
    }
    D "Found wix: $($wixCmd.Source)"

    # Build WXS
    $files = Get-ChildItem $SourceDir -Recurse -File
    D "Files: $($files.Count)"
    $fileRefs = ""
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($SourceDir.Length + 1).Replace("\", "/")
        $fileRefs += "        <File Name='$($f.Name)' Source='$rel' />`n"
    }

    $xml = "<?xml version=""1.0""?>`n<Wix xmlns=""http://schemas.microsoft.com/wix/2006/wi"">`n  <Product Name=""whiteTV"" Id=""*"" UpgradeCode=""*"" Language=""1033"" Version=""$Version"" Manufacturer=""whiteTV"">`n    <Package InstallerVersion=""200"" Compressed=""yes"" />`n    <Media Id=""1"" Cabinet=""whiteTV.cab"" EmbedCab=""yes"" />`n    <Directory Id=""ProgramFilesFolder"" Name=""PFiles"">`n      <Directory Id=""INSTALLFOLDER"" Name=""whiteTV"">`n$fileRefs      </Directory>`n    </Directory>`n  </Product>`n</Wix>"

    $wxsPath = Join-Path $env:TEMP "Product_$PID.wxs"
    D "Writing WXS to: $wxsPath"
    $xml | Out-File -FilePath $wxsPath -Encoding UTF8

    # Build MSI
    D "Building MSI..."
    D "Command: wix build -nologo -out $OutputPath $wxsPath"
    $errFile = Join-Path $env:TEMP "wix_err_$PID.txt"
    $outFile = Join-Path $env:TEMP "wix_out_$PID.txt"

    $proc = Start-Process -FilePath $wixCmd.Source -ArgumentList "build", "-nologo", "-out", $OutputPath, $wxsPath -NoNewWindow -Wait -PassThru -RedirectStandardError $errFile -RedirectStandardOutput $outFile
    D "Exit code: $($proc.ExitCode)"

    if ((Test-Path $outFile) -and (Get-Content $outFile -Raw)) {
        Get-Content $outFile | ForEach-Object { D "OUT: $_" }
    }
    if ((Test-Path $errFile) -and (Get-Content $errFile -Raw)) {
        Get-Content $errFile | ForEach-Object { D "ERR: $_" }
    }

    if ((Test-Path $OutputPath) -and (Get-Item $OutputPath).Length -gt 0) {
        D "SUCCESS: $OutputPath ($(int.KB) KB)"
    } else {
        throw "MSI not created"
    }

} catch {
    D "FATAL ERROR: $_"
    $failed = $true
} finally {
    $debugPath = Join-Path $env:TEMP "msi_debug.txt"
    $debug | Out-File -FilePath $debugPath -Encoding UTF8
    D "Debug log: $debugPath"
    if ($failed) { exit 1 }
}
