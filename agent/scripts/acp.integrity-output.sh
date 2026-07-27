#!/usr/bin/env bash
# acp.integrity-output.sh — Uniform finding output for /acp-integrity scanners (M64 route-182)
# Source from integrity bash scripts; do not execute directly.
#
# Contract: [SEVERITY] file:line ruleID — message
# --ci exits 1 only on CRITICAL or HIGH findings (not MEDIUM/LOW).

# shellcheck disable=SC2034
IG_JSON_MODE="${IG_JSON_MODE:-false}"
IG_CI_MODE="${IG_CI_MODE:-false}"
IG_BASELINE_FILE="${IG_BASELINE_FILE:-}"
IG_WRITE_BASELINE_FILE="${IG_WRITE_BASELINE_FILE:-}"
IG_FINDINGS_TOTAL=0
IG_FINDINGS_CRITICAL=0
IG_FINDINGS_HIGH=0
IG_FINDINGS_MEDIUM=0
IG_FINDINGS_LOW=0
IG_SUPPRESSED_TOTAL=0
IG_SUPPRESSED_BASELINE=0
IG_SUPPRESSED_INLINE=0
IG_JSON_BUFFER=""
IG_BASELINE_BUFFER=""
IG_BASELINE_KEYS=$'\n'
IG_INVALID_SUPPRESSION_KEYS=$'\n'
IG_BASELINE_LOADED=false

ig_parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ci) IG_CI_MODE=true; shift ;;
      --json) IG_JSON_MODE=true; shift ;;
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
      *) break ;;
    esac
  done
  # Return remaining args via global (caller re-parses)
  IG_REMAINING_ARGS=("$@")
}

ig_json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1])[1:-1], end="")' "${1:-}"
}

ig_hash_text() {
  local text="${1:-}"
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$text" | shasum -a 256 | awk '{print $1}'
    return 0
  fi
  python3 - "$text" <<'PY'
import hashlib
import sys

print(hashlib.sha256(sys.argv[1].encode("utf-8")).hexdigest())
PY
}

ig_read_source_line() {
  local file="${1:-}"
  local line="${2:-0}"
  if [[ -z "$file" || "$line" == "0" || ! -f "$file" ]]; then
    return 0
  fi
  awk -v target="$line" 'NR == target { print; exit }' "$file" 2>/dev/null || true
}

ig_normalize_snippet() {
  local snippet="${1:-}"
  printf '%s' "$snippet" | tr '\t\r\n' '   ' | tr -s ' ' | sed 's/^ //; s/ $//'
}

ig_fingerprint_key() {
  local file="${1:-}"
  local line="${2:-0}"
  local rule="${3:-IG-00}"
  local message="${4:-finding}"
  local snippet normalized hash
  snippet="$(ig_read_source_line "$file" "$line")"
  [[ -n "$snippet" ]] || snippet="$message"
  normalized="$(ig_normalize_snippet "$snippet")"
  hash="$(ig_hash_text "$normalized")"
  printf '%s|%s|%s' "$rule" "$file" "$hash"
}

ig_baseline_add_entry() {
  local file="${1:-}"
  local line="${2:-0}"
  local rule="${3:-IG-00}"
  local message="${4:-finding}"
  local severity="${5:-HIGH}"
  local snippet normalized hash
  snippet="$(ig_read_source_line "$file" "$line")"
  [[ -n "$snippet" ]] || snippet="$message"
  normalized="$(ig_normalize_snippet "$snippet")"
  hash="$(ig_hash_text "$normalized")"
  IG_BASELINE_BUFFER+="{\"rule\":\"$(ig_json_escape "$rule")\",\"file\":\"$(ig_json_escape "$file")\",\"line\":${line},\"severity\":\"$(ig_json_escape "$severity")\",\"snippet_hash\":\"${hash}\",\"message\":\"$(ig_json_escape "$message")\"},"
}

