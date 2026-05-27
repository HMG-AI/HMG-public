$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ReleaseBaseUrl = if ($env:HMG_RELEASE_BASE_URL) { $env:HMG_RELEASE_BASE_URL } else { "" }
$PublicReleaseBaseUrl = if ($env:HMG_PUBLIC_RELEASE_BASE_URL) { $env:HMG_PUBLIC_RELEASE_BASE_URL } else { "" }
$OfficialReleaseBaseUrl = "https://github.com/HMG-AI/HMG-public/releases/latest/download"
$MirrorBaseUrl = "https://hmg2ai.com/releases/latest/download"
$BinDir = if ($env:HMG_INSTALL_DIR) {
  $env:HMG_INSTALL_DIR
} elseif ($env:LOCALAPPDATA) {
  Join-Path $env:LOCALAPPDATA "Programs\HMG\bin"
} elseif ($env:USERPROFILE) {
  Join-Path $env:USERPROFILE ".local\bin"
} else {
  Join-Path $HOME ".local\bin"
}
$TempDir = Join-Path ([IO.Path]::GetTempPath()) ("hmg-install-" + [Guid]::NewGuid().ToString("N"))

function Log([string] $Message) {
  Write-Host $Message
}

function Need-Cmd([string] $Name) {
  return [bool] (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Normalize-PathEntry([string] $Entry) {
  if ([string]::IsNullOrWhiteSpace($Entry)) {
    return ""
  }

  $Expanded = [Environment]::ExpandEnvironmentVariables($Entry.Trim())
  try {
    return [IO.Path]::GetFullPath($Expanded).TrimEnd([char[]]@('\', '/'))
  } catch {
    return $Expanded.TrimEnd([char[]]@('\', '/'))
  }
}

function Path-Contains([string] $PathValue, [string] $Entry) {
  $NormalizedEntry = Normalize-PathEntry $Entry
  foreach ($PathPart in ($PathValue -split ";")) {
    if ((Normalize-PathEntry $PathPart).Equals($NormalizedEntry, [StringComparison]::OrdinalIgnoreCase)) {
      return $true
    }
  }
  return $false
}

function Add-Hmg-To-Path {
  $NormalizedBinDir = Normalize-PathEntry $BinDir
  $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")

  if (-not (Path-Contains $UserPath $NormalizedBinDir)) {
    $NewUserPath = if ([string]::IsNullOrWhiteSpace($UserPath)) {
      $NormalizedBinDir
    } else {
      $UserPath.TrimEnd([char[]]@(';')) + ";" + $NormalizedBinDir
    }
    [Environment]::SetEnvironmentVariable("Path", $NewUserPath, "User")
    Log "Added HMG bin directory to your user PATH."
  } else {
    Log "HMG bin directory is already in your user PATH."
  }

  if (-not (Path-Contains $env:Path $NormalizedBinDir)) {
    $env:Path = if ([string]::IsNullOrWhiteSpace($env:Path)) {
      $NormalizedBinDir
    } else {
      $env:Path.TrimEnd([char[]]@(';')) + ";" + $NormalizedBinDir
    }
    Log "Added HMG bin directory to this PowerShell process PATH."
  }
}

function Target-Triple {
  $Arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
  switch ($Arch.ToUpperInvariant()) {
    "AMD64" { return "x86_64-pc-windows-msvc" }
    "ARM64" { return "aarch64-pc-windows-msvc" }
    default { return "" }
  }
}

function Supported-Targets {
  Log "Supported Windows prebuilt packages:"
  Log "  hmg-x86_64-pc-windows-msvc.zip"
  Log "  hmg-aarch64-pc-windows-msvc.zip"
}

function Download-File([string] $Url, [string] $OutputPath) {
  $LastError = $null
  for ($Attempt = 1; $Attempt -le 3; $Attempt++) {
    $Client = $null
    try {
      $Client = New-Object Net.WebClient
      $Client.DownloadFile($Url, $OutputPath)
      return
    } catch {
      $LastError = $_
      Start-Sleep -Seconds $Attempt
    } finally {
      if ($Client) {
        $Client.Dispose()
      }
    }
  }
  throw $LastError
}

function PowerShell-Command {
  if (Need-Cmd "pwsh") {
    return "pwsh"
  }
  return "powershell"
}

function Try-Copy-Hmg-Binaries([string] $SourceDir, [string] $TargetDir, [string[]] $Bins) {
  try {
    foreach ($Bin in $Bins) {
      Copy-Item -Force (Join-Path $SourceDir $Bin) (Join-Path $TargetDir $Bin)
    }
    return $true
  } catch {
    $script:LastBinaryCopyError = $_.Exception.Message
    return $false
  }
}

function Schedule-Deferred-Binary-Install([string] $SourceDir, [string] $TargetDir, [string[]] $Bins) {
  $DeferredRoot = Join-Path ([IO.Path]::GetTempPath()) ("hmg-deferred-install-" + [Guid]::NewGuid().ToString("N"))
  $DeferredPackageDir = Join-Path $DeferredRoot "package"
  $HelperPath = Join-Path $DeferredRoot "finish-hmg-update.ps1"
  $LogPath = Join-Path $DeferredRoot "finish-hmg-update.log"

  New-Item -ItemType Directory -Force $DeferredPackageDir | Out-Null
  foreach ($Bin in $Bins) {
    Copy-Item -Force (Join-Path $SourceDir $Bin) (Join-Path $DeferredPackageDir $Bin)
  }

  $HelperScript = @'
param(
  [Parameter(Mandatory = $true)][string] $PackageDir,
  [Parameter(Mandatory = $true)][string] $BinDir,
  [Parameter(Mandatory = $true)][string] $BinsCsv,
  [Parameter(Mandatory = $true)][string] $LogPath
)

$ErrorActionPreference = "Stop"
$RequiredBins = $BinsCsv -split "\|"
$Deadline = (Get-Date).AddMinutes(3)
$LastErrorMessage = ""

function Append-Log([string] $Message) {
  $Timestamp = (Get-Date).ToString("s")
  Add-Content -Path $LogPath -Value "[$Timestamp] $Message"
}

function Try-Copy-Bins {
  try {
    foreach ($Bin in $RequiredBins) {
      Copy-Item -Force (Join-Path $PackageDir $Bin) (Join-Path $BinDir $Bin)
    }
    return $true
  } catch {
    $script:LastErrorMessage = $_.Exception.Message
    return $false
  }
}

Append-Log "Waiting for HMG binaries to be released before finishing update."
while ((Get-Date) -lt $Deadline) {
  if (Try-Copy-Bins) {
    Append-Log "HMG deferred update completed successfully."
    try { Remove-Item -Recurse -Force $PackageDir } catch {}
    exit 0
  }
  Start-Sleep -Milliseconds 500
}

Append-Log "Timed out while replacing HMG binaries: $LastErrorMessage"
exit 1
'@

  Set-Content -Path $HelperPath -Value $HelperScript -Encoding UTF8

  $PowerShell = PowerShell-Command
  Start-Process -FilePath $PowerShell -WindowStyle Hidden -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    $HelperPath,
    "-PackageDir",
    $DeferredPackageDir,
    "-BinDir",
    $TargetDir,
    "-BinsCsv",
    ($Bins -join "|"),
    "-LogPath",
    $LogPath
  ) | Out-Null

  Log "HMG binaries are currently in use, so the update will finish in the background after this command exits."
  Log "Deferred update log: $LogPath"
  return $true
}

function Install-Hmg-Binaries([string] $SourceDir, [string] $TargetDir, [string[]] $Bins) {
  New-Item -ItemType Directory -Force $TargetDir | Out-Null
  if (Try-Copy-Hmg-Binaries $SourceDir $TargetDir $Bins) {
    return $true
  }

  Log "Could not replace HMG binaries immediately: $script:LastBinaryCopyError"
  return Schedule-Deferred-Binary-Install $SourceDir $TargetDir $Bins
}

function Install-From-Release-Url([string] $Asset, [string] $BaseUrl) {
  $Url = $BaseUrl.TrimEnd("/") + "/" + $Asset
  $ArchivePath = Join-Path $TempDir $Asset
  $PackageDir = Join-Path $TempDir "package"

  if (Test-Path $PackageDir) {
    Remove-Item -Recurse -Force $PackageDir
  }
  New-Item -ItemType Directory -Force $PackageDir | Out-Null

  Log "Trying HMG release: $Url"
  try {
    Download-File $Url $ArchivePath
  } catch {
    Log "Release unavailable or download failed: $Url"
    return $false
  }

  try {
    Expand-Archive -Path $ArchivePath -DestinationPath $PackageDir -Force
  } catch {
    Log "Downloaded release is not a valid zip package: $Url"
    return $false
  }

  $RequiredBins = @("hmg.exe", "hmg-server.exe", "hmg-hook-worker.exe")
  foreach ($Bin in $RequiredBins) {
    if (-not (Test-Path (Join-Path $PackageDir $Bin))) {
      Log "Release package is missing required binary: $Bin"
      return $false
    }
  }

  return Install-Hmg-Binaries $PackageDir $BinDir $RequiredBins
}

function Resolve-Latest-Version {
  try {
    $ApiUrl = "https://api.github.com/repos/HMG-AI/HMG-public/releases/latest"
    $Resp = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing -TimeoutSec 10
    if ($Resp.tag_name -match '^v?(.+)$') {
      return $Matches[1]
    }
  } catch {}
  return $null
}

function Install-From-Release {
  $Target = Target-Triple
  if (-not $Target) {
    Log "Unsupported Windows architecture for prebuilt install: $env:PROCESSOR_ARCHITECTURE"
    Supported-Targets
    return $false
  }

  $Version = Resolve-Latest-Version

  # Try versioned name first (e.g. hmg-0.9.2-x86_64-pc-windows-msvc.zip)
  # then fall back to unversioned (e.g. hmg-x86_64-pc-windows-msvc.zip)
  $Assets = @()
  if ($Version) {
    $Assets += "hmg-$Version-$Target.zip"
  }
  $Assets += "hmg-$Target.zip"

  Log "Detected platform: Windows/$env:PROCESSOR_ARCHITECTURE -> $Target"

  foreach ($Asset in $Assets) {
    foreach ($BaseUrl in @($PublicReleaseBaseUrl, $OfficialReleaseBaseUrl, $MirrorBaseUrl)) {
      if ($BaseUrl -and (Install-From-Release-Url $Asset $BaseUrl)) {
        return $true
      }
    }
  }

  Log "No prebuilt HMG release package found for $Target."
  Supported-Targets
  return $false
}

try {
  New-Item -ItemType Directory -Force $TempDir | Out-Null
  if (-not (Install-From-Release)) {
    throw "HMG install failed: no release mirror package is available for this platform."
  }

  Log ""
  Add-Hmg-To-Path
  Log ""
  Log "HMG installed to:"
  Log "  $BinDir"
  Log ""
  Log "If this PowerShell window still cannot find hmg, refresh this window with:"
  Log "  `$env:Path += ';$BinDir'"
  Log ""
  Log "Next steps:"
  Log "  hmg init -g"
  Log "  hmg doctor"
  Log "  hmg daemon start"
  Log ""
  Log "Update later with:"
  Log "  hmg update"
} finally {
  if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
  }
}
