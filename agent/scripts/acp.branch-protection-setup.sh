#!/usr/bin/env bash
# acp.branch-protection-setup.sh — Enable GitHub branch protection (M70 CRIT-065-002)
#
# Requires: gh CLI authenticated with admin access to the repository.
# Usage: acp.branch-protection-setup.sh [--dry-run]

set -euo pipefail
trap 'echo "Error: branch-protection-setup.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "Usage: acp.branch-protection-setup.sh [--dry-run]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

cd "$PROJECT_ROOT"

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI not found — install GitHub CLI and authenticate" >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [[ -z "$REPO" ]]; then
  echo "Error: cannot resolve repository — run from git root with gh auth" >&2
  exit 1
fi

BODY='{
  "required_status_checks": {
    "strict": true,
    "contexts": ["validate", "shellcheck", "e2e-smoke"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}'

apply_rule() {
  local branch="$1"
  local pr_reviews="$2"
  local body
  if [[ "$pr_reviews" == "0" ]]; then
    body=$(echo "$BODY" | python3 -c "import json,sys; d=json.load(sys.stdin); d['required_pull_request_reviews']={'required_approving_review_count':0}; print(json.dumps(d))")
  else
    body="$BODY"
  fi

  if $DRY_RUN; then
    echo "DRY RUN: would protect branch ${branch} on ${REPO}"
    return 0
  fi

  echo "Applying branch protection to ${branch}..."
  if echo "$body" | gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/branches/${branch}/protection" \
    --input - 2>/dev/null; then
    echo "✅ ${branch} protection enabled"
  else
    echo "⚠️  ${branch}: failed — requires repo admin. Enable manually in GitHub Settings → Branches" >&2
    return 1
  fi
}

FAILED=0
apply_rule "mainline" "1" || FAILED=$((FAILED + 1))
apply_rule "develop" "0" || FAILED=$((FAILED + 1))

if [[ "$FAILED" -gt 0 ]]; then
  echo ""
  echo "Manual steps: docs/USAGE.md § Git Branch Protection"
  exit 1
fi

echo "✅ Branch protection setup complete for ${REPO}"
