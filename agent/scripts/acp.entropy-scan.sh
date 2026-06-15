#!/usr/bin/env bash
# acp.entropy-scan.sh — Shannon Entropy Calculator for String Literals
# Part of /acp-integrity v1.0 (M56), M64 routes 179/182
#
# Covered rules: IG-17 (entropy), IG-18 (hex/base64 runtime decoding)

set -euo pipefail
trap 'echo "Error: entropy-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

DEFAULT_THRESHOLD="4.5"
THRESHOLD="$DEFAULT_THRESHOLD"
TARGET="."

IG_REMAINING_ARGS=()
ig_parse_common_args "$@"
set -- "${IG_REMAINING_ARGS[@]:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.entropy-scan.sh [--ci] [--json] [--threshold N] [file|dir]"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

if ! command -v python3 &>/dev/null; then
  echo "Warning: python3 not found — entropy scan requires Python 3" >&2
  exit 2
fi

scan_file_entropy() {
  local file="$1"
  local combined
  combined=$(ACP_THRESHOLD="$THRESHOLD" ACP_FILEPATH="$file" python3 -c "
import sys, math, re, os
threshold = float(os.environ.get('ACP_THRESHOLD', '4.5'))
filepath = os.environ.get('ACP_FILEPATH', '')

def shannon_entropy(s):
    if not s: return 0.0
    freq = {}
    for c in s: freq[c] = freq.get(c, 0) + 1
    length = len(s)
    return -sum((count / length) * math.log2(count / length) for count in freq.values())

findings = []
try:
    lines = open(filepath, 'r', encoding='utf-8', errors='ignore').readlines()
except Exception as e:
    print(f'Error reading {filepath}: {e}', file=sys.stderr)
    print('ACP_FINDING_COUNT=0'); sys.exit(0)

string_pattern = re.compile(r'([\"\\x60])(?:(?!\\1).)*?\\1|\\x27(?:(?!\\x27).)*?\\x27')
for line_num, line in enumerate(lines, 1):
    for match in string_pattern.finditer(line):
        s = match.group(0)
        if len(s) < 20: continue
        ent = shannon_entropy(s)
        if ent > threshold:
            findings.append((line_num, 'IG-17', f'entropy={ent:.2f} high-entropy string literal'))
    if re.search(r'(?:0x[0-9a-fA-F]{16,}|[A-Za-z0-9+/]{40,}={0,2})', line):
        if not re.search(r'^\\s*(?:const|let|var|#define|0x[0-9a-fA-F]{1,8}\\b)', line):
            findings.append((line_num, 'IG-18', 'potential hex/base64 runtime decoding'))

for ln, rule, msg in findings:
    print(f'{filepath}:{ln}:{rule}:{msg}')
print(f'ACP_FINDING_COUNT={len(findings)}')
sys.exit(0)
" 2>&1)

  while IFS= read -r line; do
    [[ -z "$line" || "$line" == ACP_FINDING_COUNT=* ]] && continue
    if [[ "$line" =~ ^([^:]+):([0-9]+):(IG-[0-9]+):(.+)$ ]]; then
      ig_emit_finding "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
    fi
  done <<< "$(echo "$combined" | grep -v '^ACP_FINDING_COUNT=' || true)"
}

if [[ -f "$TARGET" ]]; then
  scan_file_entropy "$TARGET"
elif [[ -d "$TARGET" ]]; then
  while IFS= read -r file; do
    case "$file" in
      */node_modules/*|*/.git/*|*.png|*.jpg|*.gif|*.min.js) continue ;;
      *.ts|*.tsx|*.js|*.jsx|*.py|*.sh|*.yml|*.yaml|*.md|*.json)
        scan_file_entropy "$file" ;;
    esac
  done < <(find "$TARGET" -type f 2>/dev/null || true)
else
  echo "Error: $TARGET not found" >&2
  exit 2
fi

ig_finalize_scan "entropy-scan"
