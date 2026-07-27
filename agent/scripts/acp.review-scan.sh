#!/usr/bin/env bash
# acp.review-scan.sh — Deterministic Phase 1 scanner for /acp-review (audit-085 F-085-07, M70 task-225)
#
# Covered rules: EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01 (8 rules)
# Usage: acp.review-scan.sh [--ci] [--json] [--self] [file|dir ...]
# M83 task-280: accumulate all paths (F-102-01); implement --self (F-102-02);
# include .mjs/.cjs in directory find (F-102-03); re-handle flags after positionals (F-104-06).

set -euo pipefail
trap 'echo "Error: review-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

TARGETS=()
SELF_MODE=false
IG_REMAINING_ARGS=()
ig_parse_common_args "$@"
set -- "${IG_REMAINING_ARGS[@]:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "Usage: acp.review-scan.sh [--ci] [--json] [--self] [file|dir ...]"
      exit 0
      ;;
    --self)
      SELF_MODE=true
      shift
      ;;
    # F-104-06: ig_parse_common_args stops at first positional; flags after paths
    # must be re-handled here so they are never appended as scan targets.
    --ci)
      IG_CI_MODE=true
      shift
      ;;
    --json)
      IG_JSON_MODE=true
      shift
      ;;
    -*)
      echo "Error: unexpected flag: $1" >&2
      exit 2
      ;;
    *)
      TARGETS+=("$1")
      shift
      ;;
  esac
done

if [[ "$SELF_MODE" == "true" ]]; then
  # Documented at acp.review.md — skip missing directories silently (F-102-02)
  for _self_path in scripts/ agent/scripts/ agent/commands/ e2e/; do
    if [[ -d "$_self_path" ]]; then
      TARGETS+=("$_self_path")
    fi
  done
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  if [[ "$SELF_MODE" == "true" ]]; then
    # All --self paths missing — nothing to scan; clean exit
    ig_finalize_scan "review-scan"
  fi
  TARGETS=(".")
fi

for _t in "${TARGETS[@]}"; do
  if [[ ! -e "$_t" ]]; then
    echo "Error: $_t not found" >&2
    exit 2
  fi
done

scan_ts_js() {
  local file="$1"

  # M83 task-282: neutralize comments/strings before non-secret rules (F-103-01);
  # SC-01 still runs on comment-stripped-only text so string secrets remain visible;
  # EH-01 uses token-boundary \btry\b / \.catch\s*\( (F-103-02).
  if ! command -v python3 &>/dev/null; then
    echo "Warning: python3 required for TS/JS review-scan rules; skipping $file" >&2
    return 0
  fi

  while IFS=$'\t' read -r line_num rule message severity || [[ -n "${line_num:-}" ]]; do
    [[ -z "${line_num:-}" ]] && continue
    ig_emit_finding "$file" "$line_num" "$rule" "$message" "$severity"
  done < <(ACP_REVIEW_FILE="$file" python3 "${SCRIPT_DIR}/acp.review-scan-ts.py" 2>/dev/null || true)
}

scan_sh() {
  local file="$1"
  # Sourced function libraries deliberately omit set -euo (would leak into callers).
  # F-M82-05: allowlist + honor explicit exemption comment in first 40 lines.
  case "$file" in
    */acp.common.sh|*/acp.yaml-parser.sh|*/acp.integrity-output.sh|*/acp.driver-yaml.sh|*/acp.coderabbit.sh|*/acp.preferences.sh|*/e2e/*)
      return 0
      ;;
  esac
  if head -40 "$file" | grep -qiE 'sourced function library|deliberately does NOT set `set -euo|when sourced'; then
    return 0
  fi
  if ! head -40 "$file" | grep -q 'set -euo pipefail'; then
    ig_emit_finding "$file" "1" "SH-01" "missing set -euo pipefail" "HIGH"
  fi
}

scan_path() {
  local path="$1"
  if [[ -f "$path" ]]; then
    case "$path" in
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) scan_ts_js "$path" ;;
      *.sh) scan_sh "$path" ;;
    esac
    return 0
  fi
  if [[ -d "$path" ]]; then
    while IFS= read -r f; do
      scan_path "$f"
    done < <(find "$path" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.mjs' -o -name '*.cjs' -o -name '*.sh' \) \
      ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null || true)
  fi
}

for _t in "${TARGETS[@]}"; do
  scan_path "$_t"
done
ig_finalize_scan "review-scan"
