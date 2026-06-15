---
id: route-169
title: Add CODEOWNERS + PR and issue templates
task_type: ci-cd-setup
milestone: M61
complexity: low
executor: copilot
context_required:
  - core/identity.yml
files_affected:
  - .github/CODEOWNERS
  - .github/pull_request_template.md
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Add a code-ownership model and standardized contribution templates so reviews are routed and PRs/issues follow a consistent checklist.

## Context

No CODEOWNERS (audit-065 MED-065-003... M3) and no PR/issue templates (M6). These pair with branch protection (route-162) to satisfy OpenSSF Scorecard review requirements.

## Steps

1. Create `.github/CODEOWNERS` with a catch-all owner rule (the solo maintainer per identity.yml `team: solo-developer`); add finer-grained rules for `scripts/` and `.github/workflows/` if useful.
2. Create `.github/pull_request_template.md` with a checklist:
   - E2E tests pass; `/acp-validate` clean; CHANGELOG updated; route/milestone reference; double-verify evidence (automated + manual).
3. Create `.github/ISSUE_TEMPLATE/bug_report.md` and `feature_request.md` with structured fields.
4. Verify templates render on GitHub (correct frontmatter for issue templates).

## Expected Output

### Files Created
- `.github/CODEOWNERS`
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`

## Verification (double-verify)

- [ ] **Automated**: GitHub applies CODEOWNERS (review auto-requested on PR) — confirm after push
- [ ] **Manual**: opening a PR pre-fills the template; New Issue shows the template chooser

## User-Observable Acceptance

- New PRs show the checklist; new issues offer bug/feature templates
- CODEOWNERS auto-requests review

## Addresses

audit-065 M3, M6 (consolidated register)
