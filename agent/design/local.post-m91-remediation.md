# Design: Post-M91 remediation (F-R006 + release hygiene)

<!-- @acp.meta.design
topic: F-R006, F-124-02, release-hygiene, carryover-closure
description: M92 plan v1.1.0 — close review-006 carryovers without audit-133 shortcuts (omit=dev, tag-move, optional E2E)
status: active
updated: 2026-08-29
@acp.meta.end -->

**Version**: 1.1.0  
**Date**: 2026-08-29  
**Source**: `agent/reports/audit-132-leftovers-carryovers-shortcuts.md` + `agent/reports/audit-133-m92-pre-impl.md`  
**Target release**: **v6.38.0** after Track A + task-371  
**Out of scope**: ADR-19 M74–M77, visualizer, Maestro/KVM E2E, force-push, moving tags, `--only smoke` alias, inventing bootstrap `--help`, F-R006 bundled into unrelated features  

---

## Problem statement

M91 Wave C and v6.37.1 leftover patch are **done**. Pending:

1. **F-R006-01** — `js-yaml` GHSA (direct **4.3.0** still vulnerable; need **4.3.1**; nested 3.x via gray-matter; **nanoid** 3.3.16 in dev tree)
2. **F-R006-02** — bootstrap missing exact `set -euo pipefail` (trap ERR already present)
3. **F-R006-03** — dispatch TypeScript `any` debt
4. **F-124-02** — `mainline` / `origin` unpublished
5. **F-132-01/02** — tag/push hygiene (close 01 by **v6.38.0**, not retagging 6.37.1)
6. **F-133-*** — plan holes from pre-impl (CI audit flags, required tests)

F-M82-07 already claimed js-yaml fixed at 4.3.0. **Do not** re-stamp that row; F-R006-01 is the remaining pin.

## Proposed solution — Milestone M92 (amended)

```
M92 Post-M91 remediation
├── Track A — F-R006                    tasks 365–367
├── Track A2 — Test package + regression  task-371
├── Track B — Release ops                 tasks 368–369
└── Track C — Progress hygiene            task-370
```

Do **not** set `current_milestone: M92` until `/acp-proceed` starts task-365.  
Do **not** bump `identity.yml` on 365 or 366.

---

## Track A — F-R006

### Task-365 — F-R006-01 js-yaml pin (CI-identical audit)

**Acceptance**

- `scripts/package.json`: `js-yaml` **4.3.1** (not `^4.1.0` resolving 4.3.0)
- `overrides` (or equivalent) so nested 3.x is **3.15.1** (gray-matter currently 3.15.0)
- If `npm audit --audit-level=high` (no `--omit=dev`) still reports nanoid: override/bump to **≥3.3.18**
- Update `scripts/package-lock.json`
- **Gate**: `cd scripts && npm audit --audit-level=high` → **0 high** (same command as `acp.ci-steps.sh`). **Forbidden**: `--omit=dev` as the pass criterion
- `cd scripts && npm test` (vitest) still green
- Carryover F-R006-01 → `status: fixed` after that gate
- **No** identity/CHANGELOG bump in this task

**Files**: `scripts/package.json`, `scripts/package-lock.json`

### Task-366 — F-R006-02 bootstrap SH-01

**Acceptance**

- First 40 lines contain the exact string `set -euo pipefail` (SH-01 scanner)
- Keep `trap ERR` (already present); do not add `set +e` under that trap
- `--team-size` without a value fail-closed (do not assign unbound `$2` under `-u`)
- `--yes` still works under nounset
- **Do not** add `--help` unless a separate scoped task exists — bootstrap has no `--help` today
- `bash -n scripts/acp-bootstrap.sh`
- `bash agent/scripts/acp.review-scan.sh scripts/acp-bootstrap.sh` → no SH-01
- **Required**: `e2e/acp.bootstrap.test.sh` and `e2e/acp.bootstrap-preserve.test.sh` still pass (keep BUG-045-01 assertions)
- Extend bootstrap E2E with: SH-01 string present; `--team-size` missing arg exits non-zero
- Carryover F-R006-02 → fixed
- **No** identity bump

**Files**: `scripts/acp-bootstrap.sh`, `e2e/acp.bootstrap.test.sh`

### Task-367 — F-R006-03 dispatch typing + v6.38.0

**Acceptance**

- `TaskMeta` (or equivalent) replaces `Record<string, any>` on `buildContext` / `appendLedger`
- Drop `as any` on `yaml.load`; type taxonomy
- `updateRoutingYml(...): void`
- `cd scripts && npx tsc --noEmit` and `npm test` green (`acp-dispatch.test.ts` must still assert **behavior**, not only types)
- Carryover F-R006-03 → fixed
- **Then** version bump **6.37.1 → 6.38.0**: identity, package.yaml, AGENTS/CLAUDE/copilot, AGENT.md, README badge, CHANGELOG, golden TSV identity node, integrity-manifest restamp

