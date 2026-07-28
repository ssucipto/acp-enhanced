#!/usr/bin/env bash
# acp.network-whitelist-validate.sh — Outbound Network Call Validator
# Part of /acp-integrity v1.0 (M56), M64 routes 182/183
#
# Covered rules: IG-01, IG-02, IG-03, IG-05, IG-06

set -euo pipefail
trap 'echo "Error: network-whitelist-validate.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WHITELIST_FILE="${PROJECT_ROOT}/agent/core/network_whitelist.yml"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"
source "${SCRIPT_DIR}/acp.yaml-parser.sh"

TARGET="."
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
    -h|--help)
      echo "Usage: acp.network-whitelist-validate.sh [--ci] [--json] [file|dir]"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

WHITELISTED_DOMAINS=()
if [[ -f "$WHITELIST_FILE" ]]; then
  host_count=$(yaml_get_array "$WHITELIST_FILE" "approved_hosts" 2>/dev/null || echo "0")
  if [[ "$host_count" =~ ^[0-9]+$ ]] && [[ "$host_count" -gt 0 ]]; then
    for ((i = 0; i < host_count; i++)); do
      host=$(yaml_get_nested "$WHITELIST_FILE" "approved_hosts[${i}]" 2>/dev/null || true)
      host="${host//$'\r'/}"
      host="${host//\"/}"
      host="${host//\'/}"
      [[ -n "$host" ]] && WHITELISTED_DOMAINS+=("$host")
    done
  fi
else
  echo "Warning: $WHITELIST_FILE not found — all outbound calls flagged" >&2
fi

is_whitelisted() {
  local domain="$1"
  local wd pattern suffix
  for wd in "${WHITELISTED_DOMAINS[@]}"; do
    if [[ "$wd" == *"*"* ]]; then
      suffix="${wd#\*}"
      suffix="${suffix//./\\.}"
      pattern=".*${suffix}"
      if echo "$domain" | grep -qE "^${pattern}$" 2>/dev/null; then
        return 0
      fi
    elif [[ "$domain" == "$wd" ]]; then
      return 0
    fi
  done
  return 1
}

scan_file() {
  local file="$1"
  local line_num=0
  local prev_line=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    local urls
    urls=$(echo "$line" | grep -oE "(https?://[a-zA-Z0-9.-]+)" 2>/dev/null || true)

    if [[ -n "$urls" ]]; then
      while IFS= read -r url; do
        [[ -z "$url" ]] && continue
        local domain
        domain=$(echo "$url" | sed -E 's|^https?://||' | awk -F/ '{print $1}')
        if echo "$domain" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' 2>/dev/null; then
          ig_emit_finding "$file" "$line_num" "IG-02" "raw IP address: $url"
          continue
        fi
        if ! is_whitelisted "$domain"; then
          ig_emit_finding "$file" "$line_num" "IG-01" "non-whitelisted domain: $domain"
        fi
      done <<< "$urls"
    fi

    if echo "$line" | grep -qiE '(atob|btoa|Buffer.*base64).*fetch|fetch.*(atob|btoa|Buffer.*base64)' 2>/dev/null; then
      ig_emit_finding "$file" "$line_num" "IG-03" "base64-decoded string in network call"
    fi

    if echo "$line" | grep -qE '(fetch|axios|http\.request|WebSocket|XMLHttpRequest)' 2>/dev/null; then
      if echo "$prev_line" | grep -qE 'catch\s*\(' 2>/dev/null; then
        ig_emit_finding "$file" "$line_num" "IG-06" "outbound call after catch block (exfil-on-error)"
      fi
    fi

    if echo "$line" | grep -qiE 'dns\.(resolve|lookup).*process\.env' 2>/dev/null; then
      ig_emit_finding "$file" "$line_num" "IG-05" "DNS lookup from environment variable"
    fi

    prev_line="$line"
  done < "$file"
}

if [[ -f "$TARGET" ]]; then
  scan_file "$TARGET"
elif [[ -d "$TARGET" ]]; then
  while IFS= read -r file; do
    case "$file" in
      */node_modules/*|*/.git/*|*.min.js) continue ;;
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) scan_file "$file" ;;
    esac
  done < <(find "$TARGET" -type f 2>/dev/null || true)
else
  echo "Error: $TARGET not found" >&2
  exit 2
fi

ig_finalize_scan "network-whitelist-validate"
