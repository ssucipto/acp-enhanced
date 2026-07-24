---
handoff_version: 1
handoff_mode: executor
from_executor: claude
to_executor: cursor
date: 2026-07-24
status: completed
supersedes: null
completed_date: 2026-07-24
completed_commit: d080a25
git_branch: develop
git_commit: d080a25
git_remote: git@github-ssucipto:ssucipto/acp-enhanced.git
app_version: 6.28.2
---

# Handoff: M80 E2E Suite Debt Remediation → cursor

**Status: COMPLETED** (2026-07-24) — v6.28.2 shipped; full E2E suite **68/68** green. This handoff is retained for history only.

## Model / executor requirements
- **Cursor Composer 2.5, non-fast** (deterministic multi-file edits across bash + TS + YAML).
- Cross-platform bash discipline (macOS BSD + Linux) — see `agent/core/constraints.yml` `bash_rules`.
- A pre-commit hook regenerates `.github/copilot-instructions.md` + `CLAUDE.md` from `AGENTS.md` — see "What NOT to do".

## Start here (receiving agent)
1. Run project context protocol (CLAUDE.md / AGENTS.md Steps 1–6).
2. Run `/acp-receive @agent/reports/HANDOFF-LATEST.md` OR verify `git rev-parse HEAD` == `e263e9beca512795ba62f0d14ec743d1538a81da`.
3. Read locked decisions below — do not re-litigate.
4. Read `agent/reports/audit-100-m80-pre-impl-readiness.md` — it has verified root causes + exact line numbers for every fix.

## Problem / context
M78 (CodeRabbit optionality, v6.28.0) and M79 (closure-integrity, v6.28.1) shipped. M80 closed carryover **F-M78-01** (7 pre-existing E2E failures). **Result:** full suite **68/68** green at v6.28.2 (`d080a25`).

## Locked decisions (do not re-litigate)
- **ADR-19** — CodeRabbit/Aikido PR-check + findings-import stay GATED (M74–M77). Do not build them.
- **ADR-21** — CodeRabbit optionality foundation is the non-gated slice (shipped in M78). Do not touch its scope.
- **ADR-20** — hooks are a `task_id` array, not booleans.
- **audit-099 lesson** (binding): regression comparison is **assertion-level, not file-level**.
- **audit-100 verdict**: M80 plan is READY; the 7 failures split test-side (task-265) vs behavior/fixture/mode (task-266).
- **F-086-02** is CLOSED (FIFOZ downstream `/acp-version-update` done, developer-confirmed 2026-07-24) — task-267 was removed; do not re-add.

## Assignment
**Implement** — M80 tasks 265, 266, then 268 (closure). Autonomous: `/acp-proceed --complete --yes` is appropriate; all fixes are precise and unblocked.

## Plan reference
- Milestone: `agent/milestones/milestone-80-e2e-debt-carryover-closure.md`
- Tasks:
  - `agent/tasks/milestone-80-e2e-debt-carryover-closure/task-265-test-side-e2e-fixes.md` (route-254) — e2e-workflow light-mode regex, validate-cross-layer `cp package.json` at **3 sites (23/59/74)**, validate-ts placeholder fixtures
  - `agent/tasks/milestone-80-e2e-debt-carryover-closure/task-266-behavior-mismatch-reconcile.md` (route-255) — version exit-code (decide + document; drop duplicate ERR trap), package-info global-info exit, project-update fixture (script already emits "Added tag" at `acp.project-update.sh:227`), post-milestone-sweep **`chmod +x` + `git update-index --chmod=+x`** (script is git mode 100644)
  - `agent/tasks/milestone-80-e2e-debt-carryover-closure/task-268-m80-closure.md` (route-257) — full suite assertion-level check, ship **v6.28.2** (incl. `agent/progress.yaml project.version`), settle F-M78-01 truthfully
- Sequence: 265 ∥ 266 (independent) → 268 (depends on both)

## What NOT to do
- **Do NOT edit `.github/copilot-instructions.md` or `CLAUDE.md` directly** (F-100-03) — they are regenerated from `AGENTS.md` by the pre-commit hook; a direct edit is silently reverted. Fix the e2e-workflow failure **test-side** (broaden the regex to match "light + full modes") or edit `AGENTS.md` source.
- **Do NOT blind-green** — for each failure decide test-fix vs code-fix vs documented-irreducible, with a one-line rationale. Keep assertions behavioral (values/exit codes), never `typeof`-only.
- **Do NOT** touch M74–M77 / CodeRabbit PR-check work (ADR-19 gated).
- **Do NOT** expand scope beyond the 7 F-M78-01 failures.
- **Do NOT** forget `agent/progress.yaml project.version` in the v6.28.2 bump (the exact miss that caused M79) — `acp-validate.ts` now checks it.

## State to update as you work
- `agent/progress.yaml` — milestone M80 (task statuses, counters, current_milestone, recent_work, next_steps)
- `agent/memory/audit-carryovers.md` — F-M78-01 (settle at task-268); F-100-01..05 (verify at task-268)
- `agent/memory/sessions.md` — via `/acp-commit`
- Regenerate `agent/integrity-manifest.yaml` if any `agent/scripts/*.sh` changes (D4 ERROR gate)

## Adjacent context (out of scope for this handoff)
- `agent/reports/audit-099-m78-implementation-gaps.md` — root-cause triage of the 7 failures (read for context)
- `agent/reports/audit-100-m80-pre-impl-readiness.md` — exact fix sites + the auto-sync trap
- `agent/memory/decisions.md` — ADR-19/20/21 (read, do not re-open)

## Return handoff (when you finish or block)
Generate: `/acp-handoff --mode executor --to claude` with:
- Tasks completed / in progress / blocked (265/266/268)
- Commits (SHA list) + whether v6.28.2 tagged
- Full-suite before/after failure counts (assertion-level)
- Any failure settled as documented-irreducible + rationale
- Questions for the planning agent

## Reference chain
| Artifact | Path |
|----------|------|
| Milestone | agent/milestones/milestone-80-e2e-debt-carryover-closure.md |
| Task (test-side) | agent/tasks/milestone-80-e2e-debt-carryover-closure/task-265-test-side-e2e-fixes.md |
| Task (behavior) | agent/tasks/milestone-80-e2e-debt-carryover-closure/task-266-behavior-mismatch-reconcile.md |
| Task (closure) | agent/tasks/milestone-80-e2e-debt-carryover-closure/task-268-m80-closure.md |
| Pre-impl audit | agent/reports/audit-100-m80-pre-impl-readiness.md |
| Root-cause audit | agent/reports/audit-099-m78-implementation-gaps.md |
| Carryovers | agent/memory/audit-carryovers.md (F-M78-01, F-100-01..05) |
| Session | agent/memory/sessions.md (2026-07-24) |
