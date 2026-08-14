#!/usr/bin/env bash
# acp.upgrade-guard.sh — assert local ACP enhancements survived an upgrade (M86 / ADR-25)
#
# Reads agent/upstream-delta.yml and greps each recorded sentinel (grep -F).
# A missing sentinel means the upgrade reverted a local enhancement.
#
# POLICY (prefer-upstream-when-superseded):
#   A reverted enhancement is NOT automatically a regression. If upstream now
#   ships its own version, compare, verify, prefer upstream when equal/better,
#   then DELETE the entry from upstream-delta.yml. This script makes loss visible.
#
# P-UG-1: When wired from acp.version-update.sh, missing sentinel → HARD fail
#   (non-zero). Never soft-warn-only. See version-update-hook.snippet.draft.
#
# Usage:
#   bash agent/scripts/acp.upgrade-guard.sh
#   bash agent/scripts/acp.upgrade-guard.sh --list

set -euo pipefail
trap 'echo "[acp.upgrade-guard] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

REGISTER="${REPO_ROOT}/agent/upstream-delta.yml"
LIST_ONLY=false
EXECUTED_STEPS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) LIST_ONLY=true; shift ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--list]"
      echo "  Asserts every sentinel in agent/upstream-delta.yml is still present."
      echo "  Missing sentinel → exit 1 (HARD fail)."
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -f "${REGISTER}" ]]; then
  echo "[acp.upgrade-guard] ERROR: ${REGISTER} not found — nothing to guard." >&2
  exit 1
fi

# Extract path/sentinel pairs from the collisions: block (python — quote-safe).
_pairs() {
  python3 - "${REGISTER}" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read().splitlines()
inblk = False
path = ""
for line in text:
    if re.match(r"^collisions:\s*$", line):
        inblk = True
        continue
    if re.match(r"^[a-z_]+:", line) and not line.startswith(" "):
        if not line.startswith("collisions:"):
            inblk = False
        continue
    if not inblk:
        continue
    m = re.match(r"^\s*-\s*path:\s*(.*)$", line)
    if m:
        path = m.group(1).strip().strip("\"'")
        continue
    m = re.match(r"^\s*sentinel:\s*(.*)$", line)
    if m and path:
        sent = m.group(1).strip()
        if (sent.startswith("'") and sent.endswith("'")) or (sent.startswith('"') and sent.endswith('"')):
            sent = sent[1:-1]
        print(f"{path}\t{sent}")
        path = ""
PY
}

if [[ "${LIST_ONLY}" == "true" ]]; then
  echo "Guarded local enhancements (agent/upstream-delta.yml):"
  # FG-1: avoid pipefail issues counting; list is display-only
  if _pairs | while IFS=$'\t' read -r p s; do
    printf "  %-46s %s\n" "${p}" "${s}"
  done; then
    :
  fi
  exit 0
fi

echo "=== ACP upgrade guard ==="
echo "register:  agent/upstream-delta.yml"
if grep -qE '^acp_core_version:' "${REGISTER}"; then
  echo "acp_core:  $(grep -E '^acp_core_version:' "${REGISTER}" | awk '{print $2}')"
fi
echo ""

PASS_COUNT=0
FAIL_COUNT=0
MISSING_FILES=0

while IFS=$'\t' read -r path sentinel; do
  [[ -n "${path}" && -n "${sentinel}" ]] || continue
  EXECUTED_STEPS=$((EXECUTED_STEPS + 1))
  if [[ ! -f "${REPO_ROOT}/${path}" ]]; then
    printf "  MISSING FILE  %-46s\n" "${path}"
    MISSING_FILES=$((MISSING_FILES + 1))
    FAIL_COUNT=$((FAIL_COUNT + 1))
    continue
  fi
  # Fixed-string grep: sentinels may contain regex metacharacters
  if grep -qF -- "${sentinel}" "${REPO_ROOT}/${path}"; then
    printf "  OK            %-46s\n" "${path}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf "  REVERTED      %-46s  sentinel: %s\n" "${path}" "${sentinel}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done < <(_pairs)

echo ""
echo "executed_steps: ${EXECUTED_STEPS}"

# FG-2: zero collisions checked is not success if register claims collisions
if [[ "${EXECUTED_STEPS}" -eq 0 ]]; then
  echo "[ACP upgrade-guard] NO-OP | zero collision entries checked — refuse PASS" >&2
  echo "  Add collisions under agent/upstream-delta.yml or remove the register." >&2
  exit 2
fi

if [[ "${FAIL_COUNT}" -eq 0 ]]; then
  echo "[ACP upgrade-guard] PASS | ${PASS_COUNT} local enhancements intact"
  exit 0
fi

echo "[ACP upgrade-guard] ${FAIL_COUNT} REVERTED | ${PASS_COUNT} intact | missing_files=${MISSING_FILES}"
echo ""
echo "Remediation (P-UG-1 HARD fail):"
echo "  1. Check whether upstream now ships an equivalent (see upstream_ref / supersede_when)."
echo "  2. If upstream is equal or better — verify it, then DELETE the entry from upstream-delta.yml."
echo "  3. Otherwise restore the sentinel string in the file and re-run this guard."
echo ""
echo "Do not blindly re-apply. Upstream may have shipped something better."
exit 1
