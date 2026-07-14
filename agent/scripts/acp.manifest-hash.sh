#!/usr/bin/env bash
# acp.manifest-hash.sh — SHA-256 Manifest Generator & Verifier
# Part of /acp-integrity v1.0 (M56), M64 routes 182/183
#
# Covered rules: IG-42 (framework tamper detection via --verify)

set -euo pipefail
trap 'echo "Error: manifest-hash.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MANIFEST_FILE="${PROJECT_ROOT}/agent/integrity-manifest.yaml"
source "${SCRIPT_DIR}/acp.common.sh"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"
source "${SCRIPT_DIR}/acp.yaml-parser.sh"

TRACKED_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  ".github/copilot-instructions.md"
  "agent/core/identity.yml"
  "agent/core/constraints.yml"
  "agent/core/routing.yml"
  "agent/core/network_whitelist.yml"
)

TRACKED_DIRS=(
  "agent/core"
  "agent/skills"
  ".cursor/commands"
)

MODE=""
SINGLE_FILE=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --generate) MODE="generate"; shift ;;
    --verify|--diff) MODE="verify"; shift ;;
    --ci) IG_CI_MODE=true; shift ;;
    --json) IG_JSON_MODE=true; shift ;;
    --file) SINGLE_FILE="$2"; shift 2 ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.manifest-hash.sh --generate|--verify [--output path] [--ci] [--json] [--file path]"
      exit 0
      ;;
    *) shift ;;
  esac
done

hash_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    calculate_checksum "$file" 2>/dev/null || echo "MISSING"
  else
    echo "MISSING"
  fi
}

collect_tracked_paths() {
  local paths=()
  local f d
  for f in "${TRACKED_FILES[@]}"; do paths+=("$f"); done
  for d in "${TRACKED_DIRS[@]}"; do
    if [[ -d "${PROJECT_ROOT}/${d}" ]]; then
      while IFS= read -r fp; do
        case "$fp" in
          */node_modules/*|*/.git/*) continue ;;
        esac
        rel="${fp#${PROJECT_ROOT}/}"
        rel="${rel#./}"
        paths+=("$rel")
      done < <(find "${PROJECT_ROOT}/${d}" -type f 2>/dev/null || true)
    fi
  done
  if [[ -n "$SINGLE_FILE" ]]; then
    paths+=("$SINGLE_FILE")
  fi
  printf '%s\n' "${paths[@]}" | sort -u
}

if [[ -z "$MODE" ]]; then
  echo "Error: --generate or --verify required" >&2
  exit 2
fi

if [[ "$MODE" == "generate" ]]; then
  {
    echo "# agent/integrity-manifest.yaml"
    echo "# SHA-256 hashes of ACP framework files — generated $(date +%Y-%m-%d)"
    echo "# Used by /acp-integrity --diff for tamper detection (separate from package manifest.yaml)"
    echo ""
    echo "version: \"1.1\""
    echo "generated: \"$(date +%Y-%m-%d)\""
    echo "files:"
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      h=$(hash_file "${PROJECT_ROOT}/${f}")
      echo "  - path: \"$f\""
      echo "    sha256: \"$h\""
      echo "    last_verified: \"$(date +%Y-%m-%d)\""
    done < <(collect_tracked_paths)
  } | if [[ -n "$OUTPUT_FILE" ]]; then
    tee "$OUTPUT_FILE"
  else
    tee "$MANIFEST_FILE"
  fi
  echo "✓ Manifest generated" >&2
  exit 0
fi

lookup_manifest_sha256() {
  local target="$1"
  awk -v path="$target" '
    /^[[:space:]]*- path:/ {
      if (index($0, "\"" path "\"")) { found=1 } else { found=0 }
      next
    }
    found && /^[[:space:]]*sha256:/ {
      gsub(/^[[:space:]]*sha256:[[:space:]]*"/, "")
      gsub(/".*$/, "")
      print
      exit
    }
  ' "$MANIFEST_FILE"
}

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "Error: $MANIFEST_FILE not found. Run --generate first." >&2
  exit 2
fi

yaml_parse "$MANIFEST_FILE" >/dev/null 2>&1 || {
  ig_emit_finding "$MANIFEST_FILE" "0" "IG-42" "integrity-manifest.yaml failed YAML parse"
  ig_finalize_scan "manifest-hash"
}

while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  actual=$(hash_file "${PROJECT_ROOT}/${f}")
  expected=$(lookup_manifest_sha256 "$f")
  if [[ -z "$expected" ]]; then
    ig_emit_finding "$f" "0" "IG-42" "file not in manifest (sha256: ${actual:0:12}...)"
  elif [[ "$actual" != "$expected" ]]; then
    ig_emit_finding "$f" "0" "IG-42" "hash mismatch (expected ${expected:0:12}..., actual ${actual:0:12}...)"
  fi
done < <(collect_tracked_paths)

ig_finalize_scan "manifest-hash"
