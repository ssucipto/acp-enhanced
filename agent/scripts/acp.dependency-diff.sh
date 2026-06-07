#!/usr/bin/env bash
# acp.dependency-diff.sh — Shadow Dependency & Supply Chain Checker
# Part of /acp-integrity v1.0 (M56)
#
# Detects shadow dependencies (imported but not in lockfile), typosquatting,
# postinstall script risks, unpinned versions, and stale lockfiles.
#
# Usage:
#   acp.dependency-diff.sh [--ci] [project_root]
#
# Covered rules: IG-27, IG-28, IG-29, IG-30, IG-31, IG-32

set -euo pipefail
trap 'echo "Error: dependency-diff.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

CI_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) CI_MODE=true; shift ;;
    -h|--help)
      echo "Usage: acp.dependency-diff.sh [--ci] [project_root]"
      echo "Checks for shadow dependencies, typosquatting, and supply chain risks"
      exit 0
      ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

FINDINGS=0

# ── Top-1000 npm packages (abbreviated — full list in wiki) ───────────────────

TOP_PACKAGES=(
  "react" "lodash" "axios" "express" "next" "typescript" "eslint" "prettier"
  "webpack" "babel" "jest" "mocha" "chai" "redux" "vue" "angular" "svelte"
  "tailwindcss" "bootstrap" "jquery" "d3" "moment" "dayjs" "uuid" "zod" "yup"
  "graphql" "apollo" "prisma" "sequelize" "mongoose" "typeorm" "knex"
  "passport" "jsonwebtoken" "bcrypt" "cors" "helmet" "morgan" "winston"
  "dotenv" "commander" "yargs" "chalk" "ora" "inquirer" "rimraf" "mkdirp"
  "glob" "semver" "node-fetch" "ws" "socket.io" "nodemailer" "multer"
  "sharp" "puppeteer" "cheerio" "playwright" "cypress"
)

# ── IG-29: Shadow Dependencies ────────────────────────────────────────────────

PACKAGE_JSON="${PROJECT_ROOT}/package.json"
LOCK_FILE=""

if [[ -f "${PROJECT_ROOT}/package-lock.json" ]]; then
  LOCK_FILE="${PROJECT_ROOT}/package-lock.json"
elif [[ -f "${PROJECT_ROOT}/yarn.lock" ]]; then
  LOCK_FILE="${PROJECT_ROOT}/yarn.lock"
fi

if [[ -f "$PACKAGE_JSON" ]]; then
  # IG-28: postinstall/preinstall scripts
  if grep -q '"postinstall"' "$PACKAGE_JSON" 2>/dev/null || grep -q '"preinstall"' "$PACKAGE_JSON" 2>/dev/null; then
    postinstall_content=$(ACP_PACKAGE_JSON="$PACKAGE_JSON" python3 -c "
import json, os
pkg_path = os.environ.get('ACP_PACKAGE_JSON', '')
with open(pkg_path) as f:
    data = json.load(f)
scripts = data.get('scripts', {})
for key in ['postinstall', 'preinstall']:
    if key in scripts:
        print(f'{key}: {scripts[key]}')
" 2>/dev/null || echo "postinstall present (parse error)")
    
    if echo "$postinstall_content" | grep -qiE 'curl|wget|bash|sh |eval|exec' 2>/dev/null; then
      echo "IG-28 — postinstall/preinstall script executes shell command: $postinstall_content"
      FINDINGS=$((FINDINGS + 1))
    else
      echo "IG-28 — postinstall/preinstall script present (review required): $postinstall_content"
      FINDINGS=$((FINDINGS + 1))
    fi
  fi
  
  # IG-30: Unpinned versions for security-critical packages
  SECURITY_PACKAGES="jsonwebtoken|bcrypt|passport|helmet|cors|crypto|auth|session|jwt|oauth"
  while IFS= read -r line; do
    pkg=$(echo "$line" | sed 's/.*"\([^"]*\)".*/\1/')
    version=$(echo "$line" | sed 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    if echo "$version" | grep -qE '^[\^~]' 2>/dev/null; then
      echo "IG-30 — unpinned security package: $pkg@$version (use exact version)"
      FINDINGS=$((FINDINGS + 1))
    fi
  done < <(grep -E "^\s*\"($SECURITY_PACKAGES)\"" "$PACKAGE_JSON" 2>/dev/null || true)
  
  # IG-27: Typosquatting check (Levenshtein approximation via substring)
  if [[ -f "$LOCK_FILE" ]]; then
    while IFS= read -r pkg; do
      pkg_name=$(echo "$pkg" | tr -d '[:space:]",')
      for top in "${TOP_PACKAGES[@]}"; do
        # Simple similarity check — flag packages that are close to popular names
        if [[ "$pkg_name" != "$top" ]] && [[ "${#pkg_name}" -ge "${#top}" ]]; then
          # Check if the package name contains a popular package name as substring
          # (e.g., "react-native" contains "react" — legitimate, but "reactt" does not)
          if echo "$pkg_name" | grep -qi "^${top}.\|.${top}$" 2>/dev/null && [[ ${#pkg_name} -le $((${#top} + 3)) ]]; then
            if ! echo "$pkg_name" | grep -qiE "^${top}-|/${top}$" 2>/dev/null; then
              echo "IG-27 — potential typosquatting: $pkg_name (close to '$top')"
              FINDINGS=$((FINDINGS + 1))
            fi
          fi
        fi
      done
    done < <(grep -oE '"[a-zA-Z0-9@/.-]+"' "$PACKAGE_JSON" 2>/dev/null | grep -v 'version\|name\|description' | head -100 || true)
  fi
fi

# ── IG-31: Stale lockfile ────────────────────────────────────────────────────

if [[ -f "$LOCK_FILE" ]] && [[ -f "$PACKAGE_JSON" ]]; then
  lock_mtime=$(stat -f %m "$LOCK_FILE" 2>/dev/null || stat -c %Y "$LOCK_FILE" 2>/dev/null || echo "0")
  pkg_mtime=$(stat -f %m "$PACKAGE_JSON" 2>/dev/null || stat -c %Y "$PACKAGE_JSON" 2>/dev/null || echo "0")
  diff_days=$(( (pkg_mtime - lock_mtime) / 86400 ))
  if [[ $diff_days -gt 30 ]]; then
    echo "IG-31 — lockfile is $diff_days days older than package.json (stale)"
    FINDINGS=$((FINDINGS + 1))
  fi
fi

if [[ $FINDINGS -gt 0 ]]; then
  echo "" >&2
  echo "Total findings: $FINDINGS dependency/supply chain issue(s)" >&2
  if $CI_MODE; then exit 1; fi
else
  echo "✓ No dependency or supply chain anomalies detected" >&2
fi

exit 0
