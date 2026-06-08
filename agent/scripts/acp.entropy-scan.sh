#!/usr/bin/env bash
# acp.entropy-scan.sh — Shannon Entropy Calculator for String Literals
# Part of /acp-integrity v1.0 (M56)
#
# Calculates Shannon entropy for string literals in source files.
# High entropy (>4.5 bits/char) indicates potential encoded/encrypted payloads.
#
# Usage:
#   acp.entropy-scan.sh [file|dir]        Scan strings in file or directory
#   acp.entropy-scan.sh --ci [file|dir]   Exit 1 on any high-entropy finding
#   acp.entropy-scan.sh --threshold N     Set custom threshold (default: 4.5)
#
# Covered rules: IG-17 (entropy), IG-18 (hex/base64 runtime decoding)

set -euo pipefail
trap 'echo "Error: entropy-scan.sh failed at line $LINENO" >&2; exit 3' ERR

# ── Configuration ────────────────────────────────────────────────────────────

DEFAULT_THRESHOLD="4.5"
THRESHOLD="$DEFAULT_THRESHOLD"
CI_MODE=false
TARGET="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) CI_MODE=true; shift ;;
    --threshold) THRESHOLD="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.entropy-scan.sh [--ci] [--threshold N] [file|dir]"
      echo "Scans string literals for high Shannon entropy (encoded payload detection)"
      echo "  --ci           Exit 1 on any finding"
      echo "  --threshold N  Custom entropy threshold (default: 4.5)"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

# ── Entropy Calculation ───────────────────────────────────────────────────────

FINDINGS=0

# Python3 is required for math.log2 precision
if ! command -v python3 &>/dev/null; then
  echo "Warning: python3 not found — entropy scan requires Python 3" >&2
  echo "Install python3 or skip entropy scan with --rules flag" >&2
  exit 2
fi

scan_file_entropy() {
  local file="$1"
  
  # Pass parameters via environment to avoid shell injection
  local output
  output=$(ACP_THRESHOLD="$THRESHOLD" ACP_FILEPATH="$file" python3 -c "
import sys, math, re, os

threshold = float(os.environ.get('ACP_THRESHOLD', '4.5'))
filepath = os.environ.get('ACP_FILEPATH', '')

def shannon_entropy(s):
    if not s:
        return 0.0
    freq = {}
    for c in s:
        freq[c] = freq.get(c, 0) + 1
    length = len(s)
    return -sum((count / length) * math.log2(count / length) for count in freq.values())

try:
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
except Exception as e:
    print(f'Error reading {filepath}: {e}', file=sys.stderr)
    sys.exit(0)

string_pattern = re.compile(r'([\"\x60])(?:(?!\1).)*?\1|\x27(?:(?!\x27).)*?\x27')
line_num = 0
findings = 0
for line in lines:
    line_num += 1
    for match in string_pattern.finditer(line):
        s = match.group(0)
        if len(s) < 20:
            continue
        ent = shannon_entropy(s)
        if ent > threshold:
            snippet = s[:80] + ('...' if len(s) > 80 else '')
            print(f'{filepath}:{line_num} entropy={ent:.2f} \"{snippet}\"')
            findings += 1
    if re.search(r'(?:0x[0-9a-fA-F]{16,}|[A-Za-z0-9+/]{40,}={0,2})', line):
        if not re.search(r'^\s*(?:const|let|var|#define|0x[0-9a-fA-F]{1,8}\b)', line):
            snippet = line.strip()[:80]
            print(f'{filepath}:{line_num} IG-18 — potential hex/base64 runtime decoding: \"{snippet}\"')
            findings += 1

if findings > 0:
    print(f'', file=sys.stderr)
    print(f'Total findings: {findings} high-entropy or encoded string(s) detected', file=sys.stderr)
sys.exit(findings)
" 2>/dev/null)
  
  local ret=$?
  echo "$output"
  FINDINGS=$((FINDINGS + ret))
}

# ── Scan ──────────────────────────────────────────────────────────────────────

if [[ -f "$TARGET" ]]; then
  scan_file_entropy "$TARGET"
elif [[ -d "$TARGET" ]]; then
  while IFS= read -r file; do
    case "$file" in
      */node_modules/*|*/.git/*|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot|*.pdf|*.min.js|*.min.css) continue ;;
    esac
    # Only scan source files
    case "$file" in
      *.ts|*.tsx|*.js|*.jsx|*.py|*.rb|*.go|*.rs|*.sh|*.bash|*.yml|*.yaml|*.md|*.json)
        scan_file_entropy "$file"
        ;;
    esac
  done < <(find "$TARGET" -type f 2>/dev/null || true)
else
  echo "Error: $TARGET not found" >&2
  exit 2
fi

if [[ $FINDINGS -gt 0 ]]; then
  if $CI_MODE; then
    exit 1
  fi
else
  echo "✓ No high-entropy strings detected (threshold: $THRESHOLD bits/char)" >&2
fi

exit 0
