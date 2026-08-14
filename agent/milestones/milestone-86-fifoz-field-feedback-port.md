# Milestone 86: FIFOZ Field-Feedback Port

<!-- @acp.meta.milestone
topic: fifoz, feedback, acp-ci, acp-pr, upgrade-guard, false-green, review-scan, v6.31.0
description: Port verified FIFOZ field feedback into ACP Enhanced — abstract CI/PR, upgrade-guard, false-green contracts, review-scan merge — without re-shipping identical commands
status: completed
updated: 2026-08-14
@acp.meta.end -->

**Planned version**: v6.31.0  
**Status**: completed  
**Progress**: 17/17 tasks — shipped as v6.31.0  
**Estimated effort**: ~69h (17 tasks, 5 phases)  
**Source**: audit-114 (source of truth), feedback-001b/008/009, upstream-port-guide-2026-08-14, fifoz-port-inbox-2026-08-14  
**Depends on**: nothing — **independent of M81** ADR-22 CodeRabbit fixture gate  
**Design**: [local.fifoz-field-feedback-port.md](../design/local.fifoz-field-feedback-port.md)  
**ADRs**: ADR-24, ADR-25, ADR-26  
**Closes**: F-114-02, F-114-03, F-114-04, F-114-05, F-114-06, F-114-07, F-114-08, F-114-09 (and informs F-114-01/10/11)

---

## Why this milestone exists

FIFOZ produced the strongest field evidence yet that ACP’s “verification” surface does not predict CI, that routing stubs without commands create false confidence, and that forks silently lose enhancements on upgrade. audit-114 verified their implementations and **corrected** their port guide: nine of eleven “missing” commands already exist upstream byte-identical.

The remaining work is the highest-leverage portable delta: **abstract `/acp-ci`**, **`/acp-pr` with gate delegation**, **upgrade-collision guard**, **false-green contracts**, and a **deliberate review-scan merge**.

## Goal

Make ACP Enhanced predict its own CI locally, open PRs only after those gates, protect forks from silent upgrade loss, and absorb FIFOZ scanner precision without destroying M83 — then ship v6.31.0 with a consumer upgrade path FIFOZ can trust.

## Phases

| Phase | Tasks | Outcome |
|-------|-------|---------|
| **0 — Foundations** | 305, 306, 307 | Measured CI matrix; FG contracts in constraints/patterns; pre-impl audit green |
| **1 — `/acp-ci`** | 308, 309, 310, 311 | Abstract CI + AE bodies + routing wire + E2E with real execution |
| **1b — `/acp-pr`** | 312, 313 | PR command delegates to CI; E2E + wrappers |
| **2 — Upgrade safety** | 314, 315 | upstream-delta + guard + version-update hook + E2E |
| **3 — Scanner merge** | 316, 317 | review-scan diff-merge + feedback-008 discipline |
| **4 — Closure** | 318, 319, 320, 321 | feedback-002 matrix; package/wrappers; consumer dry-run; v6.31.0 |

**Hard gates**: Phase 1 coding (308+) must not start until task-307 pre-impl audit is READY (**audit-115 READY** after amendments) **and** tasks 305–306 are complete. Task-312 must not start until task-311 proves `/acp-ci` fail-closed behaviors. Task-321 must not stamp carryovers without user-observable proof. Task-319 depends on 316 (integrity-manifest after scanner merge). Task-314 depends on 310 (sentinel population). Upgrade-guard HARD-fails version-update (P-UG-1).

## Binding rules (do not violate)

1. **audit-114 is source of truth** — not the uncorrected port guide §1 “six unreported” list (ADR-26).  
2. **Do not copy FIFOZ Expo/Firebase/m50 CI bodies** — abstract orchestrator only (ADR-24).  
3. **`/acp-pr` implements no gate logic** — only delegates to `/acp-ci` (ADR-24).  
4. **Measure before tiering** — task-305 medians (≥5 runs, idle machine) before static/fast/full assignments.  
5. **False-green contracts FG-1…FG-7** are mandatory in `/acp-ci` and any external-tool wrapper touched.  
6. **Dry-run is not verification** — E2E must execute real static steps at least once; record `executed_steps` where applicable.  
7. **Diff-merge review-scan** — never blind overwrite AE M83 or FIFOZ fixes.  
8. **`current_milestone` stays M81** until fixture arrives — M86 is parallel; do not steal the pointer in planning (implementation may temporarily focus M86 without rewriting the fixture gate story).  
9. **Prefer-upstream-when-superseded** for upgrade-delta entries (ADR-25).  
10. **Full crosscut release set** on v6.31.0 — AGENT.md, README, CHANGELOG, package.yaml, wrappers, integrity-manifest (no single-file “done”).

## Shortcuts this milestone explicitly refuses

