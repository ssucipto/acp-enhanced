---
handoff_version: 1
handoff_mode: executor
from_executor: claude
to_executor: cursor
date: 2026-07-27
status: completed   # M83 shipped as v6.29.0; superseded as active pointer by handoff-claude-m85-phase2-2026-07-31.md
supersedes: null
git_branch: develop
git_commit: 612c677aba134b5ecce3fc417a83992dd142c8a8
git_remote: git@github-ssucipto:ssucipto/acp-enhanced.git
app_version: 6.28.2
---

# Handoff: M83 Deterministic Local Review Engine → cursor

## Model / executor requirements

- **Composer 2.5, non-fast.** M83 involves cross-file reasoning over bash + Python-in-bash + TypeScript. Per `acp.review.md`, DeepSeek V4 Flash variants are **disqualified** for this class of work.
- Working branch **`develop`** (`identity.yml → git_workflow.default_working_branch`). Never commit to `mainline`.
- Requires locally: `bash 4+`, `python3`, `node`, `npx tsx`, `jq`, `shellcheck`. Optional and **must not be installed for this handoff**: `dupehound`, `gitleaks`.
- macOS + Linux compatibility is a hard constraint (BSD vs GNU `sed`, no `date +%N`).

## Start here (receiving agent)

1. Run the project context protocol — `CLAUDE.md` / `AGENTS.md` Steps 1–6.
2. Run `/acp-receive @agent/reports/handoff-cursor-m83-deterministic-review-2026-07-27.md`, or verify `git rev-parse HEAD` matches `612c677aba134b5ecce3fc417a83992dd142c8a8`.
3. Read the locked decisions below — **do not re-litigate them.**
4. Read [audit-103](audit-103-review-precision-and-standards.md) Part 4 ("Shortcuts Taken") before writing any code. It is the reason this milestone is sequenced the way it is.
5. Start with **task-280**.

## Problem / context

M82 established that CodeRabbit rate-limits after ~2 of 4 CLI chunks, so ACP's own deterministic scanner is the primary review path, not a fallback. Three audits then established that the scanner is not fit for that load.

[audit-102](audit-102-deterministic-review-engine.md) found `acp.review-scan.sh` assigns rather than accumulates path arguments, so the self-review recipe printed in the command doc (`acp.review.md:71`) has only ever scanned `agent/scripts/`. Scanning `scripts/` alone surfaces two genuine HIGH findings that were invisible — including `scripts/acp-bootstrap.sh` using `set -e` with **no `trap ERR`**, in the `curl | bash` bootstrap script.

[audit-103](audit-103-review-precision-and-standards.md) measured the eight shipped rules against seeded fixtures: **1 of 13 defects detected (≈8% recall)**, and on a clean file **2 findings, both false** — one on a code comment, one on a string literal (**0% precision**). The root cause is that the scanner regexes raw lines with no lexing. A second defect compounds it: EH-01 tests `if "try" not in body` as a *substring*, so any async body containing `retry`, `telemetry`, `entry`, or `country` silently disables a HIGH security rule.

None of this was caught because `e2e/acp.review.test.sh` asserts documentation strings and **never executes the scanner** — while `domain.yml:390` simultaneously advertised "acp.review-scan.sh behavioral fixtures" coverage that did not exist.

[audit-104](audit-104-m83-pre-impl-readiness.md) cross-referenced the M83 plan against the live codebase, found 7 gaps, and **all 7 amendments are already applied** in the task files you are receiving (marked inline as `(F-104-NN)`).

## Locked decisions (do not re-litigate)

| Decision | Source | Status |
|---|---|---|
| **Phase 3 is gated on Phases 1b + 1c** — no new rules until lexing + fixture corpus land | audit-103; milestone "Binding sequencing rule" | **LOCKED** |
| dupehound is **wrapped, never reimplemented** — no tree-sitter, no k-gram hashing, no clustering in ACP | 2026-07-27 maintainer discussion; task-292 non-goal | **LOCKED** |
| dupehound uses **detection-as-consent** (`auto` default), with a mandatory explicit-`false` escape hatch | maintainer decision 2026-07-27 | **LOCKED** — ADR-23 in task-291 |
| CH-05 findings are **MEDIUM, non-blocking** in `--ci` | maintainer decision 2026-07-27 | **LOCKED** |
| ACP **never downloads binaries**; assisted install delegates to brew/cargo only, with consent | ADR-23 (task-291) | **LOCKED** |
| ACP **never installs a Rust toolchain** on the user's behalf | ADR-23 (task-291) | **LOCKED** |
| Secrets: **delegate to gitleaks + reuse entropy-scan** — do not grow hand-rolled regexes | audit-103 shortcut #2; task-290 | **LOCKED** |
| ADR-19/21/22 remain in force for CodeRabbit + Aikido; M81 stays gated | ADR-22 (DO NOT re-open) | **LOCKED** |
| M83 depends on nothing from M81 | audit-104 Phase 1 | **LOCKED** |

## Assignment

**Implement.**

Work tasks 280 → 296 in the phase order below. You own code, tests, fixtures, and the task-doc verification checkboxes. Generate a return handoff at any HUMAN gate or blocker.

## Plan reference

- **Milestone**: [agent/milestones/milestone-83-deterministic-review-engine.md](../milestones/milestone-83-deterministic-review-engine.md)
- **Tasks**: `agent/tasks/milestone-83-deterministic-review-engine/task-280…296.md` (17 files)

