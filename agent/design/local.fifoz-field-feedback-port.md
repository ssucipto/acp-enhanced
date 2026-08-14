# Design: FIFOZ Field-Feedback Port (M86)

<!-- @acp.meta.design
topic: fifoz, feedback, acp-ci, acp-pr, upgrade-guard, false-green, review-scan
description: Port verified FIFOZ field feedback into ACP Enhanced without re-shipping identical commands or copying stack-specific CI bodies
status: active
updated: 2026-08-14
@acp.meta.end -->

**Version**: 1.0.0  
**Date**: 2026-08-14  
**Source of truth**: `agent/reports/audit-114-fifoz-feedback-upstream-port.md`  
**Inbox snapshots**: `agent/reports/fifoz-port-inbox-2026-08-14/`  
**Target release**: v6.31.0  
**Related ADRs**: ADR-24, ADR-25, ADR-26  

---

## Problem statement

FIFOZ dogfoods ACP Enhanced daily and produced feedback-001…009 plus a 2026-08-14 upstream port guide. Their production pain is real:

1. **No command predicts CI** — `/acp-validate`, `/acp-review`, `/acp-integrity` all sound like verification; none runs the gates GitHub Actions runs. PRs fail after agents report green.
2. **Routing stubs without commands** — `ci-check` / `git-pr` suggest workflows that do not exist (same class as feedback-001 `/acp-pr` gap).
3. **False greens** — `set +e` under `trap ERR`, SKIP-as-PASS, empty `--only` plans, exit-code proxies instead of output contracts, dry-run claimed as verification.
4. **Silent upgrade loss** — `/acp-version-update` overwrites upstream-owned files; single-line fork enhancements disappear with no failure.
5. **Scanner proxy failures** — feedback-008; FIFOZ `acp.review-scan.sh` diverged from AE M83.

A second problem is **false port pressure**: the port guide’s “six unreported commands” are already byte-identical in ACP Enhanced (manifest-count error). Blind re-port would waste a milestone and create merge chaos.

## Proposed solution

Ship **M86** as a parallel track to fixture-gated M81:

| Wave | Deliverable |
|------|-------------|
| 0 | Measure AE CI jobs; encode false-green contracts in `constraints.yml` + patterns; pre-impl audit |
| 1 | Abstract `/acp-ci` (orchestrator + AE step bodies) + wire routing |
| 1b | `/acp-pr` that **only** delegates gates to `/acp-ci` |
| 2 | `upstream-delta.yml` + `acp.upgrade-guard.sh` hooked into version-update |
| 3 | Diff-merge `acp.review-scan.sh` (FIFOZ ↔ M83); feedback-008 discipline |
| 4 | feedback-002 residual matrix; package/wrappers; consumer dry-run; v6.31.0 |

## Key technical decisions

### D1 — Orchestrator / implementation split (ADR-24)

`acp.ci.sh` must **not** hard-code Expo/Firebase/Jest/m50. Core owns:

- tier selection, preflight, `--doctor`, ordering, tri-state summary, zero-executed fail-closed, unknown-id validation  
- a **step registry** loaded from `agent/configurables/ci.yml` + optional project step script  

Projects supply step bodies. ACP Enhanced’s own bodies map to **this repo’s** CI job graph (see below).

### D2 — `/acp-pr` gate delegation (ADR-24)

`acp.pr.sh` implements **no** gate logic. Default → `acp.ci.sh --fast`; `--strict-local` → `--full`. Duplicated gates are how false greens ship.

### D3 — Upgrade-delta register (ADR-25)

First-class `agent/upstream-delta.yml` + `acp.upgrade-guard.sh`. Missing sentinel = visible event. Prefer upstream when equal/better, then delete entry. Complements (does not replace) safer version-update work from audit-080/M68.

### D4 — No re-port of identical commands (ADR-26)

Do not re-ship: integrity, review (doc), carryover-query, rule-file-audit, session-sync, pattern-sync, design-spec, stakeholder-report, receive, handoff. Notify FIFOZ their `local_only` inventory is stale.

### D5 — Measure before tiering

Task-305 captures wall-clock for every AE CI gate **before** assigning static/fast/full. Assumed cost is forbidden (feedback-009 §2.3).

### D6 — audit-115 locked policies (pre-impl amendments)

