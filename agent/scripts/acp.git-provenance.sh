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
# shellcheck source=acp.yaml-parser.sh
source "${SCRIPT_DIR}/acp.yaml-parser.sh"

SINCE="10"
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
  member_count=$(yaml_get_array "$IDENTITY_FILE" "team_members" 2>/dev/null || echo "0")
  if [[ "$member_count" =~ ^[0-9]+$ ]] && [[ "$member_count" -gt 0 ]]; then
    for ((i = 0; i < member_count; i++)); do
      email=$(yaml_get_nested "$IDENTITY_FILE" "team_members[${i}]" 2>/dev/null || true)
      email="${email//$'\r'/}"
      [[ -n "$email" ]] && TEAM_MEMBERS+=("$email")
    done
  fi
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

# IG-35: files modified outside declared route files_affected
while IFS= read -r commit_hash; do
  [[ -z "$commit_hash" ]] && continue
  commit_msg=$(git log --format="%s" -n 1 "$commit_hash" 2>/dev/null || echo "")
  route_id=$(echo "$commit_msg" | grep -oE 'route-[0-9]+' | head -1 || true)
  [[ -z "$route_id" ]] && continue
  route_file="${PROJECT_ROOT}/agent/routing/tasks/${route_id}.md"
  [[ ! -f "$route_file" ]] && continue

  declared_files=()
  in_fa=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^files_affected: ]]; then in_fa=true; continue; fi
    if $in_fa && [[ "$line" =~ ^[[:space:]]+-[[:space:]]+ ]]; then
      f=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]*//')
      declared_files+=("$f")
    elif $in_fa && [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
      in_fa=false
    fi
  done < "$route_file"

  [[ ${#declared_files[@]} -eq 0 ]] && continue

  while IFS= read -r changed; do
    [[ -z "$changed" ]] && continue
    covered=false
    for d in "${declared_files[@]}"; do
      if [[ "$changed" == "$d" ]] || [[ "$changed" == "$d"* ]]; then covered=true; break; fi
    done
    if ! $covered && [[ "$changed" == agent/* ]]; then
      ig_emit_finding "$changed" "0" "IG-35" "changed outside ${route_id} files_affected (${commit_hash:0:7})"
    fi
  done < <(git diff-tree --no-commit-id --name-only -r "$commit_hash" 2>/dev/null || true)
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
