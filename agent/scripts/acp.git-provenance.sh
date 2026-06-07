#!/usr/bin/env bash
# acp.git-provenance.sh — Git Commit Provenance Verifier
# Part of /acp-integrity v1.0 (M56)
#
# Verifies git commit provenance: author emails match team_members in identity.yml,
# large commits to critical files have task IDs, binary files are justified.
#
# Usage:
#   acp.git-provenance.sh [--ci] [--since N]
#
# Covered rules: IG-33, IG-34, IG-35, IG-37

set -euo pipefail
trap 'echo "Error: git-provenance.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
IDENTITY_FILE="${PROJECT_ROOT}/agent/core/identity.yml"

CI_MODE=false
SINCE="10"  # Default: check last 10 commits

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) CI_MODE=true; shift ;;
    --since) SINCE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.git-provenance.sh [--ci] [--since N]"
      echo "Verifies git commit provenance against identity.yml team_members"
      exit 0
      ;;
    *) shift ;;
  esac
done

# ── Load Team Members ─────────────────────────────────────────────────────────

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
        email=$(echo "$line" | sed 's/^\s*-[[:space:]]*//' | tr -d '"' | tr -d "'")
        [[ -n "$email" ]] && TEAM_MEMBERS+=("$email")
      elif echo "$line" | grep -qE '^\S'; then
        break  # End of team_members list
      fi
    fi
  done < "$IDENTITY_FILE"
fi

# ── Git Checks ────────────────────────────────────────────────────────────────

FINDINGS=0

cd "$PROJECT_ROOT"

# IG-37: Commit author email verification
while IFS= read -r line; do
  email=$(echo "$line" | awk '{print $2}')
  commit_hash=$(echo "$line" | awk '{print $1}')
  
  if [[ ${#TEAM_MEMBERS[@]} -gt 0 ]]; then
    matched=false
    for tm in "${TEAM_MEMBERS[@]}"; do
      if [[ "$email" == "$tm" ]]; then
        matched=true
        break
      fi
    done
    if ! $matched; then
      echo "IG-37 — commit $commit_hash: author $email not in team_members"
      FINDINGS=$((FINDINGS + 1))
    fi
  fi
done < <(git log --format="%H %ae" -n "$SINCE" 2>/dev/null || true)

# IG-33: Large commits (>200 lines) to critical files without task ID
CRITICAL_PATHS="auth|crypto|payment|data-access|agent/core|agent/memory"
while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  files_changed=$(echo "$line" | awk '{print $2}')
  commit_msg=$(git log --format="%s" -n 1 "$commit_hash" 2>/dev/null || echo "")
  
  if echo "$files_changed" | grep -qE "$CRITICAL_PATHS" 2>/dev/null; then
    diff_stat=$(git diff --stat "${commit_hash}^!" 2>/dev/null | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    if [[ "$diff_stat" -gt 200 ]] 2>/dev/null; then
      if ! echo "$commit_msg" | grep -qE 'route-[0-9]+|task-[0-9]+|M[0-9]+' 2>/dev/null; then
        echo "IG-33 — commit $commit_hash: >200 lines to critical files without task ID"
        FINDINGS=$((FINDINGS + 1))
      fi
    fi
  fi
done < <(git log --format="%H" -n "$SINCE" 2>/dev/null | while read h; do
  files=$(git diff-tree --no-commit-id --name-only -r "$h" 2>/dev/null | tr '\n' ' ')
  echo "$h $files"
done || true)

# IG-36: Binary files committed without documentation
while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  binary_file=$(echo "$line" | awk '{print $2}')
  commit_msg=$(git log --format="%s" -n 1 "$commit_hash" 2>/dev/null || echo "")
  
  if ! echo "$commit_msg" | grep -qiE 'document|justif|reason|rationale|decision' 2>/dev/null; then
    echo "IG-36 — commit $commit_hash: binary file $binary_file without documented justification"
    FINDINGS=$((FINDINGS + 1))
  fi
done < <(git log --diff-filter=A --name-only --format="%H" -n "$SINCE" -- '*.png' '*.jpg' '*.gif' '*.ico' '*.pdf' '*.zip' '*.tar.gz' 2>/dev/null | while read h; do
  read f && echo "$h $f"
done || true)

if [[ $FINDINGS -gt 0 ]]; then
  echo "" >&2
  echo "Total findings: $FINDINGS git provenance issue(s)" >&2
  if $CI_MODE; then exit 1; fi
else
  echo "✓ No git provenance anomalies detected" >&2
fi

exit 0
