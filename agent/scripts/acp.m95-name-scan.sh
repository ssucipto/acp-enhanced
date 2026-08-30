#!/usr/bin/env bash
# acp.m95-name-scan.sh — encoded deny-list scanner (M95 / ADR-30)
#
# Tokens are stored base64 so tracked sources do not re-publish plaintext names.
# Default: scan git ls-files (HEAD blob contents). Empty match is success (D8).
#
# Usage:
#   bash agent/scripts/acp.m95-name-scan.sh              # scan current repo HEAD
#   bash agent/scripts/acp.m95-name-scan.sh --dir DIR    # scan files under DIR (tests)
#   bash agent/scripts/acp.m95-name-scan.sh --tokens-file PATH
#
# Do NOT add this to CI until HEAD is clean (audit-141 F-141-01 / D13).

set -euo pipefail
trap 'echo "[acp.m95-name-scan] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TOKENS_FILE="${SCRIPT_DIR}/../configurables/m95-name-deny.b64"
SCAN_DIR=""
MODE="repo"

usage() {
  cat <<'EOF'
Usage: acp.m95-name-scan.sh [--dir DIR] [--tokens-file PATH]

Scan tracked files (default) or all regular files under --dir for decoded
deny-list tokens. Exit 1 if any hit; exit 0 if none (empty match is success).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      [[ $# -ge 2 ]] || { echo "[acp.m95-name-scan] ERROR: --dir needs DIR" >&2; exit 2; }
      SCAN_DIR="$2"
      MODE="dir"
      shift 2
      ;;
    --tokens-file)
      [[ $# -ge 2 ]] || { echo "[acp.m95-name-scan] ERROR: --tokens-file needs PATH" >&2; exit 2; }
      TOKENS_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[acp.m95-name-scan] ERROR: unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

[[ -f "${TOKENS_FILE}" ]] || { echo "[acp.m95-name-scan] ERROR: missing tokens file ${TOKENS_FILE}" >&2; exit 2; }

decode_b64() {
  python3 -c 'import base64,sys; sys.stdout.write(base64.b64decode(sys.stdin.read().strip()).decode("utf-8"))'
}

TOKENS=()
while IFS= read -r line || [[ -n "${line}" ]]; do
  [[ -z "${line}" || "${line}" =~ ^# ]] && continue
  TOKENS+=("$(printf '%s' "${line}" | decode_b64)")
done < "${TOKENS_FILE}"

if [[ ${#TOKENS[@]} -eq 0 ]]; then
  echo "[acp.m95-name-scan] ERROR: deny-list decoded to zero tokens" >&2
  exit 2
fi

HITS=0
scan_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  local t
  for t in "${TOKENS[@]}"; do
    if grep -F -q -- "${t}" "${f}" 2>/dev/null; then
      echo "HIT ${f}"
      HITS=$((HITS + 1))
      return 0
    fi
  done
}

if [[ "${MODE}" == "dir" ]]; then
  [[ -d "${SCAN_DIR}" ]] || { echo "[acp.m95-name-scan] ERROR: not a directory: ${SCAN_DIR}" >&2; exit 2; }
  while IFS= read -r -d '' f; do
    scan_file "${f}"
  done < <(find "${SCAN_DIR}" -type f -print0)
else
  cd "${REPO_ROOT}"
  while IFS= read -r f; do
    [[ -z "${f}" ]] && continue
    scan_file "${f}"
  done < <(git ls-files)
fi

if [[ "${HITS}" -gt 0 ]]; then
  echo "[acp.m95-name-scan] ${HITS} file(s) with deny-list hits" >&2
  exit 1
fi
echo "[acp.m95-name-scan] clean (${#TOKENS[@]} tokens)"
exit 0
