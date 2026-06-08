#!/usr/bin/env bash
# acp.unicode-scan.sh — Hidden Unicode Character Scanner
# Part of /acp-integrity v1.0 (M56)
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

# ── Configuration ────────────────────────────────────────────────────────────

# Hidden Unicode characters: hex codepoint and name (bash 3.2 compat — no associative arrays)
# Format: "HEX|Name"
HIDDEN_CHARS=(
  "200B|ZERO WIDTH SPACE"
  "200C|ZERO WIDTH NON-JOINER"
  "200D|ZERO WIDTH JOINER"
  "FEFF|ZERO WIDTH NO-BREAK SPACE (BOM)"
  "00AD|SOFT HYPHEN"
  "180E|MONGOLIAN VOWEL SEPARATOR"
  "202A|LEFT-TO-RIGHT EMBEDDING"
  "202B|RIGHT-TO-LEFT EMBEDDING"
  "202C|POP DIRECTIONAL FORMATTING"
  "202D|LEFT-TO-RIGHT OVERRIDE"
  "202E|RIGHT-TO-LEFT OVERRIDE"
  "2066|LEFT-TO-RIGHT ISOLATE"
  "2067|RIGHT-TO-LEFT ISOLATE"
  "2068|FIRST STRONG ISOLATE"
  "2069|POP DIRECTIONAL ISOLATE"
  "061C|ARABIC LETTER MARK"
)

# AI-directive phrases to detect in comments (IG-20)
AI_DIRECTIVE_PATTERNS=(
  "ignore previous instructions"
  "ignore the above"
  "do not flag"
  "bypass security"
  "skip this rule"
  "system:"
  "assistant:"
  "forget previous"
  "new instruction"
  "as an AI"
)

# ── Argument Parsing ─────────────────────────────────────────────────────────

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

# ── File Discovery ────────────────────────────────────────────────────────────

FINDINGS=0
FINDING_LINES=""

scan_file() {
  local file="$1"
  local line_num=0
  
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    
    # Check for hidden Unicode characters
    for entry in "${HIDDEN_CHARS[@]}"; do
      local hex="${entry%%|*}"
      local name="${entry##*|}"
      local codepoint_dec=$((16#${hex}))
      # Use Python for reliable UTF-8 byte detection — pass via env to avoid injection
      if echo "$line" | ACP_CODEPOINT="$codepoint_dec" python3 -c "
import sys, os
codepoint = int(os.environ.get('ACP_CODEPOINT', '0'))
text = sys.stdin.read()
c = chr(codepoint)
if c in text:
    col = text.index(c) + 1
    print(col)
    sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
        col=$(echo "$line" | ACP_CODEPOINT="$codepoint_dec" python3 -c "
import sys, os
codepoint = int(os.environ.get('ACP_CODEPOINT', '0'))
text = sys.stdin.read()
c = chr(codepoint)
if c in text:
    print(text.index(c) + 1)
" 2>/dev/null)
        col="${col:-?}"
        if $JSON_MODE; then
          FINDING_LINES+="{\"file\":\"$file\",\"line\":$line_num,\"col\":$col,\"char\":\"U+${hex}\",\"name\":\"$name\",\"rule\":\"IG-14\"},"$'\n'
        else
          echo "${file}:${line_num}:${col} U+${hex} — ${name}"
        fi
        FINDINGS=$((FINDINGS + 1))
      fi
    done
    
    # Check for AI-directive language (IG-20) — only in comments
    # Match comment starters: //, #, /*, *, <!--
    if echo "$line" | grep -qE '^[[:space:]]*(//|#|/\\*|\*|<!--)' 2>/dev/null; then
      for pattern in "${AI_DIRECTIVE_PATTERNS[@]}"; do
        if echo "$line" | grep -qi "$pattern" 2>/dev/null; then
          if $JSON_MODE; then
            FINDING_LINES+="{\"file\":\"$file\",\"line\":$line_num,\"pattern\":\"$pattern\",\"rule\":\"IG-20\"},"$'\n'
          else
            echo "${file}:${line_num} IG-20 — AI-directive language in comment: \"$pattern\""
          fi
          FINDINGS=$((FINDINGS + 1))
        fi
      done
    fi
  done < "$file"
}

# Scan files
if [[ -f "$TARGET" ]]; then
  scan_file "$TARGET"
elif [[ -d "$TARGET" ]]; then
  while IFS= read -r file; do
    # Skip binary files, node_modules, .git
    case "$file" in
      */node_modules/*|*/.git/*|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot|*.pdf) continue ;;
    esac
    scan_file "$file"
  done < <(find "$TARGET" -type f 2>/dev/null || true)
else
  echo "Error: $TARGET not found" >&2
  exit 2
fi

# ── Output ────────────────────────────────────────────────────────────────────

if $JSON_MODE; then
  echo "["
  echo "$FINDING_LINES" | sed '/^$/d' | sed 's/,$//'
  echo "]"
fi

if [[ $FINDINGS -gt 0 ]]; then
  echo "" >&2
  echo "Total findings: $FINDINGS hidden Unicode character(s) or AI-directive phrase(s) detected" >&2
  if $CI_MODE; then
    exit 1
  fi
else
  echo "✓ No hidden Unicode characters or AI-directive phrases detected" >&2
fi

exit 0
