---
id: task-246
milestone: M72
title: "Branch protection ops + PR develop → mainline"
status: planned
priority: 5
complexity: low
estimated_hours: 1
created: 2026-07-15
started: null
completed_date: null
route: route-235
audit_findings: [CRIT-065-002]
depends_on: [task-245]
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Close the longest-standing critical carryover: enable GitHub branch protection on `mainline`, then open the pending v6.26.0+ PR develop → mainline.

## Context (inlined from audit-091 + carryover CRIT-065-002)

- Carryover (audit-065, critical): "No branch protection rules on mainline or develop — force-push and direct commits unblocked." Live-confirmed during audit-091: `gh api repos/.../branches/mainline/protection` → 404. The validator's `validateBranchProtectionDocs()` warns on every run until this lands.
- Tooling already exists: `agent/scripts/acp.branch-protection-setup.sh` (registered in package.yaml per F-089-10). Requires repo-admin credentials — this task is runnable only by/with the repo owner; if credentials are unavailable in-session, produce the exact commands and stop (do NOT stamp fixed).
- progress.yaml next_steps already carries: "Open PR develop → mainline for v6.26.0 (or merge when branch protection enabled)".

## Steps

1. Run `bash agent/scripts/acp.branch-protection-setup.sh` (or equivalent `gh api -X PUT .../branches/mainline/protection` payload it wraps) with admin auth
2. Verify: `gh api repos/{owner}/{repo}/branches/mainline/protection` → 200; required PR reviews + force-push block active
3. Re-run validator — branch-protection warning gone
4. Open PR develop → mainline covering v6.26.0 + M72 work to date (PR body per repo convention)
5. Stamp CRIT-065-002 `fixed` with verification evidence ONLY if step 2 returns 200

## Verification

- [ ] `gh api .../branches/mainline/protection` → 200
- [ ] Validator run shows no branch-protection warning
- [ ] PR develop → mainline open (URL recorded in session entry)
- [ ] CRIT-065-002 `fixed` with audit-093 pointer — or explicitly left `pending` with blocker documented

## User-Observable Acceptance

`git push --force origin mainline` is rejected by GitHub; the PR appears in the repo's PR list.
