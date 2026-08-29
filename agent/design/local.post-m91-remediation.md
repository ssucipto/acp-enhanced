# Design: Post-M91 remediation (F-R006 + release hygiene)

<!-- @acp.meta.design
topic: F-R006, F-124-02, release-hygiene, carryover-closure
description: M92 plan to close review-006 carryovers and release drift without starting ADR-19 or visualizer work
status: active
updated: 2026-08-29
@acp.meta.end -->

**Version**: 1.0.0  
**Date**: 2026-08-29  
**Source**: `agent/reports/audit-132-leftovers-carryovers-shortcuts.md`  
**Target release**: v6.38.0 (F-R006 track) + ops (F-124-02 / tag hygiene)  
**Out of scope**: ADR-19 M74–M77, visualizer, Maestro/KVM E2E, force-push, F-R006 bundled into unrelated features  

---

## Problem statement

M91 Wave C and v6.37.1 leftover patch are **done**. Four carryovers remain **pending**:

1. **F-R006-01** — `js-yaml` CVE in `scripts/`
2. **F-R006-02** — bootstrap SH-01 (`set -euo pipefail` + `trap ERR`)
3. **F-R006-03** — dispatch TypeScript `any` debt
4. **F-124-02** — `develop` unpublished to `origin` and `mainline` stale for strangers

Additionally, **release hygiene**: tag `v6.37.1` predates the docs-sync commit; `active_handoff` is stale.

## Proposed solution — Milestone M92

Three tracks. **Track A** is agent-implementable. **Track B** is maintainer-heavy. **Track C** is hygiene.

```
M92 Post-M91 remediation
├── Track A — F-R006 (v6.38.0)     tasks 365–367
├── Track B — Release ops            tasks 368–369
└── Track C — Progress hygiene       task 370
```

Do **not** set `current_milestone: M92` until `/acp-proceed` starts task-365.

---

## Track A — F-R006 remediation (v6.38.0)

### Task-365 — F-R006-01 js-yaml pin

**Acceptance**

- `scripts/package.json`: `js-yaml` → **4.3.1**; npm overrides for nested 3.x → **3.15.1**
- `cd scripts && npm audit --omit=dev` → **0 high**
- Lockfile updated; CI `npm-audit` step still passes
- Carryover F-R006-01 → `status: fixed`, `verified_in_audit: 132`

**Files**: `scripts/package.json`, `scripts/package-lock.json` (if present)

### Task-366 — F-R006-02 bootstrap SH-01

**Acceptance**

- `scripts/acp-bootstrap.sh`: `set -euo pipefail` + `trap '…' ERR` at top (after shebang/comments)
- `--help` and `--yes` paths work under `nounset` (no unbound variable explosions)
- `bash -n` passes; optional: extend bootstrap E2E if harness exists
- `acp.review-scan.sh` SH-01 clean on bootstrap
- Carryover F-R006-02 → fixed in audit-132 verification

**Risk**: curl-pipe users — test unbound `$1` patterns; use `${var:-}` idioms.

### Task-367 — F-R006-03 dispatch typing

**Acceptance**

- `scripts/acp-dispatch.ts`: replace `Record<string, any>` with `TaskMeta` (or equivalent)
- Remove `as any` on `yaml.load`; type `updateRoutingYml(): void`
- `npx tsc --noEmit` in `scripts/` clean
- review-006 TS-01/TS-02 findings addressed on dispatch file
- Carryover F-R006-03 → fixed

**Version bump**: identity, package.yaml, AGENTS/CLAUDE/copilot, AGENT.md, README badge, CHANGELOG, golden TSV identity node, integrity-manifest restamp → **6.38.0**

---

## Track B — Release ops

### Task-368 — Tag + push hygiene

**Acceptance**

- Resolve F-132-01: either **move** annotated `v6.37.1` to `9ef93fc` (only if not pushed) **or** ship **v6.37.2** docs-only tag on HEAD — **do not** move `v6.37.0`
- Push `develop` to `origin` when maintainer approves (F-132-02)
- `/acp-validate` green including git-tags check

### Task-369 — F-124-02 regular PR develop → mainline

**Acceptance**

- `gh pr create` base `mainline` head `develop` (regular merge, no force-push)
- PR description cites F-124-02 + audit-132
- After merge: strangers cloning `mainline` get v6.37.x+ keepers
- Carryover F-124-02 → fixed (maintainer stamps)

**Blocker**: requires GitHub access + review; not autonomous without user approval.

---

## Track C — Progress hygiene

### Task-370 — Handoff + milestone pointer

**Acceptance**

- `active_handoff` → this design doc or `completed` with date 2026-08-29
- `next_steps` top entry → M92 Track A first
- `project.description` mentions M92 planned, F-R006 in flight
- Optional: weekly `review-006` carryover re-verify entry in `sessions.md`

---

## Execution order

| Order | Task | Depends |
|-------|------|---------|
| 1 | 365 js-yaml | — |
| 2 | 366 bootstrap | — |
| 3 | 367 dispatch | — |
| 4 | release v6.38.0 | 365–367 |
| 5 | 368 tag/push | release or parallel if docs-only tag |
| 6 | 369 mainline PR | 368 push |
| 7 | 370 hygiene | anytime |

**Parallel**: 365–367 can run in one session with per-task commits.

---

## Verification matrix

| Gate | Command |
|------|---------|
| Validate | `npx tsx scripts/acp-validate.ts` |
| Review Phase 1 | `bash agent/scripts/acp.review-scan.sh scripts/` |
| Bootstrap | `bash -n scripts/acp-bootstrap.sh` |
| Audit scripts | `cd scripts && npm audit --omit=dev` |
| E2E smoke | `e2e/acp.smoke.test.sh`, `e2e/acp.exec-host.test.sh`, `e2e/acp.pr.test.sh` |
| Coverage | `e2e/acp.command-coverage-parity.test.sh` |

---

## Shortcuts refused (M92 scope boundary)

- No visualizer, no ADR-19 Aikido milestones
- No `--only smoke` alias
- No real `--prepare` bundle E2E
- No `git add -f` for `agent/reports/`
- No force-push to `mainline` or tags

---

## Success criteria

- [ ] All four pending carryovers **fixed** or **documented blocked** with owner
- [ ] v6.38.0 tagged after F-R006 track
- [ ] `develop` pushed; `mainline` PR opened or explicitly deferred with reason in `sessions.md`
- [ ] audit-132 findings F-132-01..04 closed
- [ ] M92 milestone `status: completed` in `progress.yaml`