ig_load_baseline() {
  if [[ "$IG_BASELINE_LOADED" == "true" || -z "$IG_BASELINE_FILE" ]]; then
    return 0
  fi
  if [[ ! -f "$IG_BASELINE_FILE" ]]; then
    echo "Error: baseline file not found: $IG_BASELINE_FILE" >&2
    exit 2
  fi
  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    IG_BASELINE_KEYS+="${key}"$'\n'
  done < <(python3 - "$IG_BASELINE_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)

entries = data.get("entries", [])
for entry in entries:
    print(f'{entry.get("rule","")}|{entry.get("file","")}|{entry.get("snippet_hash","")}')
PY
)
  IG_BASELINE_LOADED=true
}

ig_baseline_contains() {
  local key="${1:-}"
  case "$IG_BASELINE_KEYS" in
    *$'\n'"${key}"$'\n'*) return 0 ;;
    *) return 1 ;;
  esac
}

ig_invalid_suppression_seen() {
  local key="${1:-}"
  case "$IG_INVALID_SUPPRESSION_KEYS" in
    *$'\n'"${key}"$'\n'*) return 0 ;;
    *) return 1 ;;
  esac
}

ig_inline_suppression_state() {
  local file="${1:-}"
  local line="${2:-0}"
  local rule="${3:-}"
  local candidate candidate_text reason
  for candidate in "$line" "$((line - 1))"; do
    [[ "$candidate" -ge 1 ]] || continue
    candidate_text="$(ig_read_source_line "$file" "$candidate")"
    [[ -n "$candidate_text" ]] || continue
    if [[ "$candidate_text" =~ acp-review-ignore:[[:space:]]*([A-Z0-9-]+)([[:space:]]*[-—][[:space:]]*(.+))?$ ]]; then
      if [[ "${BASH_REMATCH[1]}" != "$rule" ]]; then
        continue
      fi
      reason="${BASH_REMATCH[3]:-}"
      if [[ -n "$reason" ]]; then
        printf 'suppress|%s|%s\n' "$candidate" "$reason"
        return 0
      fi
      printf 'invalid|%s|\n' "$candidate"
      return 0
    fi
  done
  echo "none||"
}

ig_rule_severity() {
  local rule="$1"
  case "$rule" in
    IG-01|IG-02|IG-03|IG-04|IG-07|IG-08|IG-09|IG-13|IG-14|IG-15|IG-16|IG-20|IG-21|IG-22|IG-26|IG-38|IG-39|IG-40|IG-43|IG-45|IG-46|IG-47|IG-51|IG-52|IG-57|IG-58|IG-59|IG-60|IG-61|IG-64|IG-65)
      echo "CRITICAL" ;;
    IG-05|IG-06|IG-10|IG-11|IG-12|IG-17|IG-18|IG-19|IG-23|IG-24|IG-25|IG-27|IG-28|IG-29|IG-33|IG-36|IG-37|IG-41|IG-42|IG-44|IG-48|IG-49|IG-50|IG-62|IG-63|IG-66|IG-67|IG-68|IG-69|IG-70)
      echo "HIGH" ;;
    IG-30|IG-31|IG-32|IG-34|IG-35|IG-55)
      echo "MEDIUM" ;;
    *)
      echo "HIGH" ;;
  esac
}

ig_record_finding() {
  local file="${1:-}"
  local line="${2:-0}"
  local rule="${3:-IG-00}"
  local message="${4:-finding}"
  local severity="${5:-}"

  if [[ -z "$severity" ]]; then
    severity="$(ig_rule_severity "$rule")"
  fi

  IG_FINDINGS_TOTAL=$((IG_FINDINGS_TOTAL + 1))
  case "$severity" in
    CRITICAL) IG_FINDINGS_CRITICAL=$((IG_FINDINGS_CRITICAL + 1)) ;;
    HIGH) IG_FINDINGS_HIGH=$((IG_FINDINGS_HIGH + 1)) ;;
    MEDIUM) IG_FINDINGS_MEDIUM=$((IG_FINDINGS_MEDIUM + 1)) ;;
    LOW) IG_FINDINGS_LOW=$((IG_FINDINGS_LOW + 1)) ;;
  esac

  if [[ "$IG_JSON_MODE" == "true" ]]; then
    IG_JSON_BUFFER+="{\"severity\":\"$(ig_json_escape "$severity")\",\"file\":\"$(ig_json_escape "$file")\",\"line\":${line},\"rule\":\"$(ig_json_escape "$rule")\",\"message\":\"$(ig_json_escape "$message")\"},"
  else
    if [[ -n "$file" && "$line" != "0" ]]; then
      printf '[%s] %s:%s %s — %s\n' "$severity" "$file" "$line" "$rule" "$message"
    elif [[ -n "$file" ]]; then
      printf '[%s] %s %s — %s\n' "$severity" "$file" "$rule" "$message"
    else
      printf '[%s] %s — %s\n' "$severity" "$rule" "$message"
    fi
  fi
}

