#!/usr/bin/env bash
# acp.unicode-scan.sh — Hidden Unicode Character Scanner
# Part of /acp-integrity v1.0 (M56), M64 routes 179/182
#
# Covered rules: IG-14–IG-16, IG-20, IG-38, IG-39, IG-61

set -euo pipefail
trap 'echo "Error: unicode-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

TARGET="."
IG_REMAINING_ARGS=()
ig_parse_common_args "$@"
set -- "${IG_REMAINING_ARGS[@]:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "Usage: acp.unicode-scan.sh [--ci] [--json] [file|dir]"
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

combined=$(ACP_TARGET="$TARGET" python3 -c "
import os, re, sys
from pathlib import Path

target = Path(os.environ.get('ACP_TARGET', '.'))
SKIP = {'node_modules', '.git'}
HIDDEN = {
    0x200B: ('IG-14', 'ZERO WIDTH SPACE'), 0x200C: ('IG-15', 'ZERO WIDTH NON-JOINER'),
    0x200D: ('IG-16', 'ZERO WIDTH JOINER'), 0xFEFF: ('IG-38', 'BOM'),
    0x00AD: ('IG-39', 'SOFT HYPHEN'), 0x180E: ('IG-61', 'MONGOLIAN VOWEL SEPARATOR'),
    0x202A: ('IG-14', 'BIDI LRE'), 0x202B: ('IG-14', 'BIDI RLE'),
    0x202C: ('IG-14', 'BIDI PDF'), 0x202D: ('IG-14', 'BIDI LRO'),
    0x202E: ('IG-14', 'BIDI RLO'), 0x2066: ('IG-14', 'BIDI LRI'),
    0x2067: ('IG-14', 'BIDI RLI'), 0x2068: ('IG-14', 'BIDI FSI'), 0x2069: ('IG-14', 'BIDI PDI'),
    0x061C: ('IG-14', 'ARABIC LETTER MARK'),
}
AI = ['ignore previous instructions','ignore the above','do not flag','bypass security',
      'skip this rule','system:','assistant:','forget previous','new instruction','as an AI']
COMMENT = re.compile(r'^\\s*(//|#|/\\*|\\*|<!--)')
findings = []

def scan(path: Path):
    try: lines = path.read_text(encoding='utf-8', errors='replace').splitlines()
    except OSError: return
    for i, line in enumerate(lines, 1):
        for j, ch in enumerate(line):
            cp = ord(ch)
            if cp in HIDDEN:
                rule, name = HIDDEN[cp]
                findings.append((str(path), i, rule, f'hidden Unicode U+{cp:04X} ({name})'))
        if COMMENT.match(line):
            low = line.lower()
            for p in AI:
                if p in low:
                    findings.append((str(path), i, 'IG-20', f'AI-directive language: \"{p}\"'))

def walk(root: Path):
    if root.is_file(): scan(root); return
    for p in root.rglob('*'):
        if not p.is_file() or any(x in p.parts for x in SKIP): continue
        scan(p)

walk(target)
for f, ln, rule, msg in findings:
    print(f'{f}:{ln}:{rule}:{msg}')
print(f'ACP_FINDING_COUNT={len(findings)}')
sys.exit(0)
" 2>&1)

while IFS= read -r line; do
  [[ -z "$line" || "$line" == ACP_FINDING_COUNT=* ]] && continue
  if [[ "$line" =~ ^([^:]+):([0-9]+):(IG-[0-9]+):(.+)$ ]]; then
    ig_emit_finding "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
  fi
done <<< "$(echo "$combined" | grep -v '^ACP_FINDING_COUNT=' || true)"

ig_finalize_scan "unicode-scan"
