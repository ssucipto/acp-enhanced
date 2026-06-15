---
id: route-171
title: Populate team_members in identity.yml; enable IG-37 author verification
task_type: yaml-schema
milestone: M61
complexity: low
executor: copilot
context_required:
  - core/identity.yml
  - wiki/integrity-rules.md
files_affected:
  - agent/core/identity.yml
tokens_est: 2500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Populate `team_members` in identity.yml so `/acp-integrity` IG-37 (git author provenance verification) is active instead of a no-op.

## Context

`identity.yml:25` has `team_members: []`, which disables IG-37 git author verification (audit-065 M4). `acp.git-provenance.sh` reads this list to flag commits from unexpected authors.

## Steps

1. Determine the maintainer's git author email(s): `git log -1 --format='%ae'` and any co-author identities.
2. Set `team_members:` in `identity.yml` to the verified email(s).
3. Confirm Layer 1 token budget still under 500 (identity.yml is prompt-cached) — keep additions minimal.
4. Run `agent/scripts/acp.git-provenance.sh --since 10` to confirm it now verifies authors without false positives.
5. (Optional, coordinate with route-177/L4) note that git-provenance currently parses team_members with grep — full parser migration is L4.

## Expected Output

### Files Modified
- `agent/core/identity.yml` — populated team_members

## Verification (double-verify)

- [ ] **Automated**: `acp.git-provenance.sh` runs and verifies recent commits (no false CRITICAL for known authors)
- [ ] **Manual**: a commit from an unknown author email is flagged by IG-37
- [ ] identity.yml still under Layer 1 budget (~388 tokens baseline)

## User-Observable Acceptance

- `/acp-integrity` IG-37 reports author verification active, not skipped

## Addresses

audit-065 M4 (consolidated register)
