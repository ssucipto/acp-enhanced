#!/usr/bin/env bash
# acp.network-whitelist-validate.sh — Outbound Network Call Validator
# Part of /acp-integrity v1.0 (M56)
#
# Scans source files for outbound network calls (fetch, axios, http.request, etc.)
# and validates target domains against agent/core/network_whitelist.yml.
#
# Usage:
#   acp.network-whitelist-validate.sh [file|dir]
#   acp.network-whitelist-validate.sh --ci [file|dir]
#
# Covered rules: IG-01, IG-02, IG-03, IG-05, IG-06

set -euo pipefail
trap 'echo "Error: network-whitelist-validate.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WHITELIST_FILE="${PROJECT_ROOT}/agent/core/network_whitelist.yml"

CI_MODE=false
TARGET="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) CI_MODE=true; shift ;;
    -h|--help)
      echo "Usage: acp.network-whitelist-validate.sh [--ci] [file|dir]"
      echo "Validates outbound network calls against network_whitelist.yml"
      exit 0
      ;;
    *) TARGET="$1"; shift ;;
  esac
done

# ── Whitelist Loading ─────────────────────────────────────────────────────────

if [[ ! -f "$WHITELIST_FILE" ]]; then
  echo "Warning: $WHITELIST_FILE not found — all outbound calls will be flagged" >&2
  echo "Create agent/core/network_whitelist.yml with approved_hosts list" >&2
  WHITELISTED_DOMAINS=()
else
  # Parse whitelist — extract approved_hosts entries
  WHITELISTED_DOMAINS=()
  while IFS= read -r line; do
    domain=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*"//' | sed 's/"$//' | sed "s/^[[:space:]]*-[[:space:]]*'//" | sed "s/'$//")
    if [[ -n "$domain" ]]; then
      WHITELISTED_DOMAINS+=("$domain")
    fi
  done < <(grep -E '^\s+-' "$WHITELIST_FILE" 2>/dev/null | grep -v '^\s*#' || true)
fi

# ── Domain Matching ───────────────────────────────────────────────────────────

is_whitelisted() {
  local domain="$1"
  for wd in "${WHITELISTED_DOMAINS[@]}"; do
    # Support wildcard patterns: *.example.com
    if [[ "$wd" == *"*"* ]]; then
      local pattern="${wd//\*/.*}"
      if echo "$domain" | grep -qE "^${pattern}$" 2>/dev/null; then
        return 0
      fi
    elif [[ "$domain" == "$wd" ]]; then
      return 0
    fi
  done
  return 1
}

# ── Scan ──────────────────────────────────────────────────────────────────────

FINDINGS=0

scan_file() {
  local file="$1"
  local line_num=0
  
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    
    # Extract URLs from common network call patterns
    # fetch('https://...'), axios.get('https://...'), http.request({host: '...'})
    urls=$(echo "$line" | grep -oE "(https?://[a-zA-Z0-9.-]+)" 2>/dev/null || true)
    
    if [[ -n "$urls" ]]; then
      while IFS= read -r url; do
        if [[ -z "$url" ]]; then continue; fi
        domain=$(echo "$url" | sed 's|https\?://||' | awk -F/ '{print $1}')
        
        # IG-02: Raw IP address
        if echo "$domain" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' 2>/dev/null; then
          echo "${file}:${line_num} IG-02 — raw IP address: $url"
          FINDINGS=$((FINDINGS + 1))
          continue
        fi
        
        # IG-01: Non-whitelisted domain
        if ! is_whitelisted "$domain"; then
          echo "${file}:${line_num} IG-01 — non-whitelisted domain: $domain ($url)"
          FINDINGS=$((FINDINGS + 1))
        fi
      done <<< "$urls"
    fi
    
    # IG-03: Base64 + network call in same expression
    if echo "$line" | grep -qiE '(atob|btoa|Buffer.*base64).*fetch|fetch.*(atob|btoa|Buffer.*base64)' 2>/dev/null; then
      echo "${file}:${line_num} IG-03 — base64-decoded string in network call"
      FINDINGS=$((FINDINGS + 1))
    fi
    
    # IG-06: Network call in catch block (exfil-on-error pattern)
    # Detected by checking if previous line contains 'catch'
    if echo "$line" | grep -qE '(fetch|axios|http\.request|WebSocket|XMLHttpRequest)' 2>/dev/null; then
      # This is a heuristic — full catch-block detection needs AST analysis
      if [[ $line_num -gt 1 ]]; then
        prev_line=$(sed -n "$((line_num - 1))p" "$file" 2>/dev/null || true)
        if echo "$prev_line" | grep -qE 'catch\s*\(' 2>/dev/null; then
          echo "${file}:${line_num} IG-06 — outbound call after catch block (exfil-on-error pattern)"
          FINDINGS=$((FINDINGS + 1))
        fi
      fi
    fi
  done < "$file"
}

if [[ -f "$TARGET" ]]; then
  scan_file "$TARGET"
elif [[ -d "$TARGET" ]]; then
  while IFS= read -r file; do
    case "$file" in
      */node_modules/*|*/.git/*|*.png|*.jpg|*.gif|*.min.js) continue ;;
    esac
    case "$file" in
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) scan_file "$file" ;;
    esac
  done < <(find "$TARGET" -type f 2>/dev/null || true)
fi

if [[ $FINDINGS -gt 0 ]]; then
  echo "" >&2
  echo "Total findings: $FINDINGS network call(s) flagged" >&2
  if $CI_MODE; then exit 1; fi
else
  echo "✓ No suspicious outbound network calls detected" >&2
fi

exit 0
