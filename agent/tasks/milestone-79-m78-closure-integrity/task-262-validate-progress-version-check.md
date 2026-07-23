---
id: task-262
milestone: M79
title: "acp-validate.ts checks progress.yaml version consistency"
status: planned
priority: 5
complexity: low
estimated_hours: 1.5
created: 2026-07-23
started: 2026-07-23
completed: 2026-07-23
route: route-251
audit_findings: [F-099-02]
depends_on: [task-261]
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

## Objective

Close the validator gap that let the F-099-01 regression pass: `validateVersionConsistency()` in `scripts/acp-validate.ts` must include `agent/progress.yaml`'s `project.version`.

## Context

audit-099 F-099-02: the version-consistency check reads identity/AGENTS/CLAUDE/CHANGELOG but not progress.yaml, so a stale progress.yaml version passed validate while the E2E cross-file checks failed. A validator that misses what an E2E catches is a gap to close so it can't recur.

## Steps

1. In `scripts/acp-validate.ts` `validateVersionConsistency()` (~line 893): read `agent/progress.yaml`, parse `project.version`, add it to the `files` map as `progress.yaml`. It participates in the same equality check as the other sources.
2. Match the existing extraction style (the function already loads several files into `files: Record<string,string>`).
3. Add a vitest in `scripts/` that asserts: a progress.yaml version differing from identity.yml produces a version-consistency error (negative case), and matching versions pass (positive case) — assert on the error/absence, not just types (constraints.yml `test_quality_gate`).
4. Run `npx tsc --noEmit` (or project's typecheck) and `npx vitest run`.

## Verification

- [ ] `validateVersionConsistency()` includes progress.yaml `project.version`
- [ ] Running validate with a deliberately mismatched progress.yaml version → non-zero / reported error
- [ ] New vitest covers positive + negative case, asserts on values
- [ ] `npx tsc --noEmit` clean; `npx vitest run` green
- [ ] `npx tsx scripts/acp-validate.ts` still exits 0 on the (now-consistent) repo

## User-Observable Acceptance

A future version bump that forgets `agent/progress.yaml` fails `acp-validate` immediately, instead of silently passing until an E2E catches it.
