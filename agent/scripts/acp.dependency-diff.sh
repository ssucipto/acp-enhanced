#!/usr/bin/env bash
# acp.dependency-diff.sh — Shadow Dependency & Supply Chain Checker
# Part of /acp-integrity v1.0 (M56), M64 routes 180/182/183
#
# Covered rules: IG-27, IG-28, IG-29, IG-30, IG-31, IG-32

set -euo pipefail
trap 'echo "Error: dependency-diff.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
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
      echo "Usage: acp.dependency-diff.sh [--ci] [--json] [project_root]"
      exit 0
      ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

TOP_PACKAGES=(
  react lodash axios express next typescript eslint webpack babel jest
  vue angular svelte tailwindcss jquery moment uuid zod graphql prisma
  passport jsonwebtoken bcrypt cors helmet dotenv commander chalk
)

PACKAGE_JSON="${PROJECT_ROOT}/package.json"
LOCK_FILE=""
[[ -f "${PROJECT_ROOT}/package-lock.json" ]] && LOCK_FILE="${PROJECT_ROOT}/package-lock.json"
[[ -f "${PROJECT_ROOT}/yarn.lock" ]] && LOCK_FILE="${PROJECT_ROOT}/yarn.lock"

if [[ -f "$PACKAGE_JSON" ]]; then
  if grep -q '"postinstall"' "$PACKAGE_JSON" 2>/dev/null || grep -q '"preinstall"' "$PACKAGE_JSON" 2>/dev/null; then
    postinstall_content=$(ACP_PACKAGE_JSON="$PACKAGE_JSON" python3 -c "
import json, os
with open(os.environ['ACP_PACKAGE_JSON']) as f:
    data = json.load(f)
for key in ['postinstall', 'preinstall']:
    if key in data.get('scripts', {}):
        print(f'{key}: {data[\"scripts\"][key]}')
" 2>/dev/null || echo "present")
    if echo "$postinstall_content" | grep -qiE 'curl|wget|bash|sh |eval|exec' 2>/dev/null; then
      ig_emit_finding "$PACKAGE_JSON" "0" "IG-28" "postinstall/preinstall executes shell: ${postinstall_content}"
    fi
  fi

  SECURITY_PACKAGES="jsonwebtoken|bcrypt|passport|helmet|cors|crypto|auth|session|jwt|oauth"
  while IFS= read -r line; do
    pkg=$(echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')
    version=$(echo "$line" | sed -n 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    if echo "$version" | grep -qE '^[\^~]' 2>/dev/null; then
      ig_emit_finding "$PACKAGE_JSON" "0" "IG-30" "unpinned security package: ${pkg}@${version}"
    fi
  done < <(grep -E "^\s*\"(${SECURITY_PACKAGES})\"" "$PACKAGE_JSON" 2>/dev/null || true)

  if [[ -n "$LOCK_FILE" ]]; then
    while IFS= read -r dep; do
      [[ -z "$dep" ]] && continue
      for top in "${TOP_PACKAGES[@]}"; do
        if [[ "$dep" != "$top" && ${#dep} -le $((${#top} + 2)) ]]; then
          if python3 -c "
a,b='${dep}','${top}'
# Levenshtein distance <= 2
if a==b: exit(1)
m,n=len(a),len(b)
dp=[[0]*(n+1) for _ in range(m+1)]
for i in range(m+1): dp[i][0]=i
for j in range(n+1): dp[0][j]=j
for i in range(1,m+1):
  for j in range(1,n+1):
    cost=0 if a[i-1]==b[j-1] else 1
    dp[i][j]=min(dp[i-1][j]+1,dp[i][j-1]+1,dp[i-1][j-1]+cost)
exit(0 if dp[m][n]<=2 else 1)
" 2>/dev/null; then
            ig_emit_finding "$PACKAGE_JSON" "0" "IG-27" "potential typosquat: ${dep} (close to ${top})"
          fi
        fi
      done
    done < <(python3 -c "
import json, re, os
pj='${PACKAGE_JSON}'
lock='${LOCK_FILE}'
deps=set()
try:
    with open(pj) as f: data=json.load(f)
    for sec in ['dependencies','devDependencies']:
        deps.update((data.get(sec) or {}).keys())
except Exception: pass
print('\\n'.join(sorted(deps)))
" 2>/dev/null || true)

    # IG-29: shadow dependencies — import in src not in package.json
    if [[ -d "${PROJECT_ROOT}/src" || -d "${PROJECT_ROOT}/scripts" ]]; then
      shadow=$(ACP_ROOT="$PROJECT_ROOT" python3 -c "
import json, os, re
from pathlib import Path
root=Path(os.environ['ACP_ROOT'])
pj=root/'package.json'
lock_names=set()
try:
    data=json.loads(pj.read_text())
    for sec in ['dependencies','devDependencies']:
        lock_names.update((data.get(sec) or {}).keys())
except Exception: pass
imports=set()
pat=re.compile(r\"(?:import|require)\\s*\\(?['\\\"]([^./][^'\\\"]*)['\\\"]\")
for base in [root/'src', root/'scripts', root]:
    if not base.is_dir(): continue
    for f in base.rglob('*'):
        if f.suffix not in {'.ts','.tsx','.js','.jsx'}: continue
        if 'node_modules' in f.parts: continue
        try: text=f.read_text(encoding='utf-8',errors='ignore')
        except OSError: continue
        for m in pat.finditer(text):
            pkg=m.group(1).split('/')[0]
            if pkg.startswith('@'): pkg='/'.join(m.group(1).split('/')[:2])
            if pkg not in lock_names and not pkg.startswith('.'):
                imports.add(pkg)
for s in sorted(imports):
    print(s)
" 2>/dev/null || true)
      while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        ig_emit_finding "${PROJECT_ROOT}" "0" "IG-29" "shadow dependency imported but not in package.json: ${pkg}"
      done <<< "$shadow"
    fi
  fi
fi

# IG-31: stale lockfile via git commit dates (route-183 — not mtime)
if [[ -f "$LOCK_FILE" && -f "$PACKAGE_JSON" ]] && git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  lock_ts=$(git -C "$PROJECT_ROOT" log -1 --format=%ct -- "$(basename "$LOCK_FILE")" 2>/dev/null || echo "0")
  pkg_ts=$(git -C "$PROJECT_ROOT" log -1 --format=%ct -- "package.json" 2>/dev/null || echo "0")
  if [[ "$lock_ts" != "0" && "$pkg_ts" != "0" ]]; then
    diff_days=$(( (pkg_ts - lock_ts) / 86400 ))
    if [[ $diff_days -gt 30 ]]; then
      ig_emit_finding "$LOCK_FILE" "0" "IG-31" "lockfile commit is ${diff_days}d older than package.json changes"
    fi
  fi
fi

# IG-32: recent commits adding deps without task ID
if git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  while IFS= read -r line; do
    hash="${line%% *}"
    msg="${line#* }"
    if git -C "$PROJECT_ROOT" diff-tree --no-commit-id --name-only -r "$hash" 2>/dev/null | grep -qE 'package(-lock)?\.json$'; then
      if ! echo "$msg" | grep -qE 'route-[0-9]+|task-[0-9]+|M[0-9]+' 2>/dev/null; then
        ig_emit_finding "$PACKAGE_JSON" "0" "IG-32" "dependency change in ${hash:0:7} without task ID in message"
      fi
    fi
  done < <(git -C "$PROJECT_ROOT" log --format='%H %s' -n 5 2>/dev/null || true)
fi

ig_finalize_scan "dependency-diff"
