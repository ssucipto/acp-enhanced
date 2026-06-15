#!/usr/bin/env bash
# acp.unicode-scan.sh — Hidden Unicode Character Scanner
# Part of /acp-integrity v1.0 (M56), hardened M64 route-179
#
# Detects invisible/hidden Unicode characters used in Rules File Backdoor attacks
# (Pillar Security, March 2025). Scans for zero-width characters, bidirectional
# text markers, and Unicode homoglyphs.
#
# Usage:
#   acp.unicode-scan.sh [file|dir]        Scan file or directory (default: .)
#   acp.unicode-scan.sh --ci [file|dir]   Exit 1 on any finding
#   acp.unicode-scan.sh --json [file|dir] JSON output format
#
# Covered rules: IG-14, IG-15, IG-16, IG-38, IG-39, IG-61
# Also covers: IG-20 (AI-directive language in comments)

set -euo pipefail
trap 'echo "Error: unicode-scan.sh failed at line $LINENO" >&2; exit 3' ERR

CI_MODE=false
JSON_MODE=false
TARGET="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) CI_MODE=true; shift ;;
    --json) JSON_MODE=true; shift ;;
    -h|--help)
      echo "Usage: acp.unicode-scan.sh [--ci] [--json] [file|dir]"
      echo "Scans for hidden Unicode characters (Rules File Backdoor detection)"
      echo "  --ci     Exit 1 on any finding"
      echo "  --json   Output findings as JSON"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 required for unicode scan" >&2
  exit 2
fi

if [[ ! -e "$TARGET" ]]; then
  echo "Error: $TARGET not found" >&2
  exit 2
fi

# One Python process for the entire scan target (F-070-04 single-pass performance).
combined=$(ACP_TARGET="$TARGET" ACP_JSON_MODE="$($JSON_MODE && echo json || echo text)" python3 -c "
import json, os, re, sys
from pathlib import Path

target = os.environ.get('ACP_TARGET', '.')
json_mode = os.environ.get('ACP_JSON_MODE', 'text') == 'json'

SKIP_PARTS = {'node_modules', '.git'}
SKIP_SUFFIXES = {'.png', '.jpg', '.gif', '.ico', '.pdf', '.woff', '.woff2', '.ttf', '.eot'}

HIDDEN_CHARS = {
    0x200B: ('IG-14', 'ZERO WIDTH SPACE'),
    0x200C: ('IG-15', 'ZERO WIDTH NON-JOINER'),
    0x200D: ('IG-16', 'ZERO WIDTH JOINER'),
    0xFEFF: ('IG-38', 'ZERO WIDTH NO-BREAK SPACE (BOM)'),
    0x00AD: ('IG-39', 'SOFT HYPHEN'),
    0x180E: ('IG-61', 'MONGOLIAN VOWEL SEPARATOR'),
    0x202A: ('IG-14', 'LEFT-TO-RIGHT EMBEDDING'),
    0x202B: ('IG-14', 'RIGHT-TO-LEFT EMBEDDING'),
    0x202C: ('IG-14', 'POP DIRECTIONAL FORMATTING'),
    0x202D: ('IG-14', 'LEFT-TO-RIGHT OVERRIDE'),
    0x202E: ('IG-14', 'RIGHT-TO-LEFT OVERRIDE'),
    0x2066: ('IG-14', 'LEFT-TO-RIGHT ISOLATE'),
    0x2067: ('IG-14', 'RIGHT-TO-LEFT ISOLATE'),
    0x2068: ('IG-14', 'FIRST STRONG ISOLATE'),
    0x2069: ('IG-14', 'POP DIRECTIONAL ISOLATE'),
    0x061C: ('IG-14', 'ARABIC LETTER MARK'),
}

AI_DIRECTIVE_PATTERNS = [
    'ignore previous instructions', 'ignore the above', 'do not flag',
    'bypass security', 'skip this rule', 'system:', 'assistant:',
    'forget previous', 'new instruction', 'as an AI',
]

COMMENT_RE = re.compile(r'^\\s*(//|#|/\\*|\\*|<!--)')

def iter_files(root: Path):
    if root.is_file():
        yield root
        return
    for path in root.rglob('*'):
        if not path.is_file():
            continue
        if any(part in SKIP_PARTS for part in path.parts):
            continue
        if path.suffix.lower() in SKIP_SUFFIXES:
            continue
        yield path

def scan_file(filepath: Path, findings: list):
    try:
        text = filepath.read_text(encoding='utf-8', errors='replace')
    except OSError as e:
        print(f'Error reading {filepath}: {e}', file=sys.stderr)
        return
    for line_num, line in enumerate(text.splitlines(), start=1):
        for idx, ch in enumerate(line):
            cp = ord(ch)
            if cp in HIDDEN_CHARS:
                rule_id, name = HIDDEN_CHARS[cp]
                findings.append({
                    'file': str(filepath), 'line': line_num, 'col': idx + 1,
                    'rule': rule_id, 'char': f'U+{cp:04X}', 'name': name, 'kind': 'unicode',
                })
        if COMMENT_RE.match(line):
            lower = line.lower()
            for pattern in AI_DIRECTIVE_PATTERNS:
                if pattern in lower:
                    findings.append({
                        'file': str(filepath), 'line': line_num,
                        'col': lower.index(pattern) + 1, 'rule': 'IG-20',
                        'pattern': pattern, 'kind': 'ai_directive',
                    })

findings = []
scan_file(Path(target), findings) if Path(target).is_file() else None
if Path(target).is_dir():
    for fp in iter_files(Path(target)):
        scan_file(fp, findings)

if json_mode:
    print(json.dumps(findings, indent=2))
else:
    for item in findings:
        if item['kind'] == 'unicode':
            print(f\"{item['file']}:{item['line']}:{item['col']} {item['char']} — {item['name']}\")
        else:
            print(f\"{item['file']}:{item['line']} IG-20 — AI-directive language in comment: \\\"{item['pattern']}\\\"\")

if findings:
    print(f'Total findings: {len(findings)} hidden Unicode character(s) or AI-directive phrase(s) detected', file=sys.stderr)
print(f'ACP_FINDING_COUNT={len(findings)}')
sys.exit(0)
" 2>&1)

count_line=$(echo "$combined" | grep '^ACP_FINDING_COUNT=' | tail -1 || true)
FINDINGS="${count_line#ACP_FINDING_COUNT=}"
FINDINGS="${FINDINGS:-0}"

echo "$combined" | grep -v '^ACP_FINDING_COUNT=' || true

if [[ $FINDINGS -gt 0 ]]; then
  if $CI_MODE; then
    exit 1
  fi
else
  echo "✓ No hidden Unicode characters or AI-directive phrases detected" >&2
fi

exit 0