### Sequence

```
Phase 1   280 ──▶ 281 ─────────────┐   (start here; 281 gates nothing but guards everything)
Phase 1b  282 ──▶ 283 ─────────────┤
Phase 1c  284 ─────────────────────┤──▶ HARD GATE ──▶ Phase 3
Phase 2   285  (independent, any time after 281)
Phase 3   286, 287, 288, 289  (parallel-safe once gate clears)
Phase 3b  290  (after 284)
Phase 4   291 ──▶ 292 ──▶ 293      (291 is an ADR — write it first)
Phase 5   294, 295  (independent)
Phase 6   296  (last — depends on all 16)
```

**Recommended first commit**: task-280 + task-281 together. 281 must **fail** if 280's fixes are reverted — that is its acceptance test.

**Highest-urgency single fix**: task-282's F-103-02 (EH-01 substring). It is a few lines and currently disables a HIGH security rule in production.

## What NOT to do

- **Do not start Phase 3 (tasks 286–289) before 282, 283, and 284 are complete.** This is the milestone's binding rule. Adding ~30 rules onto the unlexed engine multiplies false positives ~4×.
- **Do not implement duplicate detection.** Task-292 wraps the `dupehound` binary. If you find yourself writing a fingerprinting algorithm, stop.
- **Do not grow the SC-01 regex set ad hoc.** Task-290 defines a bounded prefix table plus delegation; anything beyond that is out of scope.
- **Do not install dupehound, gitleaks, or Rust** as part of implementation. Every tool-specific branch needs a *tested absent path*.
- **Do not touch M81** (tasks 270–274) or anything CodeRabbit-related. It is gated on `tests/fixtures/coderabbit-findings-sample.json` under ADR-22.
- **Do not mark a carryover `fixed` without a regression fixture** proving it (binding shortcut #4).
- **Do not accept a doc-assertion test as coverage** for a scanner rule (binding shortcut #5).
- **Do not publish a rule count without measured recall** beside it (binding shortcut #3).
- **Do not re-plan.** If a task looks wrong, generate a return handoff rather than redesigning.
- **Do not commit to `mainline`.**

## State to update as you work

- `agent/progress.yaml` — **M83**: task `status`, `completed_date`, `actual_hours`; milestone `progress` / `tasks_completed`
- `agent/memory/audit-carryovers.md` — settle **F-102-01…08**, **F-103-01…10**, **F-104-01…07** (25 total) as each lands; each needs `fix_applied_date` + `verified_in_audit` + a regression fixture
- `agent/memory/sessions.md` — via `/acp-commit` (write at each phase boundary, not just at the end)
- `agent/memory/decisions.md` — ADR-23 in task-291
- `agent/patterns/local.optional-external-tool.md` — Variant B, amended in task-291
- `agent/schemas/command-e2e-coverage.yaml` — append to `acp.review.suites[]` (task-281)
- `agent/wiki/domain.yml` — new scripts + suites; fix the `:390` coverage claim

Run `npx tsx scripts/acp-validate.ts --memory` before every commit. It is currently **green** — keep it that way.

## Adjacent context (out of scope for this handoff)

Read for background; **do not implement**:

- [audit-101](audit-101-m81-pre-impl-readiness.md) + M81 tasks 270–274 — CodeRabbit integration, gated under ADR-22
- [review-002](review-002-local-thorough-campaign.md) — the M82 campaign. Its "Phase 1 clean" row is unreliable (≈8% recall, half scope); **task-296 annotates it — do not rewrite it**
- [research-acp-vs-coderabbit-aikido-2026.md](research-acp-vs-coderabbit-aikido-2026.md) — buy-detection / build-governance strategy
- `agent/reports/coderabbit-local-2026-07-24/` — M82 CLI artifacts
- F-101-02/03/05/06 — 4 pending carryovers owned by M81, **not** M83

## Return handoff (when you finish or block)

Generate: `/acp-handoff --mode executor --to claude --scope m83-implementation-status`

Include:
- Tasks completed / in progress / blocked
- Commit SHA list
- HUMAN gates hit (expect one at task-291 — ADR-23 amends an active pattern doc and may want maintainer sign-off)
- Measured recall/precision from task-284 once available
- Any task doc that proved wrong in practice — that is planner feedback, not your problem to fix

**Recommended return points**: after Phase 1c (the measurement is the milestone's key checkpoint), and after Phase 3.

## Reference chain

| Artifact | Path |
|----------|------|
| Milestone | `agent/milestones/milestone-83-deterministic-review-engine.md` |
| Tasks (17) | `agent/tasks/milestone-83-deterministic-review-engine/` |
| Gap analysis | `agent/reports/audit-102-deterministic-review-engine.md` |
| Precision measurement | `agent/reports/audit-103-review-precision-and-standards.md` |
| Pre-impl readiness | `agent/reports/audit-104-m83-pre-impl-readiness.md` |
| Carryover ledger | `agent/memory/audit-carryovers.md` |
| Optional-tool pattern | `agent/patterns/local.optional-external-tool.md` |
| Scanner under repair | `agent/scripts/acp.review-scan.sh` |
| Shared emitter | `agent/scripts/acp.integrity-output.sh` |
| 3-gate reference impl | `agent/scripts/acp.coderabbit.sh` |
| Ruleset doc | `agent/commands/acp.review.md` |
| Prior handoff (completed) | `agent/reports/handoff-cursor-m80-e2e-debt-2026-07-24.md` |
