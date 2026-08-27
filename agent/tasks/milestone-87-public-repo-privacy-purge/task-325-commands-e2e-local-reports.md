---
id: task-325
milestone: M87
title: "Commands, E2E, and wiki: reports stay local"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 2
depends_on: [task-324]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04']
files_affected:
  - agent/commands/acp.audit.md
  - e2e/acp.audit.test.sh
  - agent/wiki/architecture.md
---

<!-- @acp.meta.task
topic: m87, e2e, commands, local-reports
description: Stop requiring historical tracked audits; writers still create local files; tests use fixtures or gitignored temp reports.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D2
depends_on: task-324
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Update command docs, E2E, and the relevant wiki section so `/acp-audit` / `/acp-report` still **write** under `agent/reports/`, but tests and docs never require those bodies to be git-tracked.

## Context

Citation map from 322. Many E2E suites assert tracked audit files or count files under `agent/reports/`. After 324, those files are ignored. Tests must use committed fixtures elsewhere, or write into the ignored dir and assert `git check-ignore`.

## Steps

1. From the 322 map, edit `acp.audit.md`, `acp.report.md`, review/integrity `--report` docs: “local only; do not commit”.
2. Fix `e2e/acp.audit.test.sh` and any other suite that `git add`s reports or requires a tracked historical `audit-N.md`.
3. Update golden TSV / coverage lists if they list report paths as tracked protocol files.
4. Wiki: one section of `architecture.md` (or domain.yml equivalent) — D9 tracking is superseded; do not load the whole wiki.
5. Run the affected E2E files locally; do not weaken assertions into no-ops.
6. Do not paste consumer internals into docs.

## Verification

- [ ] Audit E2E green without tracked historical audits
- [ ] Command docs say reports are gitignored
- [ ] No test `git add -f` on reports
- [ ] Validate still green

## User-Observable Acceptance

CI can clone a reports-empty tree and still pass audit E2E.

## Expected Output

### Files Created / Modified
- Command docs listed in 322 map
- `e2e/*.test.sh` as needed
- One wiki section

### Notes
Writers stay. Tracking goes.