ig_emit_finding() {
  local file="${1:-}"
  local line="${2:-0}"
  local rule="${3:-IG-00}"
  local message="${4:-finding}"
  local severity="${5:-}"
  local inline_state inline_kind inline_line key invalid_key

  if [[ -z "$severity" ]]; then
    severity="$(ig_rule_severity "$rule")"
  fi

  ig_load_baseline

  if [[ -n "$IG_WRITE_BASELINE_FILE" ]]; then
    ig_baseline_add_entry "$file" "$line" "$rule" "$message" "$severity"
  fi

  if [[ -n "$file" && "$line" != "0" ]]; then
    inline_state="$(ig_inline_suppression_state "$file" "$line" "$rule")"
    inline_kind="${inline_state%%|*}"
    inline_line="$(printf '%s' "$inline_state" | cut -d'|' -f2)"
    case "$inline_kind" in
      suppress)
        IG_SUPPRESSED_TOTAL=$((IG_SUPPRESSED_TOTAL + 1))
        IG_SUPPRESSED_INLINE=$((IG_SUPPRESSED_INLINE + 1))
        return 0
        ;;
      invalid)
        invalid_key="${file}|${inline_line}|${rule}"
        if ! ig_invalid_suppression_seen "$invalid_key"; then
          IG_INVALID_SUPPRESSION_KEYS+="${invalid_key}"$'\n'
          ig_record_finding "$file" "$inline_line" "$rule" "invalid acp-review-ignore for ${rule} - reason required" "LOW"
        fi
        ;;
    esac
  fi

  if [[ -n "$IG_BASELINE_FILE" ]]; then
    key="$(ig_fingerprint_key "$file" "$line" "$rule" "$message")"
    if ig_baseline_contains "$key"; then
      IG_SUPPRESSED_TOTAL=$((IG_SUPPRESSED_TOTAL + 1))
      IG_SUPPRESSED_BASELINE=$((IG_SUPPRESSED_BASELINE + 1))
      return 0
    fi
  fi

  ig_record_finding "$file" "$line" "$rule" "$message" "$severity"
}

ig_print_json_payload() {
  if [[ "$IG_JSON_MODE" != "true" ]]; then
    return 0
  fi

  printf '{\n'
  printf '  "findings": [\n'
  local body="${IG_JSON_BUFFER%,}"
  if [[ -n "$body" ]]; then
    echo "$body" | sed 's/},{/},\n{/g' | sed 's/^/  /'
  fi
  printf '\n  ],\n'
  printf '  "summary": {\n'
  printf '    "active_total": %s,\n' "$IG_FINDINGS_TOTAL"
  printf '    "critical": %s,\n' "$IG_FINDINGS_CRITICAL"
  printf '    "high": %s,\n' "$IG_FINDINGS_HIGH"
  printf '    "medium": %s,\n' "$IG_FINDINGS_MEDIUM"
  printf '    "low": %s,\n' "$IG_FINDINGS_LOW"
  printf '    "suppressed_total": %s,\n' "$IG_SUPPRESSED_TOTAL"
  printf '    "suppressed_baseline": %s,\n' "$IG_SUPPRESSED_BASELINE"
  printf '    "suppressed_inline": %s\n' "$IG_SUPPRESSED_INLINE"
  printf '  }\n'
  printf '}\n'
}

