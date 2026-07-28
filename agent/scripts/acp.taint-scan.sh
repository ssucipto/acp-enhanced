#!/usr/bin/env bash
# acp.taint-scan.sh — Taint source/sink extractor + heuristic detector (M58 Phase 2)
# Part of /acp-integrity v2.0
#
# Covered rules: IG-45–IG-50 (preparatory + obvious-sink heuristics)
# Output: <file>:<line> SOURCE|SINK <id>  and  finding lines for heuristics

set -euo pipefail
trap 'echo "Error: taint-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

TARGET="."
PREP_ONLY=false
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
    --prep-only) PREP_ONLY=true; shift ;;
    -h|--help)
      echo "Usage: acp.taint-scan.sh [--ci] [--json] [--prep-only] [file|dir]"
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

combined=$(ACP_TARGET="$TARGET" python3 "${SCRIPT_DIR}/acp.taint-scan.py" 2>&1)

while IFS= read -r line; do
  [[ -z "$line" || "$line" == ACP_FINDING_COUNT=* || "$line" == ACP_MARKER_COUNT=* ]] && continue
  if [[ "$line" =~ ^([^:]+):([0-9]+):(IG-[0-9]+):(.+)$ ]]; then
    if [[ "$PREP_ONLY" != "true" ]]; then
      conf="MEDIUM"
      [[ "${BASH_REMATCH[3]}" == "IG-50" ]] && conf="LOW"
      ig_emit_finding "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "$conf"
    fi
  elif [[ "$line" =~ ^([^:]+):([0-9]+)\ (SOURCE|SINK)\ (.+)$ ]]; then
    printf '%s:%s %s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
  fi
done <<< "$combined"

if [[ "$PREP_ONLY" == "true" ]]; then
  exit 0
fi

ig_finalize_scan "taint-scan"
