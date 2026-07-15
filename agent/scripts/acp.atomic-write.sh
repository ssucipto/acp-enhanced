#!/usr/bin/env bash
# acp.atomic-write.sh — Atomic file write via temp + rename (M70 GAP-041-08)
#
# Usage: acp.atomic-write.sh <target-file> < content
#    or: echo "data" | acp.atomic-write.sh <target-file>
#    or: acp.atomic-write.sh <target-file> <source-file>

set -euo pipefail
trap 'echo "Error: atomic-write.sh failed at line $LINENO" >&2; exit 3' ERR

if [[ $# -lt 1 ]]; then
  echo "Usage: acp.atomic-write.sh <target-file> [source-file]" >&2
  exit 2
fi

TARGET="$1"
TARGET_DIR="$(dirname "$TARGET")"
mkdir -p "$TARGET_DIR"

TMP="$(mktemp "${TARGET_DIR}/.acp-atomic.XXXXXX")"
trap 'rm -f "$TMP"' EXIT

if [[ $# -ge 2 ]]; then
  cp "$2" "$TMP"
else
  cat > "$TMP"
fi

mv -f "$TMP" "$TARGET"
trap - EXIT
