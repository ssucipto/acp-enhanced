# Milestone 73: M72 Closure Honesty & Carryover Integrity Remediation

<!-- @acp.meta.milestone
topic: audit-094, carryover-integrity, closure-process
description: Restore honest M72 closure — fix process shortcuts without re-doing runtime hardening
status: planned
updated: 2026-07-15
@acp.meta.end -->

**Planned version**: 6.27.1
**Status**: completed (7/7 — audit-096 PASS WITH DEFERRALS)
**Estimated effort**: ~12h (7 tasks)
**Source**: audit-094 (M72 implementation gaps — FAIL)
**Depends on**: M72 runtime work (v6.27.0 — enforcement sound)
**Design**: [m73-m72-closure-honesty-remediation.md](../design/m73-m72-closure-honesty-remediation.md)

## Goal

M72 enforcement code ships as v6.27.0. **Closure is not honest** until this milestone completes. Restore carryover audit trail integrity, run independent closure with seeded negative probes, sync all tracking layers, register remaining scripts, green the post-milestone-sweep, and ship v6.27.1 as a process/metadata patch.

## Context

audit-094 verdict: **FAIL** on closure hygiene despite runtime PASS. Critical issues: F-094-01 (19 corrupted `verified_in_audit`), F-094-02 (audit-093 self-cert), F-094-03 (task-246 false complete), F-094-04 (sweep 2/6).

## Build Order

| Phase | Route | Task | Title | Findings | Est. | Priority |
|-------|-------|------|-------|----------|------|----------|
| **1** | route-237 | task-248 | Carryover integrity restore + stamp guard | F-094-01; D9 prevention | 2h | P0 |
| **1** | route-238 | task-249 | Tracking truth sync (progress, tasks, gates, notes) | F-094-03, 05, 08, 09, 10 | 2h | P0 |
| **2** | route-239 | task-250 | Script registration + D4 WARN→ERROR | F-094-06, 07 | 2h | P1 |
| **2** | route-240 | task-251 | Post-milestone-sweep 6/6 (tsc + gate fixes) | F-094-04 | 2h | P1 |
| **3** | route-241 | task-252 | Independent closure audit-095 (seeded probes) | F-094-02, 06 | 2h | P0 |
| **3** | route-242 | task-253 | Branch protection ops (honest deferral) | CRIT-065-002; F-094-03 | 1h | P0 |
| **4** | route-243 | task-254 | M73 closure audit-096 + ship v6.27.1 | all F-094 | 1h | P0 |

Dependency notes: task-252 depends on 248–251 (restored carryovers + green gates before re-stamp); task-254 depends on all; task-253 can run in parallel with 250–251 if admin available.

## Task Map

| Task | Route | Deliverable | Gate |
|------|-------|-------------|------|
| [task-248](../tasks/milestone-73-m72-closure-honesty-remediation/task-248-carryover-integrity-restore.md) | route-237 | 19 entries restored; guard test | F-094-01 fixed |
| [task-249](../tasks/milestone-73-m72-closure-honesty-remediation/task-249-tracking-truth-sync.md) | route-238 | task-246 deferred; frontmatter synced; M72 gates checked | F-094-03/05/08/09/10 fixed |
| [task-250](../tasks/milestone-73-m72-closure-honesty-remediation/task-250-script-registration-d4-ratchet.md) | route-239 | 14 scripts registered; D4 ERROR | F-094-06/07 fixed |
| [task-251](../tasks/milestone-73-m72-closure-honesty-remediation/task-251-sweep-gates-green.md) | route-240 | post-milestone-sweep 6/6 | F-094-04 fixed |
| [task-252](../tasks/milestone-73-m72-closure-honesty-remediation/task-252-independent-closure-audit-095.md) | route-241 | audit-095 PASS; M72 carryovers re-stamped | F-094-02/06 fixed |
| [task-253](../tasks/milestone-73-m72-closure-honesty-remediation/task-253-branch-protection-ops.md) | route-242 | CRIT-065-002 honest status + PR if unblocked | ops track |
| [task-254](../tasks/milestone-73-m72-closure-honesty-remediation/task-254-m73-closure-ship.md) | route-243 | audit-096 PASS; v6.27.1 tagged | M73 complete |

## Anti-Shortcut Guardrails

See design doc § Anti-Shortcut Guardrails. **Binding**: independent audit-095; no bulk carryover replace; no false `completed` on ops tasks.

## Verification Gates (M73 closure)

- [ ] `git show 07ab4d5^:agent/memory/audit-carryovers.md` diff confirms 19 restores (task-248)
- [ ] Zero `verified_in_audit: audit-093` on pre-M72 entries (guard test)
- [ ] `audit-095` report lists 5 seeded negative probes with before/after output
- [ ] `audit-093` header marked SUPERSEDED
- [ ] task-246 `status: deferred` in progress.yaml; CRIT-065-002 `pending`
- [ ] All M72 task files 243–247 frontmatter `completed` OR 246 `deferred` matching progress
- [ ] M72 milestone verification gates `[x]` with evidence refs
- [ ] 14 scripts in package.yaml; unregistered disk script fails validator
- [ ] `bash agent/scripts/acp.post-milestone-sweep.sh` → 6/6 pass
- [ ] `npx vitest run` in scripts/ → all pass
- [ ] `npx tsx scripts/acp-validate.ts` → exit 0
- [ ] `git tag v6.27.1` exists; CHANGELOG entry; identity/package 6.27.1
- [ ] audit-096 PASS; F-094-01..10 carryovers `fixed` with honest `verified_in_audit`

## M72 Amendment Note

M72 runtime deliverables (validator, CI, D9, v6.27.0 tag) remain valid. M72 **closure status** amends from "audit-093 PASS" to **"pending M73 honest closure"** until audit-095/096 pass.
