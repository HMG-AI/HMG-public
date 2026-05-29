#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy-release.sh — Deploy release binaries to hmg2ai.com mirror
#
# Usage: ./scripts/deploy-release.sh [version]
# Example: ./scripts/deploy-release.sh 0.9.2
#
# Downloads binaries from GitHub Release and deploys to hmg2ai.com mirror.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REMOTE="root@hmg2ai.com"
MIRROR_DIR="/opt/funcode/hmg-site/releases/latest/download"
REPO="HMG-AI/HMG-public"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        2>/dev/null | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')
    [ -z "$VERSION" ] && { echo "ERROR: Cannot detect version. Pass as argument."; exit 1; }
fi

echo "=== Deploying HMG v${VERSION} to hmg2ai.com mirror ==="

STAGING="/tmp/hmg-release-mirror"
rm -rf "$STAGING"
mkdir -p "$STAGING"

# Download all release assets from GitHub
echo ">>> Downloading from GitHub Release v${VERSION}..."
gh release download "v${VERSION}" \
    --repo "${REPO}" \
    --dir "$STAGING" \
    --clobber 2>/dev/null || {
    echo "ERROR: Failed to download from GitHub. Check gh auth and release existence."
    exit 1
}

ls -lh "$STAGING"

# Deploy to mirror
echo ""
echo ">>> Deploying to ${REMOTE}:${MIRROR_DIR}..."
ssh "$REMOTE" "mkdir -p $MIRROR_DIR"
rsync -avz "$STAGING/" "$REMOTE:$MIRROR_DIR/"

echo ""
echo "✅ Release v${VERSION} deployed to https://hmg2ai.com/releases/latest/download/"
