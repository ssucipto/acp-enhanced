#!/usr/bin/env bash
# acp.integrity-output.sh — Uniform finding output for /acp-integrity scanners (M64 route-182)
# Source from integrity bash scripts; do not execute directly.
#
# Contract: [SEVERITY] file:line ruleID — message
# --ci exits 1 only on CRITICAL or HIGH findings (not MEDIUM/LOW).

# shellcheck disable=SC2034
IG_JSON_MODE="${IG_JSON_MODE:-false}"
IG_CI_MODE="${IG_CI_MODE:-false}"
IG_FINDINGS_TOTAL=0
IG_FINDINGS_CRITICAL=0
IG_FINDINGS_HIGH=0
IG_FINDINGS_MEDIUM=0
IG_FINDINGS_LOW=0
IG_JSON_BUFFER=""

ig_parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ci) IG_CI_MODE=true; shift ;;
      --json) IG_JSON_MODE=true; shift ;;
      *) break ;;
    esac
  done
  # Return remaining args via global (caller re-parses)
  IG_REMAINING_ARGS=("$@")
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

ig_emit_finding() {
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
    local escaped_msg
    escaped_msg=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')
    IG_JSON_BUFFER+="{\"severity\":\"${severity}\",\"file\":\"${file}\",\"line\":${line},\"rule\":\"${rule}\",\"message\":\"${escaped_msg}\"},"
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

ig_print_json_findings() {
  if [[ "$IG_JSON_MODE" != "true" ]]; then
    return 0
  fi
  printf '[\n'
  local body="${IG_JSON_BUFFER%,}"
  if [[ -n "$body" ]]; then
    echo "$body" | sed 's/},{/},\n{/g' | sed 's/^/  /'
  fi
  printf '\n]\n'
}

ig_finalize_scan() {
  local scanner_name="${1:-integrity-scanner}"

  if [[ "$IG_JSON_MODE" == "true" ]]; then
    ig_print_json_findings
  fi

  if [[ $IG_FINDINGS_TOTAL -gt 0 ]]; then
    echo "" >&2
    echo "Total findings: $IG_FINDINGS_TOTAL ($IG_FINDINGS_CRITICAL CRITICAL, $IG_FINDINGS_HIGH HIGH, $IG_FINDINGS_MEDIUM MEDIUM, $IG_FINDINGS_LOW LOW)" >&2
    if [[ "$IG_CI_MODE" == "true" ]] && [[ $((IG_FINDINGS_CRITICAL + IG_FINDINGS_HIGH)) -gt 0 ]]; then
      exit 1
    fi
  else
    echo "✓ No findings from ${scanner_name}" >&2
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
