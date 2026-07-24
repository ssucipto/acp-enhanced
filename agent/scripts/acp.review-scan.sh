#!/usr/bin/env bash
# acp.review-scan.sh — Deterministic Phase 1 scanner for /acp-review (audit-085 F-085-07, M70 task-225)
#
# Covered rules: EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01 (8 rules)
# Usage: acp.review-scan.sh [--ci] [--json] [file|dir]

set -euo pipefail
trap 'echo "Error: review-scan.sh failed at line $LINENO" >&2; exit 3' ERR

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
      echo "Usage: acp.review-scan.sh [--ci] [--json] [file|dir]"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [[ ! -e "$TARGET" ]]; then
  echo "Error: $TARGET not found" >&2
  exit 2
fi

scan_ts_js() {
  local file="$1"
  local line_num=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    if echo "$line" | grep -qE '(API_KEY|api[_-]?key|jwtSecret|databasePassword)\s*=\s*["'"'"'][^"'"'"']+["'"'"']' 2>/dev/null; then
      ig_emit_finding "$file" "$line_num" "SC-01" "hardcoded secret pattern" "CRITICAL"
    elif echo "$line" | grep -qiE '(password|secret)\s*:\s*["'"'"'][^"'"'"']+["'"'"']' 2>/dev/null; then
      ig_emit_finding "$file" "$line_num" "SC-01" "hardcoded secret pattern" "CRITICAL"
    fi

    if echo "$line" | grep -qE ':\s*any\b|as\s+any\b' 2>/dev/null; then
      ig_emit_finding "$file" "$line_num" "TS-01" "any type usage" "HIGH"
    fi

    if echo "$line" | grep -qE '^export (async )?function [a-zA-Z0-9_]+\([^)]*\)\s*\{' 2>/dev/null; then
      if ! echo "$line" | grep -qE '\)\s*:\s*[A-Za-z{[]' 2>/dev/null; then
        ig_emit_finding "$file" "$line_num" "TS-02" "exported function missing return type" "HIGH"
      fi
    fi

    if echo "$line" | grep -qE 'res\.(json|send)\([^)]*\)' 2>/dev/null; then
      if ! echo "$line" | grep -qE '(data\s*:|"data"\s*:)' 2>/dev/null; then
        ig_emit_finding "$file" "$line_num" "AP-01" "response missing data envelope" "HIGH"
      fi
    fi

    if echo "$line" | grep -qE '^(const|let|var) [a-z]+_[a-z0-9_]*\s*=' 2>/dev/null; then
      ig_emit_finding "$file" "$line_num" "NC-01" "snake_case variable in TS/JS" "MEDIUM"
    fi
  done < "$file"

  if command -v python3 &>/dev/null; then
    while IFS= read -r eh_line; do
      [[ -z "$eh_line" ]] && continue
      ig_emit_finding "$file" "$eh_line" "EH-02" "empty catch block" "HIGH"
    done < <(ACP_REVIEW_FILE="$file" python3 - <<'PY' 2>/dev/null || true
import os, re
path = os.environ["ACP_REVIEW_FILE"]
text = open(path, encoding="utf-8", errors="replace").read()
for m in re.finditer(r"catch\s*\([^)]*\)\s*\{([^}]*)\}", text, re.DOTALL):
    body = re.sub(r"//.*?$", "", m.group(1), flags=re.MULTILINE)
    body = re.sub(r"/\*.*?\*/", "", body, flags=re.DOTALL)
    if not body.strip():
        line = text[: m.start()].count("\n") + 1
        print(line)
PY
)

    while IFS= read -r eh_line; do
      [[ -z "$eh_line" ]] && continue
      ig_emit_finding "$file" "$eh_line" "EH-01" "async without try/catch" "HIGH"
    done < <(ACP_REVIEW_FILE="$file" python3 - <<'PY' 2>/dev/null || true
import os, re
path = os.environ["ACP_REVIEW_FILE"]
text = open(path, encoding="utf-8", errors="replace").read()
for m in re.finditer(r"async\s+function\s+\w+[^{]*\{", text):
    start = m.end() - 1
    depth = 0
    i = start
    while i < len(text):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                body = text[start + 1 : i]
                if "try" not in body and ".catch(" not in body:
                    line = text[: m.start()].count("\n") + 1
                    print(line)
                break
        i += 1
PY
)
  fi
}

scan_sh() {
  local file="$1"
  # Sourced function libraries deliberately omit set -euo (would leak into callers).
  # F-M82-05: allowlist + honor explicit exemption comment in first 40 lines.
  case "$file" in
    */acp.common.sh|*/acp.yaml-parser.sh|*/acp.integrity-output.sh|*/acp.driver-yaml.sh|*/acp.coderabbit.sh|*/acp.preferences.sh|*/e2e/*)
      return 0
      ;;
  esac
  if head -40 "$file" | grep -qiE 'sourced function library|deliberately does NOT set `set -euo|when sourced'; then
    return 0
  fi
  if ! head -40 "$file" | grep -q 'set -euo pipefail'; then
    ig_emit_finding "$file" "1" "SH-01" "missing set -euo pipefail" "HIGH"
  fi
}

scan_path() {
  local path="$1"
  if [[ -f "$path" ]]; then
    case "$path" in
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) scan_ts_js "$path" ;;
      *.sh) scan_sh "$path" ;;
    esac
    return 0
  fi
  if [[ -d "$path" ]]; then
    while IFS= read -r f; do
      scan_path "$f"
    done < <(find "$path" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.sh' \) \
      ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null || true)
  fi
}

scan_path "$TARGET"
ig_finalize_scan "review-scan"
