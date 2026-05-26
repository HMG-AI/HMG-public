#!/usr/bin/env sh
# ─────────────────────────────────────────────────────────────────────────────
# install.sh — One-command installer for HMG Community Edition
#
# Usage:
#   curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
#   curl -fsSL ... | sh -s -- v0.9.2
#   curl -fsSL ... | sh -s -- --prefix ~/bin
#
# Download sources (tried in order):
#   1. GitHub Releases (default, canonical)
#   2. Official website mirror (github.com/HMG-AI)
# ─────────────────────────────────────────────────────────────────────────────
set -eu

HMG_REPO="HMG-AI/HMG-public"
HMG_GITHUB="https://github.com/${HMG_REPO}"
WEBSITE_BASE="https://github.com/HMG-AI/HMG/releases/latest/download"
BIN_DIR="${HMG_INSTALL_DIR:-$HOME/.local/bin}"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t hmg-install)"
REQUESTED_VERSION=""
DRY_RUN=false

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

log() { printf '%s\n' "$*"; }
err() { log "ERROR: $*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || err "Required command not found: $1"; }

# ── Parse args ─────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)  BIN_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      log "HMG Community Edition Installer"
      log ""
      log "Usage: curl -fsSL ${HMG_GITHUB}/releases/latest/download/install.sh | sh -s -- [options] [version]"
      log ""
      log "Options:"
      log "  [version]     Version to install (default: latest)"
      log "  --prefix DIR  Installation directory (default: \$HOME/.local/bin)"
      log "  --dry-run     Show what would happen without installing"
      log "  -h, --help    Show this help"
      exit 0
      ;;
    v*) REQUESTED_VERSION="${1#v}"; shift ;;
    *) err "Unknown option: $1" ;;
  esac
done

need_cmd curl
need_cmd tar

# ── Detect platform ────────────────────────────────────────────────────────
target_triple() {
  os="$(uname -s 2>/dev/null || echo unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$os:$arch" in
    Linux:x86_64|Linux:amd64)  echo "x86_64-unknown-linux-gnu" ;;
    Linux:aarch64|Linux:arm64) echo "aarch64-unknown-linux-gnu" ;;
    Darwin:x86_64)             echo "x86_64-apple-darwin" ;;
    Darwin:arm64|Darwin:aarch64) echo "aarch64-apple-darwin" ;;
    *) echo "" ;;
  esac
}

# ── Resolve version ────────────────────────────────────────────────────────
resolve_version() {
  if [ -n "$REQUESTED_VERSION" ]; then
    VERSION="$REQUESTED_VERSION"
  else
    log "Detecting latest version..."
    latest=$(curl -fsSL "https://api.github.com/repos/${HMG_REPO}/releases/latest" \
      2>/dev/null | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/') || true
    if [ -z "$latest" ]; then
      err "Cannot detect latest version. Specify explicitly: sh -s -- v0.9.2"
    fi
    VERSION="$latest"
  fi
  log "Installing HMG v${VERSION} (Community Edition)"
}

# ── Download and install ───────────────────────────────────────────────────
install_from_url() {
  local url="$1"
  local archive="$2"
  local pkg_dir="$TMP_DIR/package"
  rm -rf "$pkg_dir"
  mkdir -p "$pkg_dir"

  log "  Downloading: $url"
  if ! curl -fL --retry 3 --retry-delay 1 --connect-timeout 20 "$url" -o "$TMP_DIR/$archive" 2>/dev/null; then
    return 1
  fi

  if ! tar -xzf "$TMP_DIR/$archive" -C "$pkg_dir" 2>/dev/null; then
    log "  Downloaded file is not a valid tar.gz"
    return 1
  fi

  for bin in hmg hmg-server hmg-hook-worker; do
    if [ ! -f "$pkg_dir/$bin" ]; then
      log "  Package missing binary: $bin"
      return 1
    fi
  done

  if [ "$DRY_RUN" = true ]; then
    log "  (dry-run) Would install hmg, hmg-server, hmg-hook-worker to $BIN_DIR"
    return 0
  fi

  mkdir -p "$BIN_DIR"
  for bin in hmg hmg-server hmg-hook-worker; do
    install -m 0755 "$pkg_dir/$bin" "$BIN_DIR/$bin"
  done
  return 0
}

do_install() {
  local target
  target="$(target_triple)"
  if [ -z "$target" ]; then
    err "Unsupported platform. Prebuilt binaries available for Linux (x64/ARM64) and macOS (Intel/Apple Silicon)."
  fi

  local archive="hmg-${VERSION}-${target}.tar.gz"
  log "Platform: $target"

  # Source 1: GitHub Releases
  local gh_url="${HMG_GITHUB}/releases/download/v${VERSION}/${archive}"
  if install_from_url "$gh_url" "$archive"; then
    return 0
  fi

  # Source 2: Official website mirror
  local web_url="${WEBSITE_BASE}/${archive}"
  if install_from_url "$web_url" "$archive"; then
    return 0
  fi

  err "Download failed from all sources. Check your network or specify a different version."
}

# ── Main ───────────────────────────────────────────────────────────────────
main() {
  resolve_version
  do_install

  log ""
  log "✅ HMG v${VERSION} installed to ${BIN_DIR}"
  log ""
  log "If hmg is not found, add to PATH:"
  log "  export PATH=\"${BIN_DIR}:\$PATH\""
  log ""
  log "Next steps:"
  log "  hmg init -g          # Install AGENTS.md + agent adapters"
  log "  hmg doctor           # Check system readiness"
  log "  hmg daemon start     # Start background daemon"
  log ""
  log "Documentation: https://hmg-ai.github.io/HMG-public/"
  log "Website:       https://github.com/HMG-AI/HMG/"
  log "GitHub:        ${HMG_GITHUB}"
}

main
