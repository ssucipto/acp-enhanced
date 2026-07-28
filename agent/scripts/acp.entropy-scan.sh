#!/usr/bin/env bash
# acp.entropy-scan.sh — Shannon Entropy Calculator for String Literals
# Part of /acp-integrity v1.0 (M56), M64 routes 179/182
#
# Covered rules: IG-17 (entropy), IG-18 (hex/base64 runtime decoding)
# Shared machine mode: --review-sc01 emits SC-01 TSV findings for
# secret-like high-entropy assignments so /acp-review reuses the same
# Shannon entropy calculation instead of copying it.

set -euo pipefail
trap 'echo "Error: entropy-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

DEFAULT_THRESHOLD="4.5"
THRESHOLD="$DEFAULT_THRESHOLD"
TARGET="."
REVIEW_SC01_MODE=false

IG_REMAINING_ARGS=()
ig_parse_common_args "$@"
# Restore positionals only when non-empty: "${arr[@]:-}" injects a single
# empty-string argument for an empty array, which downstream loops treat
# as a scan target (CodeRabbit PR#13 / F-107-01).
if [[ ${#IG_REMAINING_ARGS[@]} -gt 0 ]]; then
  set -- "${IG_REMAINING_ARGS[@]}"
else
  set --
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --review-sc01) REVIEW_SC01_MODE=true; shift ;;
    -h|--help)
      echo "Usage: acp.entropy-scan.sh [--ci] [--json] [--threshold N] [--review-sc01] [file|dir]"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

if ! command -v python3 &>/dev/null; then
  echo "Warning: python3 not found — entropy scan requires Python 3" >&2
  exit 2
fi

run_entropy_python() {
  local file="$1"
  ACP_THRESHOLD="$THRESHOLD" \
  ACP_FILEPATH="$file" \
  ACP_REVIEW_SC01_MODE="$REVIEW_SC01_MODE" \
  python3 - <<'PY'
import math
import os
import re
import sys

threshold = float(os.environ.get("ACP_THRESHOLD", "4.5"))
filepath = os.environ.get("ACP_FILEPATH", "")
review_mode = os.environ.get("ACP_REVIEW_SC01_MODE", "false") == "true"


def shannon_entropy(value: str) -> float:
    if not value:
        return 0.0
    freq: dict[str, int] = {}
    for ch in value:
        freq[ch] = freq.get(ch, 0) + 1
    length = len(value)
    return -sum((count / length) * math.log2(count / length) for count in freq.values())


def emit_review(filepath: str, line_num: int, entropy: float) -> None:
    print(
        f"{filepath}\t{line_num}\tSC-01\t"
        f"high-entropy secret-like assignment (entropy={entropy:.2f})\tCRITICAL"
    )


def emit_integrity(filepath: str, line_num: int, rule: str, message: str) -> None:
    print(f"{filepath}:{line_num}:{rule}:{message}")


try:
    lines = open(filepath, "r", encoding="utf-8", errors="ignore").readlines()
except Exception as exc:
    print(f"Error reading {filepath}: {exc}", file=sys.stderr)
    sys.exit(0)

string_pattern = re.compile(r'(["\'`])(?:(?=(\\?))\2.)*?\1')
secret_context = re.compile(
    r"(?i)\b("
    r"secret|token|credential|password|passphrase|"
    r"api[_-]?key|access[_-]?key|private[_-]?key|"
    r"client[_-]?secret|jwtsecret|databasepassword"
    r")\b"
)
legacy_runtime = re.compile(r"(?:0x[0-9a-fA-F]{16,}|[A-Za-z0-9+/]{40,}={0,2})")
legacy_skip = re.compile(r"^\s*(?:const|let|var|#define|0x[0-9a-fA-F]{1,8}\b)")

for line_num, line in enumerate(lines, 1):
    for match in string_pattern.finditer(line):
        string_literal = match.group(0)
        if len(string_literal) < 20:
            continue
        entropy = shannon_entropy(string_literal)
        if entropy <= threshold:
            continue
        if review_mode:
            if secret_context.search(line):
                emit_review(filepath, line_num, entropy)
        else:
            emit_integrity(
                filepath,
                line_num,
                "IG-17",
                f"entropy={entropy:.2f} high-entropy string literal",
            )
    if not review_mode and legacy_runtime.search(line) and not legacy_skip.search(line):
        emit_integrity(filepath, line_num, "IG-18", "potential hex/base64 runtime decoding")
PY
}

scan_file_entropy() {
  local file="$1"
  local combined
  combined="$(run_entropy_python "$file" 2>&1)"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^([^:]+):([0-9]+):(IG-[0-9]+):(.+)$ ]]; then
      ig_emit_finding "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
    fi
  done <<< "$combined"
}

scan_file_review_sc01() {
  local file="$1"
  run_entropy_python "$file"
}

scan_dir_review_sc01() {
  local target_dir="$1"
  while IFS= read -r file; do
    case "$file" in
      */node_modules/*|*/.git/*|*.png|*.jpg|*.gif|*.min.js) continue ;;
      *.ts|*.tsx|*.js|*.jsx|*.py|*.sh|*.yml|*.yaml|*.md|*.json)
        scan_file_review_sc01 "$file"
        ;;
    esac
  done < <(find "$target_dir" -type f 2>/dev/null || true)
}

if [[ "$REVIEW_SC01_MODE" == "true" ]]; then
  if [[ -f "$TARGET" ]]; then
    scan_file_review_sc01 "$TARGET"
  elif [[ -d "$TARGET" ]]; then
    scan_dir_review_sc01 "$TARGET"
  else
    echo "Error: $TARGET not found" >&2
    exit 2
  fi
  exit 0
fi

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