| ID | Policy |
|----|--------|
| P-UG-1 | `upstream-delta.yml` present → version-update runs upgrade-guard and **HARD fails** on missing sentinel |
| P-CI-1 | `agent/configurables/ci.yml` is runtime CI matrix — **not** registered in `acp.configurables.yaml` |
| P-CI-2 | integrity-manifest regenerated in task-309 **and** again in 319 after 316 |
| P-VAL-1 | `executed_steps` required for `acp.ci` / `acp.pr` / `acp.upgrade-guard` coverage rows; extend validator |
| P-PATH-1 | Step bodies live at `agent/scripts/acp.ci-steps.sh` — never top-level `scripts/acp-ci-steps.sh` |

## AE CI job graph (planning baseline — task-305 re-measures)

From `.github/workflows/` (job-level, not “one job = CI”):

| Workflow | Job | PR-blocking? | Candidate tier (provisional) |
|----------|-----|--------------|------------------------------|
| `ci.yaml` | `validate` | yes | static / fast (split steps after measure) |
| `ci.yaml` | `shellcheck` | yes | static |
| `ci.yaml` | `e2e-smoke` | yes | fast |
| `ci.yaml` | `supply-chain` | soft (`continue-on-error` on npm audit) | full / warn |
| `e2e-tests.yaml` | `e2e` (matrix OS) | yes on PR | full |
| `benchmark.yaml` | `benchmark` | no (`workflow_dispatch`) | out-of-scope or `--release` only |

**Binding**: task-305 must assign every job a tier **or** a written out-of-scope rationale. Read every `if:` (none today on ci.yaml jobs — still verify after edits).

## False-green contracts (non-negotiable)

| ID | Rule |
|----|------|
| FG-1 | `set +e` does **not** suppress `trap ERR` — capture status in `if` context |
| FG-2 | Results are PASS / FAIL / **SKIP**; banners must not claim full parity when SKIP present |
| FG-3 | Never emit success when **zero** units executed |
| FG-4 | Validate user-supplied step ids; unknown → non-zero |
| FG-5 | When contract is “output contains X”, assert X — not exit code alone |
| FG-6 | `--dry-run` proves planning only; verification requires executed_steps coverage |
| FG-7 | Probe dependencies in `bash -c` (execution context), not agent shell functions |

## Explicit non-goals

- Re-porting SHA-identical commands from port guide §5  
- Copying FIFOZ `scripts/ci-frontend-check.sh` / Expo / Firebase / payslip / m50 bodies  
- Visualizer feedback-003/004 (wrong repository)  
- Inventing CodeRabbit fixture (M81 / ADR-22)  
- Changing `current_milestone` away from M81 (M86 is parallel)  
- Raising E2E timeouts to hide CI cost  

## Shortcuts this design explicitly refuses

1. Declaring M86 done by copying FIFOZ files into `agent/commands/` without abstraction  
2. Shipping `/acp-pr` before `/acp-ci` works  
3. Tiering from intuition without task-305 measurements  
4. E2E that only exercises `--dry-run` / `--help`  
5. Blind overwrite of `acp.review-scan.sh`  
6. Skipping pre-impl audit before coding  
7. Skipping upgrade-guard because “we’ll be careful”  
8. Closing F-114 carryovers without user-observable verification  
9. Version bump without wrappers + package.yaml + CHANGELOG + integrity-manifest  
10. Treating FIFOZ “six unreported” list as a task backlog  

## Success criteria (milestone-level)

- [ ] `/acp-ci --static` runs AE PR-blocking static gates in cost order; reports in CI job order  
- [ ] `/acp-ci --only typo` exits non-zero; empty plan never PASS  
- [ ] `/acp-pr` delegates gates; no duplicate gate implementation in `acp.pr.sh`  
- [ ] `acp.upgrade-guard.sh` detects removed sentinel and passes when restored  
- [ ] `routing.yml` `ci-check` / `git-pr` point at real commands  
- [ ] review-scan merge preserves M83 corpus green **and** FIFOZ feedback-008 precision fixes that still apply  
- [ ] FIFOZ notified: identical commands already upstream; upgrade checklist published  
- [ ] v6.31.0 released with full crosscut file set  

## Atomic design units (for task `incorporates`)

- **D1** Orchestrator/body split  
- **D2** PR→CI delegation  
- **D3** Upgrade-delta register + prefer-upstream policy  
- **D4** No re-port identical commands  
- **D5** Measure-before-tier  
- **FG-1…FG-7** False-green contracts  
