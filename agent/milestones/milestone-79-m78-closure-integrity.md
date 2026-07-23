# Milestone 79: M78 Closure-Integrity Remediation

<!-- @acp.meta.milestone
topic: m78, closure-integrity, version-regression, carryover-hygiene, audit-099
description: Fix the M78 v6.28.0 version regression, close the carryover ledger honestly, harden the validator and detection helper
status: in_progress
updated: 2026-07-23
@acp.meta.end -->

**Planned version**: 6.28.1
**Status**: in_progress (2/4)
**Estimated effort**: ~5h (4 tasks)
**Source**: audit-099 (M78 implementation gaps)
**Depends on**: M78 (v6.28.0)

## Goal

M78 shipped with a real regression I then mis-reported: the v6.28.0 bump missed `agent/progress.yaml`'s own `version:` field, caught by cross-file E2E version checks but not by `acp-validate.ts`, and my "zero regression" claim was file-level and masked it. This milestone fixes the regression, closes the validator gap so it can't recur, closes the carryover ledger honestly (F-098-01..07 + F-097-01 were implemented but never marked fixed), and hardens two low-severity items — shipping v6.28.1.

## Scope

| In scope (M79 → v6.28.1) | Out of scope |
|---|---|
| F-099-01 progress.yaml version regression | The ~6 genuinely pre-existing E2E failures (F-M78-01) — root-caused in audit-099, deferred to a later triage milestone |
| F-099-02 validator gap (progress.yaml version) | New CodeRabbit features (ADR-19 gated) |
| F-099-03 close F-098-*/F-097-01 carryovers | |
| F-099-04 stale milestone doc ref | |
| F-099-05 coderabbit_available repo-root hardening | |
| F-099-06 task-259 pointer reconcile | |

## Build Order

| Route | Task | Title | Findings | Est. |
|-------|------|-------|----------|------|
| route-250 | task-261 | Version regression fix + carryover ledger closure + doc reconcile | F-099-01, F-099-03, F-099-04, F-099-06 | 1.5h |
| route-251 | task-262 | acp-validate.ts checks progress.yaml version | F-099-02 | 1.5h |
| route-252 | task-263 | Harden coderabbit_available for repo-root detection | F-099-05 | 1h |
| route-253 | task-264 | M79 closure — v6.28.1, confirm e2e-workflow/security cleared | closure | 1h |

Dependency: task-262 depends on task-261 (validator asserts the now-correct version). task-264 depends on all.

## Anti-Shortcut Guardrails

1. **Assertion-level verification** — after the version fix, re-run `tests/acp.e2e-workflow.test.sh` + `tests/acp.security.test.sh` and confirm the version-mismatch assertions clear (not just the file-level count).
2. **Close the validator gap** — F-099-02 must land so a future bump can't skip progress.yaml again.
3. **Honest carryover closure** — mark F-098-01..07 + F-097-01 `fixed` with `verified_in_audit: audit-099` only after re-confirming each is actually implemented.
4. **Do NOT fix the ~6 pre-existing E2E failures here** — out of scope; they are old debt, not M78/M79 shortcuts.

## Verification Gates (M79 closure)

- [ ] `grep "^  version:" agent/progress.yaml` → 6.28.0 (task-261)
- [ ] `tests/acp.e2e-workflow.test.sh` + `tests/acp.security.test.sh` version assertions pass (task-261)
- [ ] `acp-validate.ts` fails if progress.yaml version diverges from identity (new check + negative test) (task-262)
- [ ] F-098-01..07 + F-097-01 → `status: fixed`, `verified_in_audit: audit-099` (task-261)
- [ ] milestone-78 Build Order references `acp.coderabbit.sh` (task-261)
- [ ] `coderabbit_available` detects config from a subdirectory (task-263 + E2E case)
- [ ] `acp-validate.ts` exit 0; vitest green; v6.28.1 tagged (task-264)
- [ ] Remaining pre-existing E2E failures explicitly re-affirmed as deferred (task-264)
