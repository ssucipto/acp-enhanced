#!/usr/bin/env bash
# acp.m95-name-scan.sh — encoded deny-list scanner (M95 / ADR-30)
#
# Tokens are stored base64 so tracked sources do not re-publish plaintext names.
# Default: scan HEAD blobs via git grep. Empty match is success (D8).
#
# Usage:
#   bash agent/scripts/acp.m95-name-scan.sh              # scan current repo HEAD
#   bash agent/scripts/acp.m95-name-scan.sh --dir DIR    # scan files under DIR (tests)
#   bash agent/scripts/acp.m95-name-scan.sh --tokens-file PATH
#
# Default --repo mode is a CI job after HEAD redact (audit-142 F-142-05 / D13).
# Fixture tests (--dir) stay the unit coverage; they do not require a clean HEAD.
# One git-grep / grep -F -f pass (not per-file per-token) so windows-latest
# stays under the 180s e2e timeout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TOKENS_FILE="${SCRIPT_DIR}/../configurables/m95-name-deny.b64"
SCAN_DIR=""
MODE="repo"
TMP_TOKENS=""

cleanup_tokens() { rm -f "${TMP_TOKENS}"; }
trap 'cleanup_tokens; echo "[acp.m95-name-scan] Error on line ${LINENO}" >&2; exit 1' ERR
trap cleanup_tokens EXIT

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
  # python3 first (same as other ACP tools); openssl is the no-python fallback (FG-4).
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import base64,sys; sys.stdout.write(base64.b64decode(sys.stdin.read().strip()).decode("utf-8"))'
  elif command -v openssl >/dev/null 2>&1; then
    openssl base64 -d -A
  else
    echo "[acp.m95-name-scan] ERROR: need python3 or openssl to decode deny-list" >&2
    exit 2
  fi
}

TOKEN_COUNT=0
TMP_TOKENS="$(mktemp "${TMPDIR:-/tmp}/m95-tokens.XXXXXX")"
: > "${TMP_TOKENS}"
while IFS= read -r line || [[ -n "${line}" ]]; do
  [[ -z "${line}" || "${line}" =~ ^# ]] && continue
  printf '%s\n' "$(printf '%s' "${line}" | decode_b64)" >> "${TMP_TOKENS}"
  TOKEN_COUNT=$((TOKEN_COUNT + 1))
done < "${TOKENS_FILE}"

if [[ "${TOKEN_COUNT}" -eq 0 ]]; then
  echo "[acp.m95-name-scan] ERROR: deny-list decoded to zero tokens" >&2
  exit 2
fi

HITS=0
# Process substitution (not a pipe) so HITS updates in this shell. Do not print
# matching lines — filenames only (never re-publish deny-list tokens).
if [[ "${MODE}" == "dir" ]]; then
  [[ -d "${SCAN_DIR}" ]] || { echo "[acp.m95-name-scan] ERROR: not a directory: ${SCAN_DIR}" >&2; exit 2; }
  while IFS= read -r f; do
    [[ -z "${f}" ]] && continue
    echo "HIT ${f}"
    HITS=$((HITS + 1))
  done < <(grep -R -F -I -l -f "${TMP_TOKENS}" -- "${SCAN_DIR}" 2>/dev/null || true)
else
  cd "${REPO_ROOT}"
  while IFS= read -r f; do
    [[ -z "${f}" ]] && continue
    echo "HIT ${f}"
    HITS=$((HITS + 1))
  done < <(git --no-pager grep -F -I -l -f "${TMP_TOKENS}" HEAD -- 2>/dev/null | sed 's/^HEAD://' || true)
fi

if [[ "${HITS}" -gt 0 ]]; then
  echo "[acp.m95-name-scan] ${HITS} file(s) with deny-list hits" >&2
  exit 1
fi
echo "[acp.m95-name-scan] clean (${TOKEN_COUNT} tokens)"
exit 0
