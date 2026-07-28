#!/usr/bin/env bash
# acp.pattern-scan.sh — Exfiltration & Persistence Pattern Scanner
# Part of /acp-integrity v1.1 (M64 route-180)
#
# Usage: acp.pattern-scan.sh [--ci] [--json] [file|dir]
# Covered rules: IG-04, IG-07–IG-13, IG-21–IG-26

set -euo pipefail
trap 'echo "Error: pattern-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

TARGET="."
IG_REMAINING_ARGS=()
ig_parse_common_args "$@"
# Restore positionals only when non-empty: "${arr[@]:-}" injects a single
# empty-string argument for an empty array, which downstream loops treat
# as a scan target (CodeRabbit PR#13 / F-107-01).
if [[ ${#IG_REMAINING_ARGS[@]} -gt 0 ]]; then
  set -- "${IG_REMAINING_ARGS[@]}"
else
  set --
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "Usage: acp.pattern-scan.sh [--ci] [--json] [file|dir]"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 required" >&2
  exit 2
fi

if [[ ! -e "$TARGET" ]]; then
  echo "Error: $TARGET not found" >&2
  exit 2
fi

combined=$(ACP_TARGET="$TARGET" python3 "${SCRIPT_DIR}/acp.pattern-scan.py" 2>&1)

while IFS= read -r line; do
  [[ -z "$line" || "$line" == ACP_FINDING_COUNT=* ]] && continue
  if [[ "$line" =~ ^([^:]+):([0-9]+):(IG-[0-9]+):(.+)$ ]]; then
    ig_emit_finding "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
  fi
done <<< "$(echo "$combined" | grep -v '^ACP_FINDING_COUNT=' || true)"

ig_finalize_scan "pattern-scan"
