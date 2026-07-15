---
id: task-249
milestone: M73
title: "Tracking truth sync — progress, task frontmatter, milestone gates"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started: null
completed: null
route: route-238
audit_findings: [F-094-03, F-094-05, F-094-08, F-094-09, F-094-10]
depends_on: []
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Align progress.yaml, task file frontmatter, milestone verification gates, and project notes so tracking layers tell one honest story about M72 completion state.

## Context

- task-246 marked `completed` in progress.yaml but CRIT-065-002 pending, gh api 404, task file `planned` (F-094-03)
- Tasks 243, 244, 246, 247 frontmatter still `planned` while progress says completed (F-094-05)
- M72 milestone 11 verification gates all `[ ]` despite completed status (F-094-08)
- progress notes cite 3 surfaces not 5; missing claude (F-094-09)
- Milestone gate "wrong cwd fails" conflicts with D1 module ROOT (F-094-10)

## Steps

1. Revert task-246 in progress.yaml: `status: deferred`, `completed_date: null`, notes cite CRIT-065-002 blocker (`gh api` 404)
2. Sync task frontmatter: 243, 244, 247 → `status: completed` with dates matching progress; 246 → `status: deferred`
3. Update M72 milestone doc: amend closure note; check gates `[x]` where runtime evidence exists (cite commit/audit probe); leave ops gates open for 253
4. Fix F-094-10: update M72 milestone gate text — ROOT-missing fails loudly; any cwd OK per D1
5. Update progress.yaml notes: 5 wrapper surfaces (prompts, opencode, cursor, claude); v6.27.0 shipped; M72 closure pending M73
6. Add audit-093 superseded banner in `agent/reports/audit-093-m72-closure.md`

## Verification

- [ ] `grep task-246 agent/progress.yaml` → `deferred`, not completed
- [ ] All M72 task files frontmatter matches progress.yaml status
- [ ] M72 milestone gates reflect evidence (not blanket `[x]` without proof)
- [ ] progress notes mention 5 surfaces + claude
- [ ] audit-093 header says SUPERSEDED

## User-Observable Acceptance

`/acp-status` and milestone doc agree on what's done vs deferred; no false "branch protection complete."
