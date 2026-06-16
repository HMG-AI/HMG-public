$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ReleaseBaseUrl = if ($env:HMG_RELEASE_BASE_URL) { $env:HMG_RELEASE_BASE_URL } else { "" }
$PublicReleaseBaseUrl = if ($env:HMG_PUBLIC_RELEASE_BASE_URL) { $env:HMG_PUBLIC_RELEASE_BASE_URL } else { "" }
$OfficialReleaseBaseUrl = "https://github.com/HMG-AI/HMG-public/releases/latest/download"
$MirrorBaseUrl = "https://hmg1ai.com/releases/latest/download"
$MirrorBaseUrl2 = "https://hmg2ai.com/releases/latest/download"
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
$script:HmgInstallDeferred = $false

function Log([string] $Message) {
  Write-Host $Message
}

function Invoke-Hmg-Command-With-Timeout([string] $FilePath, [string[]] $Arguments, [int] $TimeoutSeconds) {
  $StdoutPath = [IO.Path]::GetTempFileName()
  $StderrPath = [IO.Path]::GetTempFileName()
  $Output = @()
  try {
    $Process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -NoNewWindow -PassThru -RedirectStandardOutput $StdoutPath -RedirectStandardError $StderrPath
    $Completed = $Process.WaitForExit($TimeoutSeconds * 1000)
    if (-not $Completed) {
      try { Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue } catch {}
      try { $Process.WaitForExit(5000) | Out-Null } catch {}
    }
    if (Test-Path $StdoutPath) { $Output += Get-Content -Path $StdoutPath -ErrorAction SilentlyContinue }
    if (Test-Path $StderrPath) { $Output += Get-Content -Path $StderrPath -ErrorAction SilentlyContinue }
    return [PSCustomObject]@{
      TimedOut = (-not $Completed)
      ExitCode = if ($Completed) { $Process.ExitCode } else { $null }
      Output = $Output
    }
  } finally {
    try { Remove-Item -Force $StdoutPath, $StderrPath -ErrorAction SilentlyContinue } catch {}
  }
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
    Log "  Added to user PATH (persistent)."
  } else {
    Log "  Already in user PATH."
  }

  # Always ensure the current process PATH has the bin dir
  # This is critical — without it hmg setup in the same script will fail
  if (-not (Path-Contains $env:Path $NormalizedBinDir)) {
    $env:Path = if ([string]::IsNullOrWhiteSpace($env:Path)) {
      $NormalizedBinDir
    } else {
      $env:Path.TrimEnd([char[]]@(';')) + ";" + $NormalizedBinDir
    }
    Log "  Added to current process PATH."
  } else {
    Log "  Already in current process PATH."
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

function Target-Triple-GNU {
  $Arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
  switch ($Arch.ToUpperInvariant()) {
    "AMD64" { return "x86_64-pc-windows-gnu" }
    "ARM64" { return "aarch64-pc-windows-gnu" }
    default { return "" }
  }
}

function Supported-Targets {
  Log "Supported Windows prebuilt packages:"
  Log "  hmg-x86_64-pc-windows-msvc.zip"
  Log "  hmg-x86_64-pc-windows-gnu.zip"
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

function Quote-ProcessArgument([string] $Value) {
  return '"' + ($Value -replace '"', '\"') + '"'
}

function Stop-Hmg-Daemon-Before-Install([string] $TargetDir) {
  $ExistingHmg = Join-Path $TargetDir "hmg.exe"
  if (-not (Test-Path $ExistingHmg)) {
    return
  }

  Log "  Stopping existing HMG daemon (if running)..."
  # 1. Graceful stop via the daemon named pipe.
  try {
    $StopOutput = & $ExistingHmg daemon stop 2>&1
    $StopExit = $LASTEXITCODE
    if ($StopExit -eq 0) {
      Log "  Existing HMG daemon stopped."
    } else {
      Log "  No running HMG daemon stopped gracefully (exit $StopExit; non-fatal)."
      $StopOutput | ForEach-Object { Log "  $_" }
    }
  } catch {
    Log "  Could not stop existing HMG daemon before install (non-fatal): $($_.Exception.Message)"
  }

  # 2. Forceful recovery for stale/zombie hmg-server.exe that still holds the
  #    store lock but no longer responds on its named pipe. This is the common
  #    Windows failure when a previous install/update was interrupted: the
  #    daemon holds store.lock while `hmg daemon status` reports "not running",
  #    and Windows refuses to overwrite the locked binaries. `daemon stop --force`
  #    terminates the holder PID and waits for the OS to release store.lock.
  try {
    $ForceOutput = & $ExistingHmg daemon stop --force 2>&1
    $ForceExit = $LASTEXITCODE
    if ($ForceExit -eq 0) {
      Log "  Force-stop sweep completed."
    } else {
      Log "  Force-stop sweep exited $ForceExit (non-fatal)."
      $ForceOutput | ForEach-Object { Log "  $_" }
    }
  } catch {
    Log "  Force-stop sweep failed (non-fatal): $($_.Exception.Message)"
  }

  # 3. Last-resort: terminate any lingering hmg-server.exe / hmg.exe processes so
  #    Windows will release the store lock and let us overwrite the binaries.
  foreach ($ProcName in @("hmg-server", "hmg")) {
    try {
      $Procs = Get-Process -Name $ProcName -ErrorAction SilentlyContinue
      if ($Procs) {
        Log "  Terminating lingering $ProcName process(es)..."
        $Procs | Stop-Process -Force -ErrorAction SilentlyContinue
      }
    } catch {
      Log "  Could not terminate $ProcName (non-fatal): $($_.Exception.Message)"
    }
  }

  # 4. Give the OS a moment to release the file handles / store lock before copy.
  Start-Sleep -Milliseconds 500
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

function Invoke-Hmg-Command-With-Timeout([string] $FilePath, [string[]] $Arguments, [int] $TimeoutSeconds) {
  $StdoutPath = [IO.Path]::GetTempFileName()
  $StderrPath = [IO.Path]::GetTempFileName()
  $Output = @()
  try {
    $Process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -NoNewWindow -PassThru -RedirectStandardOutput $StdoutPath -RedirectStandardError $StderrPath
    $Completed = $Process.WaitForExit($TimeoutSeconds * 1000)
    if (-not $Completed) {
      try { Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue } catch {}
      try { $Process.WaitForExit(5000) | Out-Null } catch {}
    }
    if (Test-Path $StdoutPath) { $Output += Get-Content -Path $StdoutPath -ErrorAction SilentlyContinue }
    if (Test-Path $StderrPath) { $Output += Get-Content -Path $StderrPath -ErrorAction SilentlyContinue }
    return [PSCustomObject]@{
      TimedOut = (-not $Completed)
      ExitCode = if ($Completed) { $Process.ExitCode } else { $null }
      Output = $Output
    }
  } finally {
    try { Remove-Item -Force $StdoutPath, $StderrPath -ErrorAction SilentlyContinue } catch {}
  }
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
    $HmgExe = Join-Path $BinDir "hmg.exe"
    if (Test-Path $HmgExe) {
      Append-Log "Stopping any stale daemon before setup."
      try {
        $PreSetupStop = & $HmgExe daemon stop --force 2>&1
        $PreSetupStop | ForEach-Object { Append-Log "pre-setup stop: $_" }
      } catch {
        Append-Log "pre-setup force-stop failed (non-fatal): $($_.Exception.Message)"
      }
      Append-Log "Running hmg setup --no-daemon after deferred update."
      try {
        $Setup = Invoke-Hmg-Command-With-Timeout $HmgExe @("setup", "--no-daemon") 90
        $Setup.Output | ForEach-Object { Append-Log "setup: $_" }
        if ($Setup.TimedOut) {
          Append-Log "hmg setup --no-daemon timed out after deferred update."
        } elseif ($Setup.ExitCode -eq 0) {
          Append-Log "hmg setup --no-daemon completed successfully after deferred update."
        } else {
          Append-Log "hmg setup --no-daemon exited with code $($Setup.ExitCode) after deferred update."
        }
        Append-Log "Starting HMG daemon after deferred update (best effort)."
        $DaemonStart = Invoke-Hmg-Command-With-Timeout $HmgExe @("daemon", "start") 45
        $DaemonStart.Output | ForEach-Object { Append-Log "daemon-start: $_" }
        if ($DaemonStart.TimedOut) {
          Append-Log "hmg daemon start timed out after deferred update."
        } elseif ($DaemonStart.ExitCode -eq 0) {
          Append-Log "hmg daemon start completed successfully after deferred update."
        } else {
          Append-Log "hmg daemon start exited with code $($DaemonStart.ExitCode) after deferred update."
        }
      } catch {
        Append-Log "hmg initialization failed after deferred update: $($_.Exception.Message)"
      }
    }
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
    (Quote-ProcessArgument $HelperPath),
    "-PackageDir",
    (Quote-ProcessArgument $DeferredPackageDir),
    "-BinDir",
    (Quote-ProcessArgument $TargetDir),
    "-BinsCsv",
    (Quote-ProcessArgument ($Bins -join "|")),
    "-LogPath",
    (Quote-ProcessArgument $LogPath)
  ) | Out-Null

  $script:HmgInstallDeferred = $true
  Log "  Binaries are in use — update will finish in the background."
  Log "  Deferred update log: $LogPath"
  return $true
}

function Install-Hmg-Binaries([string] $SourceDir, [string] $TargetDir, [string[]] $Bins) {
  New-Item -ItemType Directory -Force $TargetDir | Out-Null
  Stop-Hmg-Daemon-Before-Install $TargetDir
  if (Try-Copy-Hmg-Binaries $SourceDir $TargetDir $Bins) {
    return $true
  }

  Log "  Could not replace HMG binaries immediately: $script:LastBinaryCopyError"
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

  Log "  Trying: $Url"
  try {
    Download-File $Url $ArchivePath
  } catch {
    Log "  Download failed: $Url"
    return $false
  }

  try {
    Expand-Archive -Path $ArchivePath -DestinationPath $PackageDir -Force
  } catch {
    Log "  Invalid zip package: $Url"
    return $false
  }

  $RequiredBins = @("hmg.exe", "hmg-server.exe", "hmg-hook-worker.exe")
  foreach ($Bin in $RequiredBins) {
    if (-not (Test-Path (Join-Path $PackageDir $Bin))) {
      Log "  Missing binary: $Bin"
      return $false
    }
  }

  return Install-Hmg-Binaries $PackageDir $BinDir $RequiredBins
}

function Release-Base-Urls {
  $BaseUrls = @($ReleaseBaseUrl, $PublicReleaseBaseUrl, $OfficialReleaseBaseUrl, $MirrorBaseUrl, $MirrorBaseUrl2)
  $BaseUrls = $BaseUrls | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
  Write-Output $BaseUrls
}

function Resolve-Version-From-Release-Json([string] $BaseUrl) {
  if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    return $null
  }

  $VersionUrl = $BaseUrl.TrimEnd("/") + "/version.json"
  try {
    $Resp = Invoke-RestMethod -Uri $VersionUrl -TimeoutSec 10
    if ($Resp -and $Resp.version) {
      return [string] $Resp.version
    }
  } catch {}
  return $null
}

function Resolve-Latest-Version {
  foreach ($BaseUrl in (Release-Base-Urls)) {
    $Version = Resolve-Version-From-Release-Json $BaseUrl
    if ($Version) {
      return $Version
    }
  }

  try {
    $ApiUrl = "https://api.github.com/repos/HMG-AI/HMG-public/releases/latest"
    $Resp = Invoke-RestMethod -Uri $ApiUrl -TimeoutSec 10
    if ($Resp.tag_name -match '^v?(.+)$') {
      return $Matches[1]
    }
  } catch {}
  return $null
}

function Install-From-Release {
  $Version = Resolve-Latest-Version

  # Try MSVC first (preferred), then fall back to GNU toolchain
  $MsvcTarget = Target-Triple
  $GnuTarget = Target-Triple-GNU
  $Targets = @($MsvcTarget, $GnuTarget) | Where-Object { $_ -ne "" } | Select-Object -Unique

  if ($Targets.Count -eq 0) {
    Log "Unsupported Windows architecture: $env:PROCESSOR_ARCHITECTURE"
    Supported-Targets
    return $false
  }

  foreach ($Target in $Targets) {
    Log "Platform: Windows/$env:PROCESSOR_ARCHITECTURE ($Target)"

    # Try versioned name first (e.g. hmg-1.0.0-x86_64-pc-windows-gnu.zip)
    # then fall back to unversioned (e.g. hmg-x86_64-pc-windows-gnu.zip)
    $Assets = @()
    if ($Version) {
      $Assets += "hmg-$Version-$Target.zip"
    }
    $Assets += "hmg-$Target.zip"

    foreach ($Asset in $Assets) {
      foreach ($BaseUrl in (Release-Base-Urls)) {
        if ($BaseUrl -and (Install-From-Release-Url $Asset $BaseUrl)) {
          return $true
        }
      }
    }
  }

  Log "No prebuilt HMG release package found for any supported target."
  Supported-Targets
  return $false
}

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

try {
  Log ""
  Log "╔══════════════════════════════════════╗"
  Log "║       HMG Installer for Windows      ║"
  Log "╚══════════════════════════════════════╝"
  Log ""

  # ── Step 1: Download & install binaries ──────────────────
  Log "[1/3] Downloading HMG..."
  New-Item -ItemType Directory -Force $TempDir | Out-Null
  if (-not (Install-From-Release)) {
    throw "HMG install failed: no release package is available for this platform."
  }
  Log "  Binaries installed."

  # ── Step 2: Configure PATH ───────────────────────────────
  Log ""
  Log "[2/3] Configuring PATH..."
  Add-Hmg-To-Path

  # Verify hmg is reachable right now via the installed path
  $HmgExe = Join-Path $BinDir "hmg.exe"
  if (-not (Test-Path $HmgExe)) {
    Log "  WARNING: hmg.exe not found at $HmgExe"
  }

  # ── Step 3: Run hmg setup ───────────────────────────────
  Log ""
  if ($script:HmgInstallDeferred) {
    Log "[3/3] Initializing HMG (deferred)..."
    Log "  HMG binaries are still being replaced in the background."
    Log "  The deferred update helper will run hmg setup after the new binaries are installed."
  } else {
    Log "[3/3] Initializing HMG (hmg setup --no-daemon)..."
    try {
      # Keep installer setup non-blocking: create the store and configure agents first,
      # then start the daemon as a bounded best-effort step. A broken Windows named
      # pipe can otherwise make `hmg setup` wait forever while probing daemon status.
      $Setup = Invoke-Hmg-Command-With-Timeout $HmgExe @("setup", "--no-daemon") 90
      if ($Setup.TimedOut) {
        Log "  hmg setup --no-daemon timed out after 90s (non-fatal)."
        Log "  You can run it manually later: hmg setup --no-daemon"
      } elseif ($Setup.ExitCode -eq 0) {
        Log "  hmg setup --no-daemon completed successfully."
      } else {
        Log "  hmg setup --no-daemon exited with code $($Setup.ExitCode) (non-fatal)."
      }
      $Setup.Output | ForEach-Object { Log "  $_" }

      Log "  Starting HMG daemon (best effort, 45s timeout)..."
      $DaemonStart = Invoke-Hmg-Command-With-Timeout $HmgExe @("daemon", "start") 45
      if ($DaemonStart.TimedOut) {
        Log "  hmg daemon start timed out after 45s (non-fatal)."
        Log "  Installation is complete; run later: hmg daemon stop --force; hmg daemon start"
      } elseif ($DaemonStart.ExitCode -eq 0) {
        Log "  hmg daemon start completed successfully."
      } else {
        Log "  hmg daemon start exited with code $($DaemonStart.ExitCode) (non-fatal)."
        Log "  You can start it later: hmg daemon start"
      }
      $DaemonStart.Output | ForEach-Object { Log "  $_" }
    } catch {
      Log "  hmg initialization failed: $($_.Exception.Message)"
      Log "  You can run it manually later: hmg setup --no-daemon; hmg daemon start"
    }
  }

  Log ""
  Log "╔══════════════════════════════════════╗"
  Log "║          Installation complete!       ║"
  Log "╚══════════════════════════════════════╝"
  Log ""
  Log "  Install dir: $BinDir"
  Log ""
  Log "  Quick commands:"
  Log "    hmg doctor           # Check system readiness"
  Log "    hmg daemon start     # Start background daemon"
  Log "    hmg tui              # Open terminal UI"
  Log ""
  Log "  Slow/blocked model downloads (mainland China)?"
  Log "    HMG downloads a small embedding model from HuggingFace on first use."
  Log "    If that is slow or blocked, set a mirror before starting the daemon:"
  Log "      `$env:HF_ENDPOINT = 'https://hf-mirror.com'"
  Log "      `$env:HMG_EMBEDDING_ENDPOINT = 'https://hf-mirror.com'"
  Log "      hmg model embedding download"
  Log ""
  Log "  Update later:"
  Log "    hmg update"
  Log ""
  Log "  Note: Open a new terminal for PATH to take effect in all windows."
} finally {
  if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
  }
}