- Re-porting SHA-identical command docs  
- Pasting `fifoz-port-inbox/acp.ci.sh` into `agent/scripts/`  
- Shipping `/acp-pr` first “because it’s smaller”  
- Tiering from assumed cost  
- E2E that only greps `--help` / dry-run output  
- Claiming PASS with zero steps or with SKIPs presented as full parity  
- Using `set +e` around non-zero tools under `trap ERR`  
- Gating on exit code when CI greps for specific output lines  
- Skipping `/acp-audit --pre-impl` before coding  
- Closing F-114-* without observable verification  
- Skipping consumer upgrade dry-run / FIFOZ notification  
- Raising timeouts to hide gate cost  
- Soft-fail upgrade-guard (P-UG-1 = **HARD fail**)  
- Step bodies in top-level `scripts/` (must be `agent/scripts/acp.ci-steps.sh`)  
- Closing v6.31.0 without scanner merge (316/317)  
- Fail-open task wording (“if required”, “defer”, “optional”) — removed in audit-115  
- Registering `ci.yml` as an `acp.configurables.yaml` preference (P-CI-1)  

## Deliverables

- `agent/commands/acp.ci.md`, `agent/scripts/acp.ci.sh`, `agent/scripts/acp.ci-steps.sh`  
- `agent/commands/acp.pr.md`, `agent/scripts/acp.pr.sh`  
- `agent/configurables/ci.yml` + `agent/schemas/ci.config.schema.yaml` (runtime matrix — not preference registry)  
- `agent/upstream-delta.template.yml`, `agent/upstream-delta.yml`, `agent/scripts/acp.upgrade-guard.sh`  
- `e2e/acp.ci.test.sh`, `e2e/acp.pr.test.sh`, `e2e/acp.upgrade-guard.test.sh`  
- `executed_steps` support in `command-e2e-coverage.yaml` + `acp-validate.ts`  
- Patterns for FG contracts + `docs/acp-fork-upgrade-checklist.md`  
- Merged `agent/scripts/acp.review-scan.sh`  
- Wrappers on all four surfaces; package/coverage/domain/manifest updates  
- v6.31.0 CHANGELOG + version pins  
- audit-115 pre-impl report  

## Explicit non-goals

- Visualizer feedback-003/004  
- M81 CodeRabbit fixture invention  
- Aikido / ADR-19 gated track  
- Replacing M83 deterministic review with CodeRabbit  

## Success criteria

- [x] Pre-impl audit-115 READY (after amendments)  
- [ ] All 17 tasks completed with Step 3.5 deliverable audits  
- [ ] `/acp-ci --static` and `--doctor` work on this repo  
- [ ] `/acp-pr --dry-run` shows CI delegation  
- [ ] Upgrade-guard self-test passes; version-update HARD-fails on missing sentinel  
- [ ] F-114-02,03,04,05,06,07,08,09,11 stamped fixed with evidence  
- [ ] FIFOZ upgrade note drafted (identical cmds already upstream)  
- [ ] `npx tsx scripts/acp-validate.ts` clean; relevant E2E green  

## Task index

| ID | Name | Phase | Est. | Depends |
|----|------|-------|------|---------|
| 305 | AE CI job graph + wall-clock baseline | 0 | 3h | — |
| 306 | False-green contracts in constraints + pattern | 0 | 3h | — |
| 307 | Pre-impl audit `--pre-impl` M86 | 0 | 4h | 305, 306 — **DONE (audit-115)** |
| 308 | CI configurables schema + step plugin interface | 1 | 4h | 307 |
| 309 | `/acp-ci` + `agent/scripts/acp.ci-steps.sh` + AE bodies | 1 | 8h | 308 |
| 310 | Wire routing.yml + discoverability surfaces | 1 | 3h | 309 |
| 311 | E2E `/acp-ci` + `executed_steps` validator | 1 | 5h | 309 |
| 312 | `/acp-pr` with CI gate delegation | 1b | 5h | 311 |
| 313 | E2E `/acp-pr` + wrappers all surfaces | 1b | 3h | 312 |
| 314 | upstream-delta + upgrade-guard + HARD version-update hook | 2 | 5h | 307, **310** |
| 315 | E2E upgrade-guard + fork upgrade docs | 2 | 3h | 314 |
| 316 | Diff-merge `acp.review-scan.sh` FIFOZ↔M83 | 3 | 6h | 307 |
| 317 | feedback-008 rule-verification discipline | 3 | 3h | 316 |
| 318 | feedback-002 residual matrix closeout | 4 | 3h | 307 |
| 319 | Package/wrappers/coverage/integrity-manifest | 4 | 4h | 311, 313, 315, **316** |
| 320 | Consumer upgrade dry-run + FIFOZ notification | 4 | 3h | 314, 319 |
| 321 | v6.31.0 closure + carryover stamps | 4 | 4h | **316, 317**, 318, 319, 320 |

**Total**: ~69h · **estimated_weeks**: 2
