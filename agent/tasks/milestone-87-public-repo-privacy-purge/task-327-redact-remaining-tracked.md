---
id: task-327
milestone: M87
title: "Redact remaining tracked files ($HOME, consumer internals)"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 3
depends_on: [task-322, task-323]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-03', 'F-118-06', 'F-118-07', 'F-119-08']
files_affected:
  - agent/memory/sessions.md
  - agent/progress.yaml
  - agent/commands/acp.design-spec.md
  - CHANGELOG.md
---

<!-- @acp.meta.task
topic: m87, redact, home-path, leftovers
description: Strip leftover pointers and contradictory Class A guidance from files that remain tracked after the reports purge.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D6, D7
depends_on: task-322, task-323
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

After reports/feedback leave git, remaining tracked files must not still **point at** leaked bodies or tell agents to keep Class A audits in git. Keep IG-37 email in `identity.yml`.

## Context

`git grep '/Users/'` on develop tip outside reports/feedback is already clean except this milestone’s grep instructions. Leftovers are **policy/path** not home directories: `sessions.md` still has the audit-118 Class A key_fact; `progress.yaml` `active_handoff.path` points at a handoff report that will vanish from clones; `acp.design-spec.md` names the consumer spec filename (325 may already retarget — verify).

## Steps

1. Run:

```bash
git grep -n '/Users/\|orgId\|isProUser' -- ':!agent/reports' ':!agent/feedback'
```

Redact any hits without pasting the original secret into the commit message.

2. `sessions.md`: rewrite the 2026-08-27 audit-118 `key_fact` to “superseded by ADR-27; do not keep Class A in git” (one sentence). Do not delete the historical entry.
3. `active_handoff.path`: completed handoff — set path to empty string **or** a keeper README path; keep `status: completed`. Schema requires `path` string — use `agent/reports/README.md` after 328 keepers exist, or `agent/milestones/milestone-85-preference-yaml-performance.md` as a non-secret pointer. Prefer README keeper once 328 landed; if 327 runs first, use a tracked milestone path temporarily and fix in 328.
4. Keep `agent/core/identity.yml` team email (F-118-08).
5. Do not stamp F-118-* (history still dirty until 331).

## Verification

- [ ] No Class A-in-git instruction in the latest sessions key_fact
- [ ] `active_handoff.path` does not name a missing audit/handoff body on a fresh clone
- [ ] identity.yml email unchanged
- [ ] F-118-01..03 still `pending`

## User-Observable Acceptance

A new agent loading last-3 sessions does not follow the rejected Class A split.

## Expected Output

### Files Created / Modified
- files_affected plus any grep hits

### Notes
History rewrite of report blobs is 330, not a `--replace-text` of this tip.