**Files**: `scripts/acp-dispatch.ts`, `scripts/acp-dispatch.test.ts`, version-bearing files listed above

---

## Track A2 — Test package (audit-133; not optional)

### Task-371 — M91 regression + test package refresh

**Acceptance** (run **after** 365–367)

- M91 contracts (must not regress):
  - `e2e/acp.smoke.test.sh`
  - `e2e/acp.exec-host.test.sh`
  - `e2e/acp.pr.test.sh`
  - `e2e/acp.ci.test.sh` (includes `--only smoke` unknown)
- Track A suites: bootstrap E2E pair; `cd scripts && npm test`; `bash agent/scripts/acp.ci.sh --only npm-audit` **or** the same `npm audit --audit-level=high` in `scripts/`
- `e2e/acp.command-coverage-parity.test.sh` (73 commands)
- yaml-parser equivalence (identity **6.38.0** in golden)
- Do **not** delete or weaken BUG-045-01 bootstrap assertions
- Do **not** add bootstrap `--help` tests

---

## Track B — Release ops

### Task-368 — Tag + push hygiene

**Acceptance**

- **Forbidden**: `git tag -f` / move `v6.37.0` or `v6.37.1`; **forbidden**: extra `v6.37.2` docs-only tag
- Annotated tag **`v6.38.0`** on the Track A + 371 commit
- Push `develop` when maintainer approves (F-132-02)
- `/acp-validate` green including git-tags
- F-132-01 → fixed when `v6.38.0` matches HEAD of the release commit

### Task-369 — F-124-02 regular PR develop → mainline

**Acceptance**

- `gh pr create` base `mainline` head `develop` (regular merge, **no force-push**)
- PR cites F-124-02 + audit-132/133
- After merge: default clone is not stuck on pre-M89 keepers
- F-124-02 → fixed (maintainer stamps)

**Blocker**: GitHub access; not autonomous without user approval.

---

## Track C — Progress hygiene

### Task-370 — Handoff + milestone pointer

**Acceptance**

- Confirm `active_handoff.path` is this design (already retargeted in `5c8400b`; stamp F-132-03 after verify)
- `next_steps` reflect remaining M92 work or completion
- `project.description` mentions v6.38.0 / F-R006 closed when true
- Do not leave F-132-03 pending if already done — stamp with `verified_in_audit: 133`

---

## Execution order

| Order | Task | Depends |
|-------|------|---------|
| 1 | 365 js-yaml + full npm audit | — |
| 2 | 366 bootstrap SH-01 + required E2E | — |
| 3 | 367 dispatch types + **v6.38.0 bump** | 365–366 preferred (same tree OK) |
| 4 | **371** regression + test package | **365–367** |
| 5 | 368 tag v6.38.0 + push | 371 |
| 6 | 369 mainline PR | 368 push |
| 7 | 370 hygiene stamps | anytime after handoff verify |

365–366 may be sequential in one session with per-task commits. **371 is not optional.**

---

## Verification matrix

| Gate | Command |
|------|---------|
| CI-identical audit | `cd scripts && npm audit --audit-level=high` |
| Vitest | `cd scripts && npm test` |
| SH-01 | `bash agent/scripts/acp.review-scan.sh scripts/acp-bootstrap.sh scripts/acp-dispatch.ts` |
| Bootstrap E2E | `e2e/acp.bootstrap.test.sh`, `e2e/acp.bootstrap-preserve.test.sh` |
| M91 regression | smoke, exec-host, pr, ci E2E |
| Validate | `npx tsx scripts/acp-validate.ts` |
| Coverage | `e2e/acp.command-coverage-parity.test.sh` |
| Parser golden | `tests/acp.yaml-parser-equivalence.test.sh` (after 6.38.0) |

---

## Shortcuts refused (M92 scope boundary)

- `npm audit --omit=dev` as the HIGH gate
- Claiming F-R006-01 fixed at js-yaml **4.3.0**
- Optional bootstrap E2E
- Inventing bootstrap `--help`
- Moving or deleting `v6.37.0` / `v6.37.1`
- Tagging v6.37.2 then v6.38.0
- Identity bump on 365/366
- ADR-19 / visualizer / Maestro / `--only smoke` alias
- `git add -f` for `agent/reports/`
- Treating CI `allow_skip` npm-audit as pass
- Force-push to `mainline` or tags

---

## Success criteria

- [ ] F-R006-01..03 **fixed** with CI-identical audit + SH-01 + vitest evidence
- [ ] Task-371 green (M91 + bootstrap + coverage + golden)
- [ ] **v6.38.0** tagged; `v6.37.1` still on `91f1dd5`
- [ ] `develop` pushed; `mainline` PR opened **or** deferred in `sessions.md` with owner
- [ ] F-132-01..03 closed or explicitly owned
- [ ] M92 `status: completed` in `progress.yaml`
