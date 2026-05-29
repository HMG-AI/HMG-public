#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# check-export-leak.sh — Public repo leak detector
#
# Run from HMG-public repo root.
# All checks must PASS before public release.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PASS=0
FAIL=0

check() {
  local name="$1"; shift
  local pattern="$1"; shift
  local exclude="${1:-}"

  # Search all tracked files (not .git)
  local matches
  # Exclude self, ADR doc, and .git
  local skip='\.git/|check-export-leak\.sh|ADR-PUBLIC-RELEASE-HARDENING'
  if [ -n "$exclude" ]; then
    skip="${skip}|${exclude}"
  fi
  matches=$(grep -rn "$pattern" --include='*.rs' --include='*.ts' --include='*.py' --include='*.json' --include='*.yaml' --include='*.yml' --include='*.md' --include='*.sh' --include='*.html' --include='*.toml' . 2>/dev/null | grep -vE "$skip" || true)

  if [ -z "$matches" ]; then
    PASS=$((PASS + 1))
    echo "  ✅ $name"
  else
    FAIL=$((FAIL + 1))
    echo "  ❌ $name"
    echo "$matches" | head -10 | while read -r line; do
      echo "     $line"
    done
  fi
}

check_absent() {
  local name="$1"
  local path="$2"
  if [ ! -e "$path" ]; then
    PASS=$((PASS + 1))
    echo "  ✅ $name"
  else
    FAIL=$((FAIL + 1))
    echo "  ❌ $name — file exists: $path"
  fi
}

echo "=== HMG-public Export Leak Check ==="
echo ""

# P1: No internal ADR files
echo "--- P1: Internal ADR files ---"
check_absent "No docs/adr/ directory" "docs/adr"
check_absent "No adr-classification.md" "docs/md/adr-classification.md"

# P2: No internal module/crate names
echo ""
echo "--- P2: Internal module names ---"
check "No hmg-core references" "hmg-core"
check "No hmg-llm references" "hmg-llm"
check "No MemoryAtom type" "MemoryAtom"
check "No ContentEnvelope" "ContentEnvelope"
check "No Kant taxonomy" "Kant.*CategoryCoord\|Kant.*taxonomy\|Kant.*enum"
check "No CategoryCoord" "CategoryCoord"
check "No AgentQueryResultView" "AgentQueryResultView"
check "No crates/hmg-" "crates/hmg-"

# P3: No internal storage engine names
echo ""
echo "--- P3: Internal storage/algorithm names ---"
check "No Fjall references" "[Ff]jall"
check "No noise_gate" "noise_gate"
check "No fingerprint_index" "fingerprint_index"
check "No semantic.shard" "semantic.shard"
check "No HNSW" "HNSW"
check "No write-ahead log" "write-ahead"
check "No store\.lock" "store\.lock"
check "No daemon\.json" "daemon\.json"
check "No commit_sequence" "commit_sequence"

# P4: No internal daemon name
echo ""
echo "--- P4: Internal process names ---"
check "No hmg-local-daemon" "hmg-local-daemon"

# P5: No consolidation algorithm names
echo ""
echo "--- P5: Internal algorithm names ---"
check "No biomimetic" "biomimetic"
check "No consolidation_scheduler" "consolidation_scheduler"
check "No consolidation.*architecture" "consolidation.*architecture"
check "No ranking.*fusion" "ranking.*fusion"
check "No proprietary.*internals" "proprietary.*internals"

# P6: No license key prefixes in architecture docs
echo ""
echo "--- P6: License key internals ---"
check "No hmg-dev- prefix" "hmg-dev-"
check "No hmg-ent- prefix" "hmg-ent-"

# P7: No Private ADR inventory
echo ""
echo "--- P7: Private ADR inventory ---"
check "No Private ADR count" "Private.*11"
check "No Private ADR list" "\\*\\*Private\\*\\*.*Reveals"
check "No monorepo references" "private monorepo"

# P8: No internal domain/email
echo ""
echo "--- P8: Internal references ---"
check "No funcode.xin" "funcode\.xin"
check "No personal email (monkseekee@gmail.com)" "monkseekee@gmail\.com"

# P9: No internal env vars
echo ""
echo "--- P9: Internal environment variables ---"
check "No HMG_CONSOLIDATION_SCHEDULER" "HMG_CONSOLIDATION_SCHEDULER"
check "No HMG_PROVIDER_BACKEND" "HMG_PROVIDER_BACKEND"

echo ""
echo "=== Results: $PASS PASS, $FAIL FAIL ==="

if [ "$FAIL" -gt 0 ]; then
  echo "❌ BLOCKED — fix leaks before release"
  exit 1
else
  echo "✅ ALL CLEAR — safe for public release"
  exit 0
fi
