#!/usr/bin/env bash
# acp.manifest-hash.sh — SHA-256 Manifest Generator & Verifier
# Part of /acp-integrity v1.0 (M56)
#
# Generates and verifies SHA-256 hashes of ACP framework files for tamper
# detection. Used by /acp-integrity --diff flag.
#
# Usage:
#   acp.manifest-hash.sh --generate           Generate manifest.yaml from current files
#   acp.manifest-hash.sh --verify             Verify files against stored manifest
#   acp.manifest-hash.sh --diff               Alias for --verify with diff output
#   acp.manifest-hash.sh --file <path>        Check single file

set -euo pipefail
trap 'echo "Error: manifest-hash.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MANIFEST_FILE="${PROJECT_ROOT}/agent/manifest.yaml"

# ACP framework files to track
TRACKED_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  ".github/copilot-instructions.md"
  "agent/core/identity.yml"
  "agent/core/constraints.yml"
  "agent/core/routing.yml"
  "agent/core/network_whitelist.yml"
)

MODE=""
SINGLE_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --generate) MODE="generate"; shift ;;
    --verify|--diff) MODE="verify"; shift ;;
    --file) SINGLE_FILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.manifest-hash.sh --generate|--verify [--file <path>]"
      echo "Generates/verifies SHA-256 hashes of ACP framework files"
      exit 0
      ;;
    *) shift ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Error: --generate or --verify required" >&2
  exit 2
fi

# ── Hash Function ─────────────────────────────────────────────────────────────

hash_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    shasum -a 256 "$file" 2>/dev/null | awk '{print $1}'
  else
    echo "MISSING"
  fi
}

# ── Generate Manifest ─────────────────────────────────────────────────────────

if [[ "$MODE" == "generate" ]]; then
  echo "# agent/manifest.yaml"
  echo "# SHA-256 hashes of ACP framework files — generated $(date +%Y-%m-%d)"
  echo "# Used by /acp-integrity --diff for tamper detection"
  echo ""
  echo "version: \"1.0\""
  echo "generated: \"$(date +%Y-%m-%d)\""
  echo "files:"
  
  for f in "${TRACKED_FILES[@]}"; do
    local_path="${PROJECT_ROOT}/${f}"
    hash=$(hash_file "$local_path")
    echo "  - path: \"$f\""
    echo "    sha256: \"$hash\""
    echo "    last_verified: \"$(date +%Y-%m-%d)\""
  done
  
  if [[ -n "$SINGLE_FILE" ]]; then
    hash=$(hash_file "${PROJECT_ROOT}/${SINGLE_FILE}")
    echo "  - path: \"$SINGLE_FILE\""
    echo "    sha256: \"$hash\""
    echo "    last_verified: \"$(date +%Y-%m-%d)\""
  fi
  
  echo ""
  echo "✓ Manifest generated — $((${#TRACKED_FILES[@]} + (${SINGLE_FILE:+1}))) files hashed" >&2
  exit 0
fi

# ── Verify Against Manifest ──────────────────────────────────────────────────

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "Error: $MANIFEST_FILE not found. Run --generate first." >&2
  exit 2
fi

CHANGED=0
MATCHED=0

if [[ -n "$SINGLE_FILE" ]]; then
  actual=$(hash_file "${PROJECT_ROOT}/${SINGLE_FILE}")
  expected=$(grep -A1 "path: \"$SINGLE_FILE\"" "$MANIFEST_FILE" 2>/dev/null | grep 'sha256:' | awk '{print $2}' | tr -d '"' || echo "NOT_IN_MANIFEST")
  if [[ "$actual" == "$expected" ]]; then
    echo "  $SINGLE_FILE: OK"
    MATCHED=$((MATCHED + 1))
  else
    echo "  $SINGLE_FILE: CHANGED (expected: ${expected:0:12}..., actual: ${actual:0:12}...)"
    CHANGED=$((CHANGED + 1))
  fi
else
  for f in "${TRACKED_FILES[@]}"; do
    actual=$(hash_file "${PROJECT_ROOT}/${f}")
    expected=$(grep -A1 "path: \"$f\"" "$MANIFEST_FILE" 2>/dev/null | grep 'sha256:' | awk '{print $2}' | tr -d '"' || echo "NOT_IN_MANIFEST")
    if [[ "$actual" == "$expected" ]]; then
      echo "  $f: OK"
      MATCHED=$((MATCHED + 1))
    elif [[ "$expected" == "NOT_IN_MANIFEST" ]]; then
      echo "  $f: NOT IN MANIFEST (current: ${actual:0:12}...)"
      CHANGED=$((CHANGED + 1))
    else
      echo "  $f: CHANGED (expected: ${expected:0:12}..., actual: ${actual:0:12}...)"
      CHANGED=$((CHANGED + 1))
    fi
  done
fi

echo ""
echo "Verified: $MATCHED matched, $CHANGED changed" >&2

if [[ $CHANGED -gt 0 ]]; then
  exit 1
fi
exit 0
