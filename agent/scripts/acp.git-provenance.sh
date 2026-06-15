#!/usr/bin/env bash
# acp.git-provenance.sh — Git Commit Provenance Verifier
# Part of /acp-integrity v1.0 (M56), M64 routes 182/183
#
# Covered rules: IG-33, IG-34, IG-35, IG-36, IG-37

set -euo pipefail
trap 'echo "Error: git-provenance.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
IDENTITY_FILE="${PROJECT_ROOT}/agent/core/identity.yml"
# shellcheck source=acp.integrity-output.sh
source "${SCRIPT_DIR}/acp.integrity-output.sh"

SINCE="10"
IG_REMAINING_ARGS=()
ig_parse_common_args "$@"
set -- "${IG_REMAINING_ARGS[@]:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --since) SINCE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.git-provenance.sh [--ci] [--json] [--since N]"
      exit 0
      ;;
    *) shift ;;
  esac
done

TEAM_MEMBERS=()
if [[ -f "$IDENTITY_FILE" ]]; then
  in_team=false
  while IFS= read -r line; do
    if echo "$line" | grep -q '^team_members:'; then
      in_team=true
      continue
    fi
    if $in_team; then
      if echo "$line" | grep -qE '^\s*-'; then
        email=$(echo "$line" | sed 's/^\s*-[[:space:]]*//' | tr -d '"' | tr -d "'" | tr -d '\r')
        [[ -n "$email" ]] && TEAM_MEMBERS+=("$email")
      elif echo "$line" | grep -qE '^\S'; then
        break
      fi
    fi
  done < "$IDENTITY_FILE"
fi

cd "$PROJECT_ROOT"
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Warning: not a git repository — skipping git provenance checks" >&2
  ig_finalize_scan "git-provenance"
fi

# IG-37: explicit skip when team_members empty (route-183)
if [[ ${#TEAM_MEMBERS[@]} -eq 0 ]]; then
  echo "IG-37: skipped — team_members empty in identity.yml (configure team_members to enable)" >&2
else
  while IFS= read -r line; do
    email=$(echo "$line" | awk '{print $2}')
    commit_hash=$(echo "$line" | awk '{print $1}')
    matched=false
    for tm in "${TEAM_MEMBERS[@]}"; do
      if [[ "$email" == "$tm" ]]; then matched=true; break; fi
    done
    if ! $matched; then
      ig_emit_finding "" "0" "IG-37" "commit ${commit_hash:0:7}: author ${email} not in team_members"
    fi
  done < <(git log --format="%H %ae" -n "$SINCE" 2>/dev/null || true)
fi

CRITICAL_PATHS="auth|crypto|payment|data-access|agent/core|agent/memory"
while IFS= read -r commit_hash; do
  [[ -z "$commit_hash" ]] && continue
  files_changed=$(git diff-tree --no-commit-id --name-only -r "$commit_hash" 2>/dev/null | tr '\n' ' ')
  commit_msg=$(git log --format="%s" -n 1 "$commit_hash" 2>/dev/null || echo "")
  if echo "$files_changed" | grep -qE "$CRITICAL_PATHS" 2>/dev/null; then
    ins=$(git diff --shortstat "${commit_hash}^!" 2>/dev/null | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' | head -1 || echo "0")
    if [[ "${ins:-0}" -gt 200 ]] 2>/dev/null; then
      if ! echo "$commit_msg" | grep -qE 'route-[0-9]+|task-[0-9]+|M[0-9]+' 2>/dev/null; then
        ig_emit_finding "" "0" "IG-33" "commit ${commit_hash:0:7}: >200 lines to critical paths without task ID"
      fi
    fi
    if echo "$files_changed" | grep -qE 'agent/core/constraints|network_whitelist|identity\.yml' 2>/dev/null; then
      if ! echo "$commit_msg" | grep -qE 'route-[0-9]+|task-[0-9]+|security|audit' 2>/dev/null; then
        ig_emit_finding "" "0" "IG-34" "security-critical file change without linked task ID"
      fi
    fi
  fi
done < <(git log --format="%H" -n "$SINCE" 2>/dev/null || true)

while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  commit_hash="${entry%% *}"
  binary_file="${entry#* }"
  commit_msg=$(git log --format="%s" -n 1 "$commit_hash" 2>/dev/null || echo "")
  if ! echo "$commit_msg" | grep -qiE 'document|justif|reason|rationale|decision' 2>/dev/null; then
    ig_emit_finding "$binary_file" "0" "IG-36" "binary added in ${commit_hash:0:7} without documented justification"
  fi
done < <(git log --diff-filter=A --name-only --format="%H" -n "$SINCE" -- '*.png' '*.jpg' '*.gif' '*.ico' '*.pdf' 2>/dev/null | awk 'NR%2==1{h=$0} NR%2==0{print h" "$0}' || true)

ig_finalize_scan "git-provenance"