ig_write_baseline_file() {
  if [[ -z "$IG_WRITE_BASELINE_FILE" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$IG_WRITE_BASELINE_FILE")"
  {
    printf '{\n'
    printf '  "format": "acp-baseline-v1",\n'
    printf '  "entries": [\n'
    local body="${IG_BASELINE_BUFFER%,}"
    if [[ -n "$body" ]]; then
      echo "$body" | sed 's/},{/},\n{/g' | sed 's/^/  /'
    fi
    printf '\n  ]\n'
    printf '}\n'
  } > "$IG_WRITE_BASELINE_FILE"
}

ig_finalize_scan() {
  local scanner_name="${1:-integrity-scanner}"

  if [[ "$IG_JSON_MODE" == "true" ]]; then
    ig_print_json_payload
  fi

  ig_write_baseline_file

  if [[ $IG_FINDINGS_TOTAL -gt 0 ]]; then
    echo "" >&2
    echo "Total findings: $IG_FINDINGS_TOTAL ($IG_FINDINGS_CRITICAL CRITICAL, $IG_FINDINGS_HIGH HIGH, $IG_FINDINGS_MEDIUM MEDIUM, $IG_FINDINGS_LOW LOW)" >&2
    if [[ "$IG_CI_MODE" == "true" ]] && [[ $((IG_FINDINGS_CRITICAL + IG_FINDINGS_HIGH)) -gt 0 ]]; then
      exit 1
    fi
  else
    if [[ "$IG_SUPPRESSED_TOTAL" -gt 0 ]]; then
      echo "✓ No active findings from ${scanner_name}" >&2
    else
      echo "✓ No findings from ${scanner_name}" >&2
    fi
  fi

  if [[ "$IG_SUPPRESSED_TOTAL" -gt 0 ]]; then
    echo "Suppressed findings: $IG_SUPPRESSED_TOTAL ($IG_SUPPRESSED_BASELINE baseline, $IG_SUPPRESSED_INLINE inline)" >&2
  fi
  exit 0
}

ig_count_from_marker() {
  local combined="$1"
  local count_line
  count_line=$(echo "$combined" | grep '^ACP_FINDING_COUNT=' | tail -1 || true)
  local count="${count_line#ACP_FINDING_COUNT=}"
  echo "${count:-0}"
}

ig_emit_from_legacy_line() {
  local line="$1"
  local file line_num rule msg severity

  if [[ "$line" =~ ^\[([A-Z]+)\]\ ([^:]+):([0-9]+)\ (IG-[0-9]+)\ —\ (.+)$ ]]; then
    ig_emit_finding "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}" "${BASH_REMATCH[1]}"
    return 0
  fi
  if [[ "$line" =~ ^\[([A-Z]+)\]\ ([^ ]+)\ (IG-[0-9]+)\ —\ (.+)$ ]]; then
    ig_emit_finding "${BASH_REMATCH[2]}" "0" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[1]}"
    return 0
  fi

  if [[ "$line" =~ ^([^:]+):([0-9]+)\ (IG-[0-9]+)\ —\ (.+)$ ]]; then
    file="${BASH_REMATCH[1]}"
    line_num="${BASH_REMATCH[2]}"
    rule="${BASH_REMATCH[3]}"
    msg="${BASH_REMATCH[4]}"
    ig_emit_finding "$file" "$line_num" "$rule" "$msg"
    return 0
  fi

  if [[ "$line" =~ ^([^:]+):([0-9]+)\ entropy= ]]; then
    file="${BASH_REMATCH[1]}"
    line_num="${BASH_REMATCH[2]}"
    ig_emit_finding "$file" "$line_num" "IG-17" "high Shannon entropy string literal"
    return 0
  fi

  if [[ "$line" =~ ^([^:]+):([0-9]+):([0-9]+)\ U\+([0-9A-F]+) ]]; then
    file="${BASH_REMATCH[1]}"
    line_num="${BASH_REMATCH[2]}"
    ig_emit_finding "$file" "$line_num" "IG-14" "hidden Unicode character U+${BASH_REMATCH[4]}"
    return 0
  fi

  if [[ "$line" =~ ^(IG-[0-9]+)\ —\ (.+)$ ]]; then
    ig_emit_finding "" "0" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    return 0
  fi

  return 1
}
