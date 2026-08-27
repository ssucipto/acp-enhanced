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
audit_findings: ['F-118-04', 'F-119-05']
files_affected:
  - agent/commands/acp.audit.md
  - agent/commands/acp.report.md
  - agent/commands/acp.review.md
  - agent/commands/acp.integrity.md
  - agent/commands/acp.design-spec.md
  - agent/commands/acp.install.md
  - agent/commands/acp.clarification-address.md
  - agent/scripts/acp.ci.sh
  - e2e/acp.audit.test.sh
  - e2e/acp.tier3-memory-knowledge.test.sh
  - agent/wiki/architecture.md
---

<!-- @acp.meta.task
topic: m87, e2e, commands, local-reports
description: Stop requiring historical tracked audits; writers still create local files; tests must not git-add reports.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D2
depends_on: task-324
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Update command docs, E2E, wiki, and leftover **code comments** so writers still write under `agent/reports/`, but nothing requires those bodies to be git-tracked.

## Context

Citation map from 322. Known leftovers (audit-119): `acp.design-spec.md` exemplar paths into feedback/reports; `acp.ci.sh:46` cites `agent/reports/m86-ci-job-baseline.md`; `architecture.md:80,107` treats audits as durable git artifacts. `e2e/acp.audit.test.sh` only asserts the **directory** exists — keep that; add `git check-ignore` if a test creates a report.

## Steps

1. Command docs (`acp.audit`, `acp.report`, review/integrity `--report`, `acp.design-spec`): “write locally; do not commit; ADR-27.” Replace FIFOZ exemplar **paths** with a generic `agent/reports/design-spec-{subject}-v{N}.md` (do not paste spec body).
2. `acp.install.md` “preserving reports” language: preserve **on disk**, not as tracked evidence.
3. `acp.ci.sh` usage text: remove the reports-path citation; keep tier descriptions in-line.
4. `architecture.md` (those two bullets only — do not load the whole wiki): audits are local; ledger IDs live in carryovers/CHANGELOG.
5. E2E: no `git add` of reports; if a test writes a report, assert `git check-ignore`.
6. Run affected E2E. Do not weaken to no-ops (FG-3).

## Verification

- [ ] No command doc says reports are version-controlled evidence
- [ ] `acp.ci.sh --help` does not point at a report file
- [ ] Wiki bullets match ADR-27
- [ ] Affected E2E green

## User-Observable Acceptance

CI can clone a reports-empty tree and still pass audit E2E.

## Expected Output

### Files Created / Modified
- files_affected list above

### Notes
`acp.validate.md` is task-324. Pattern/install heredocs are 326.
