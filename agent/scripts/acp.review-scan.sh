#!/usr/bin/env bash
# acp.review-scan.sh — Deterministic Phase 1 scanner for /acp-review (audit-085 F-085-07, M70 task-225)
#
# Covered rules: EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01
# Optional local analyzers: SH-03 via shellcheck, SC-01 via gitleaks,
# CH-05 via dupehound (ADR-23 / Variant B helpers).
# Usage: acp.review-scan.sh [--ci] [--json] [--baseline file] [--write-baseline file] [--self] [--include-tests] [file|dir ...]
# M83 task-280: accumulate all paths (F-102-01); implement --self (F-102-02);
# include .mjs/.cjs in directory find (F-102-03); re-handle flags after positionals (F-104-06).

set -euo pipefail
trap 'echo "Error: review-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"
# shellcheck source=acp.gitleaks.sh
source "${SCRIPT_DIR}/acp.gitleaks.sh"
# shellcheck source=acp.dupehound.sh
source "${SCRIPT_DIR}/acp.dupehound.sh"

TARGETS=()
SELF_MODE=false
INCLUDE_TESTS=false
IG_REMAINING_ARGS=()
REVIEW_FINDING_KEYS=$'\n'
SCANNED_FILES=()
DUPEHOUND_ANNOUNCED=false
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
IG_PREFS_ROOT="${IG_PREFS_ROOT:-$PROJECT_ROOT}"

emit_review_finding() {
  local file="$1"
  local line="${2:-0}"
  local rule="$3"
  local message="$4"
  local severity="${5:-}"
  local key="${file}:${line}:${rule}"
  case "${REVIEW_FINDING_KEYS}" in
    *$'\n'"${key}"$'\n'*)
      return 0
      ;;
  esac
  REVIEW_FINDING_KEYS+="${key}"$'\n'
  ig_emit_finding "$file" "$line" "$rule" "$message" "$severity"
}

review_rg_file() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$file"
  else
    grep -qE "$pattern" "$file"
  fi
}

review_rg_dir() {
  local pattern="$1"
  local dir="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$dir"
  else
    grep -RqE "$pattern" "$dir" 2>/dev/null
  fi
}

normalize_repo_path() {
  local path="$1"
  if [[ "$path" == "${REPO_ROOT}/"* ]]; then
    path="${path#"${REPO_ROOT}/"}"
  elif [[ "$path" == ./* ]]; then
    path="${path#./}"
  fi
  echo "$path"
}

remember_scanned_file() {
  local path="$1"
  SCANNED_FILES+=("$(normalize_repo_path "$path")")
}

is_scanned_file() {
  local path candidate
  path="$(normalize_repo_path "$1")"
  for candidate in "${SCANNED_FILES[@]}"; do
    if [[ "$candidate" == "$path" ]]; then
      return 0
    fi
  done
  return 1
}

announce_dupehound_activation() {
  if [[ "$DUPEHOUND_ANNOUNCED" != "true" ]]; then
    echo "[ACP] CH-05 duplicate detection active via dupehound; disable with integrations.dupehound.enabled: false." >&2
    DUPEHOUND_ANNOUNCED=true
  fi
}

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
    -h|--help)
      echo "Usage: acp.review-scan.sh [--ci] [--json] [--baseline file] [--write-baseline file] [--self] [--include-tests] [file|dir ...]"
      exit 0
      ;;
    --self)
      SELF_MODE=true
      shift
      ;;
    --include-tests)
      INCLUDE_TESTS=true
      shift
      ;;
    # F-104-06: ig_parse_common_args stops at first positional; flags after paths
    # must be re-handled here so they are never appended as scan targets.
    --ci)
      IG_CI_MODE=true
      shift
      ;;
    --json)
      IG_JSON_MODE=true
      shift
      ;;
    --baseline)
      [[ $# -ge 2 ]] || { echo "Error: --baseline requires a file path" >&2; exit 2; }
      IG_BASELINE_FILE="$2"
      shift 2
      ;;
    --write-baseline)
      [[ $# -ge 2 ]] || { echo "Error: --write-baseline requires a file path" >&2; exit 2; }
      IG_WRITE_BASELINE_FILE="$2"
      shift 2
      ;;
    -*)
      echo "Error: unexpected flag: $1" >&2
      exit 2
      ;;
    *)
      TARGETS+=("$1")
      shift
      ;;
  esac
done

if [[ "$SELF_MODE" == "true" ]]; then
  # Documented at acp.review.md — skip missing directories silently (F-102-02)
  for _self_path in scripts/ agent/scripts/ agent/commands/ e2e/; do
    if [[ -d "$_self_path" ]]; then
      TARGETS+=("$_self_path")
    fi
  done
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  if [[ "$SELF_MODE" == "true" ]]; then
    # All --self paths missing — nothing to scan; clean exit
    ig_finalize_scan "review-scan"
  fi
  TARGETS=(".")
fi

for _t in "${TARGETS[@]}"; do
  if [[ ! -e "$_t" ]]; then
    echo "Error: $_t not found" >&2
    exit 2
  fi
done

scan_ts_js() {
  local file="$1"

  # M83 task-282: neutralize comments/strings before non-secret rules (F-103-01);
  # SC-01 still runs on comment-stripped-only text so string secrets remain visible;
  # EH-01 uses token-boundary \btry\b / \.catch\s*\( (F-103-02).
  if ! command -v python3 &>/dev/null; then
    echo "Warning: python3 required for TS/JS review-scan rules; skipping $file" >&2
    return 0
  fi

  while IFS=$'\t' read -r line_num rule message severity || [[ -n "${line_num:-}" ]]; do
    [[ -z "${line_num:-}" ]] && continue
    emit_review_finding "$file" "$line_num" "$rule" "$message" "$severity"
  done < <(ACP_REVIEW_FILE="$file" python3 "${SCRIPT_DIR}/acp.review-scan-ts.py" 2>/dev/null || true)

  while IFS=$'\t' read -r out_file line_num rule message severity || [[ -n "${out_file:-}" ]]; do
    [[ -z "${out_file:-}" ]] && continue
    emit_review_finding "$out_file" "$line_num" "$rule" "$message" "$severity"
  done < <(bash "${SCRIPT_DIR}/acp.entropy-scan.sh" --review-sc01 --threshold 4.2 "$file" 2>/dev/null || true)
}

node_scan_modules_available() {
  command -v node >/dev/null 2>&1 && [[ -d "${PROJECT_ROOT}/scripts/node_modules" ]]
}

# YM-01/YM-02 need js-yaml + gray-matter from scripts/node_modules. When those
# are absent the rules skip, which silently lowers corpus recall (95.7% instead
# of 100%) with no indication why — a clean-looking run that is not clean.
# Warn once so a degraded scan is never mistaken for a passing one (audit-108).
YAML_RULES_SKIP_ANNOUNCED=false
announce_yaml_rules_skipped() {
  if [[ "$YAML_RULES_SKIP_ANNOUNCED" != "true" ]]; then
    echo "[ACP] YM-01/YM-02 skipped: scripts/node_modules missing (run: cd scripts && npm install --ignore-scripts). Recall is understated." >&2
    YAML_RULES_SKIP_ANNOUNCED=true
  fi
}

scan_yaml_with_node() {
  local file="$1"
  local abs_file="$file"
  local rule="$2"
  local mode="$3"
  local message="$4"
  local output=""
  local line_num="1"

  if ! node_scan_modules_available; then
    announce_yaml_rules_skipped
    return 0
  fi

  if [[ "$abs_file" != /* ]]; then
    abs_file="${PROJECT_ROOT}/${abs_file#./}"
  fi

  if output="$(cd "${PROJECT_ROOT}/scripts" && node --input-type=module - "$mode" "$abs_file" 2>&1 <<'NODE'
import fs from "fs";
import matter from "gray-matter";
import yaml from "js-yaml";

const mode = process.argv[2];
const file = process.argv[3];
const raw = fs.readFileSync(file, "utf8");

if (mode === "frontmatter") {
  if (!raw.startsWith("---\n")) {
    process.exit(0);
  }
  matter(raw);
} else {
  yaml.load(raw);
}
NODE
)"; then
    return 0
  fi

  if [[ "$output" =~ line[[:space:]]+([0-9]+) ]]; then
    line_num="${BASH_REMATCH[1]}"
  fi
  emit_review_finding "$file" "$line_num" "$rule" "$message" "$(ig_rule_severity "$rule")"
}

scan_markdown_frontmatter() {
  local file="$1"
  scan_yaml_with_node "$file" "YM-02" "frontmatter" "markdown frontmatter does not parse as YAML"
}

scan_yaml_file() {
  local file="$1"
  scan_yaml_with_node "$file" "YM-01" "yaml" "YAML file does not parse"
}

scan_shell_portability() {
  local file="$1"
  local has_guard=false
  local line_num=0
  local line=""

  if review_rg_file 'Darwin|uname -s' "$file" && review_rg_file "sed -i ''" "$file" && review_rg_file 'sed -i( |")' "$file"; then
    has_guard=true
  fi

  while IFS= read -r line; do
    line_num=$((line_num + 1))
    [[ "$line" == *"sed -i"* ]] || continue
    [[ "$line" == *"sed -i.bak"* ]] && continue
    if [[ "$has_guard" == "true" ]]; then
      continue
    fi
    emit_review_finding "$file" "$line_num" "SH-02" "sed -i usage is not BSD/GNU guard-aware" "HIGH"
  done < "$file"
}

scan_shell_exit_trap() {
  local file="$1"
  local line_num=0
  local line=""
  local trap_line=""

  if ! is_sh_allowlisted "$file"; then
    return 0
  fi
  if review_rg_file 'trap - EXIT' "$file"; then
    return 0
  fi

  while IFS= read -r line; do
    line_num=$((line_num + 1))
    if [[ "$line" == *"trap"* && "$line" == *" EXIT"* ]]; then
      trap_line="$line_num"
      break
    fi
  done < "$file"

  if [[ -n "$trap_line" ]]; then
    emit_review_finding "$file" "$trap_line" "SH-04" "sourced library sets EXIT trap without clearing it" "CRITICAL"
  fi
}

scan_shell_naming() {
  local file="$1"
  local base
  base="$(basename "$file")"
  case "$file" in
    */agent/scripts/*.sh|*/scripts/*.sh)
      if [[ ! "$base" =~ ^acp\.[A-Za-z0-9-]+\.sh$ ]]; then
        emit_review_finding "$file" "1" "ACP-03" "script name should follow acp.{name}.sh" "LOW"
      fi
      ;;
  esac
}

scan_command_directive() {
  local file="$1"
  case "$file" in
    */agent/commands/*.md|*/commands/*.md)
      if [[ "$(basename "$file")" != "command.template.md" ]] && ! review_rg_file 'Agent Directive' "$file"; then
        emit_review_finding "$file" "1" "ACP-01" "command doc missing Agent Directive header" "MEDIUM"
      fi
      ;;
  esac
}

scan_tsconfig_rules() {
  local file="$1"
  if ! command -v python3 >/dev/null 2>&1; then
    return 0
  fi
  while IFS=$'\t' read -r line_num rule message severity || [[ -n "${line_num:-}" ]]; do
    [[ -z "${line_num:-}" ]] && continue
    emit_review_finding "$file" "$line_num" "$rule" "$message" "$severity"
  done < <(python3 - "$file" <<'PY'
import json
import sys
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    raise SystemExit(0)
opts = data.get("compilerOptions") or {}
if not opts.get("strictNullChecks"):
    print("1\tTS-08\tstrictNullChecks is disabled or missing\tHIGH")
missing = []
for key in ("noUncheckedIndexedAccess", "exactOptionalPropertyTypes"):
    if not opts.get(key):
        missing.append(key)
if missing:
    print(f"1\tTS-13\tmissing compiler options: {', '.join(missing)}\tMEDIUM")
PY
)
}

scan_package_security_rules() {
  local dir="$1"
  local package_file="${dir%/}/package.json"
  local audit_file="${dir%/}/npm-audit.json"
  local tracked_lockfile=""

  [[ -f "$package_file" ]] || return 0

  if [[ -f "$audit_file" ]] && command -v python3 >/dev/null 2>&1; then
    while IFS=$'\t' read -r file line_num rule message severity || [[ -n "${file:-}" ]]; do
      [[ -z "${file:-}" ]] && continue
      emit_review_finding "$file" "$line_num" "$rule" "$message" "$severity"
    done < <(python3 - "$audit_file" <<'PY'
import json
import sys
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    raise SystemExit(0)
meta = data.get("metadata", {}).get("vulnerabilities", {})
high = int(meta.get("high", 0) or 0)
critical = int(meta.get("critical", 0) or 0)
if high > 0 or critical > 0:
    package_file = path.rsplit("/", 1)[0] + "/package.json"
    print(f"{package_file}\t1\tSC-14\tnpm audit reports {high} high / {critical} critical vulnerabilities\tHIGH")
PY
)
  elif [[ -f "${dir%/}/package-lock.json" ]] && command -v npm >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
    local audit_output=""
    audit_output="$(cd "$dir" && npm audit --json 2>/dev/null || true)"
    if [[ -n "$audit_output" ]]; then
      while IFS=$'\t' read -r file line_num rule message severity || [[ -n "${file:-}" ]]; do
        [[ -z "${file:-}" ]] && continue
        emit_review_finding "$file" "$line_num" "$rule" "$message" "$severity"
      done < <(python3 - "$package_file" "$audit_output" <<'PY'
import json
import sys
path = sys.argv[1]
raw = sys.argv[2]
try:
    data = json.loads(raw)
except Exception:
    raise SystemExit(0)
meta = data.get("metadata", {}).get("vulnerabilities", {})
high = int(meta.get("high", 0) or 0)
critical = int(meta.get("critical", 0) or 0)
if high > 0 or critical > 0:
    print(f"{path}\t1\tSC-14\tnpm audit reports {high} high / {critical} critical vulnerabilities\tHIGH")
PY
)
    fi
  fi

  # SC-15 — a lockfile must exist AND be tracked in git for `npm ci` to be
  # reproducible. The previous implementation built two ad-hoc path variants and
  # then returned 0 on both branches, so the tracking half was dead code: an
  # untracked lockfile passed silently. Normalising to one repo-relative path
  # and running git from the repo root makes the check work regardless of the
  # caller's cwd or whether "$dir" was given as absolute or relative
  # (CodeRabbit PR#13 / F-107-02).
  local lock_path="" lock_dir="" lock_repo="" rel_lock=""
  for tracked_lockfile in package-lock.json npm-shrinkwrap.json yarn.lock pnpm-lock.yaml; do
    lock_path="${dir%/}/${tracked_lockfile}"
    if [[ -f "$lock_path" ]]; then
      lock_dir="$(cd "$(dirname "$lock_path")" && pwd)"
      # Resolve the repo root from the lockfile's own directory rather than the
      # script-level REPO_ROOT, which is derived from the caller's cwd and is
      # therefore wrong whenever an absolute path outside that repo is scanned.
      lock_repo="$(git -C "$lock_dir" rev-parse --show-toplevel 2>/dev/null || true)"
      if [[ -z "$lock_repo" ]]; then
        # Not inside a git work tree — tracking is unknowable, so assert nothing.
        return 0
      fi
      rel_lock="${lock_dir#"${lock_repo}"/}/${tracked_lockfile}"
      [[ "$lock_dir" == "$lock_repo" ]] && rel_lock="$tracked_lockfile"
      if ! git -C "$lock_repo" ls-files --error-unmatch "$rel_lock" >/dev/null 2>&1; then
        # Untracked, but distinguish deliberate from accidental. acp.review.md
        # SC-15 explicitly permits gitignored lockfiles in framework/protocol
        # projects where they are development-only (M55 G-001), so an ignored
        # lockfile is a documented choice, not a finding. An untracked lockfile
        # that is NOT ignored is an accident and breaks `npm ci` reproducibility.
        if ! git -C "$lock_repo" check-ignore -q "$rel_lock" 2>/dev/null; then
          emit_review_finding "$package_file" "1" "SC-15" \
            "lockfile ${tracked_lockfile} exists but is not tracked in git" "HIGH"
        fi
      fi
      return 0
    fi
  done
  emit_review_finding "$package_file" "1" "SC-15" "package manager lockfile is missing" "HIGH"
}

scan_unhandled_rejection_rule() {
  local dir="$1"
  local package_file="${dir%/}/package.json"
  [[ -f "$package_file" ]] || return 0
  if ! review_rg_dir 'express|app\.listen|res\.json|router\.|useState\(|useEffect\(' "$dir"; then
    return 0
  fi
  if review_rg_dir "process\\.on\\(['\"]unhandledRejection['\"]" "$dir"; then
    return 0
  fi
  emit_review_finding "$package_file" "1" "EH-09" "project lacks a global unhandledRejection handler" "HIGH"
}

is_sh_allowlisted() {
  local file="$1"
  case "$file" in
    */acp.common.sh|*/acp.yaml-parser.sh|*/acp.integrity-output.sh|*/acp.driver-yaml.sh|*/acp.coderabbit.sh|*/acp.preferences.sh|*/e2e/*)
      return 0
      ;;
  esac
  if head -40 "$file" | grep -qiE 'sourced function library|deliberately does NOT set `set -euo|when sourced'; then
    return 0
  fi
  return 1
}

shellcheck_available() {
  command -v shellcheck >/dev/null 2>&1
}

scan_sh_shellcheck() {
  local file="$1"
  local min_severity="$2"
  local line=""
  local line_num=""
  local code=""
  local message=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^([^:]+):([0-9]+):[0-9]+:\ (.+)\ \[(SC[0-9]+)\]$ ]]; then
      line_num="${BASH_REMATCH[2]}"
      message="${BASH_REMATCH[3]}"
      code="${BASH_REMATCH[4]}"
      case "$code" in
        SC2046|SC2068|SC2086)
          emit_review_finding "$file" "$line_num" "SH-03" "shellcheck ${code}: ${message}" "MEDIUM"
          ;;
      esac
    fi
  done < <(shellcheck -f gcc -S "$min_severity" "$file" 2>/dev/null || true)
}

scan_sh() {
  local file="$1"
  local allowlisted=false
  # Sourced function libraries deliberately omit set -euo (would leak into callers).
  # F-M82-05: allowlist + honor explicit exemption comment in first 40 lines.
  if is_sh_allowlisted "$file"; then
    allowlisted=true
  fi
  if [[ "$allowlisted" != "true" ]] && ! head -40 "$file" | grep -q 'set -euo pipefail'; then
    emit_review_finding "$file" "1" "SH-01" "missing set -euo pipefail" "HIGH"
  fi
  if [[ "$allowlisted" != "true" ]] && shellcheck_available; then
    scan_sh_shellcheck "$file" "warning"
    # SC2086/SC2046/SC2068 are note-level quote-safety findings; promote only these.
    scan_sh_shellcheck "$file" "style"
  fi
  scan_shell_portability "$file"
  scan_shell_exit_trap "$file"
  scan_shell_naming "$file"
}

scan_md() {
  local file="$1"
  scan_command_directive "$file"
  scan_markdown_frontmatter "$file"
}

scan_dir_level_rules() {
  local dir="$1"
  local tsconfig_file=""

  scan_package_security_rules "$dir"
  scan_unhandled_rejection_rule "$dir"

  while IFS= read -r tsconfig_file; do
    scan_tsconfig_rules "$tsconfig_file"
  done < <(find "$dir" -maxdepth 2 -type f -name 'tsconfig*.json' 2>/dev/null || true)
}

should_skip_path() {
  local path="$1"
  case "$path" in
    node_modules/*|*/node_modules/*|.git/*|*/.git/*)
      return 0
      ;;
  esac
  if [[ "$INCLUDE_TESTS" != "true" ]]; then
    case "$path" in
      *test*|*spec*|*fixture*|*__mocks__*|*.generated.*|*.min.js)
        return 0
        ;;
    esac
  fi
  return 1
}

scan_gitleaks_file() {
  local file="$1"
  local report_path rc=0
  if [[ "$INCLUDE_TESTS" == "true" ]] || ([[ "$INCLUDE_TESTS" != "true" ]] && should_skip_path "$file"); then
    return 0
  fi
  if ! gitleaks_active; then
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Warning: python3 required to parse gitleaks JSON; skipping $file" >&2
    return 0
  fi
  report_path="$(mktemp)"
  gitleaks dir "$file" --no-banner --report-format json --report-path "$report_path" >/dev/null 2>&1 || rc=$?
  case "$rc" in
    0|1) ;;
    *)
      rm -f "$report_path"
      return 0
      ;;
  esac
  while IFS=$'\t' read -r out_file line_num rule message severity || [[ -n "${out_file:-}" ]]; do
    [[ -z "${out_file:-}" ]] && continue
    emit_review_finding "${out_file:-$file}" "${line_num:-1}" "$rule" "$message" "$severity"
  done < <(python3 - "$report_path" <<'PY'
import json
import sys

path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    raise SystemExit(0)

items = data.get("findings") if isinstance(data, dict) else data
if items is None:
    items = []

for item in items:
    if not isinstance(item, dict):
        continue
    file = item.get("File") or item.get("file") or item.get("Path") or ""
    line = item.get("StartLine") or item.get("line") or item.get("Line") or 1
    rule_id = item.get("RuleID") or item.get("rule") or "gitleaks"
    desc = item.get("Description") or item.get("Message") or "hardcoded secret pattern"
    print(f"{file}\t{line}\tSC-01\tgitleaks {rule_id}: {desc}\tCRITICAL")
PY
)
  rm -f "$report_path"
}

scan_dupehound() {
  local report_path
  if [[ ${#SCANNED_FILES[@]} -eq 0 ]]; then
    return 0
  fi
  if [[ "$INCLUDE_TESTS" == "true" ]]; then
    return 0
  fi
  if ! dupehound_active; then
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Warning: python3 required to parse dupehound JSON; skipping CH-05" >&2
    return 0
  fi
  announce_dupehound_activation
  report_path="$(mktemp)"
  if ! dupehound_write_json "$report_path"; then
    rm -f "$report_path"
    return 0
  fi
  while IFS=$'\t' read -r out_file line_num rule message severity || [[ -n "${out_file:-}" ]]; do
    [[ -z "${out_file:-}" ]] && continue
    if is_scanned_file "$out_file"; then
      emit_review_finding "$out_file" "${line_num:-1}" "$rule" "$message" "$severity"
    fi
  done < <(python3 - "$report_path" <<'PY'
import json
import sys

path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    raise SystemExit(0)

items = data.get("findings") if isinstance(data, dict) else data
if items is None:
    items = []

for item in items:
    if not isinstance(item, dict):
        continue
    file = item.get("file") or item.get("path") or item.get("File") or ""
    line = item.get("line") or item.get("Line") or item.get("start_line") or 1
    similarity = item.get("similarity") or item.get("Similarity") or "?"
    original = item.get("original") or item.get("source") or {}
    if isinstance(original, dict):
      origin_file = original.get("file") or original.get("path") or original.get("File") or "existing code"
      origin_line = original.get("line") or original.get("Line") or original.get("start_line") or 1
      origin_ref = f"{origin_file}:{origin_line}"
    else:
      origin_ref = str(original or "existing code")
    suggestion = item.get("suggestion") or item.get("Suggestion") or ""
    message = f"duplicate code cluster ({similarity}% similar) — reuse {origin_ref}"
    if suggestion:
      message += f"; suggestion: {suggestion}"
    print(f"{file}\t{line}\tCH-05\t{message}\tMEDIUM")
PY
)
  rm -f "$report_path"
}

scan_path() {
  local path="$1"
  if should_skip_path "$path"; then
    return 0
  fi
  if [[ -f "$path" ]]; then
    remember_scanned_file "$path"
    case "$path" in
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) scan_ts_js "$path" ;;
      *.sh) scan_sh "$path" ;;
      *.md) scan_md "$path" ;;
      *.yaml|*.yml) scan_yaml_file "$path" ;;
      */package.json|package.json)
        scan_package_security_rules "$(dirname "$path")"
        scan_unhandled_rejection_rule "$(dirname "$path")"
        ;;
      */tsconfig*.json|tsconfig*.json) scan_tsconfig_rules "$path" ;;
    esac
    scan_gitleaks_file "$path"
    return 0
  fi
  if [[ -d "$path" ]]; then
    scan_dir_level_rules "$path"
    while IFS= read -r f; do
      scan_path "$f"
    done < <(find "$path" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.mjs' -o -name '*.cjs' -o -name '*.sh' -o -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name 'tsconfig*.json' -o -name 'package.json' \) \
      ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null || true)
  fi
}

for _t in "${TARGETS[@]}"; do
  scan_path "$_t"
done

scan_dupehound
ig_finalize_scan "review-scan"
