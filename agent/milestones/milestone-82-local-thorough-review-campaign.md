# Milestone 82: Local Thorough Review Campaign (CodeRabbit CLI + ACP)

<!-- @acp.meta.milestone
topic: coderabbit, cli, local-review, acp-review, thorough, chunked, ops
description: Layered thorough local review of ACP Enhanced — ACP /acp-review plus chunked CodeRabbit CLI diffs; triage to carryovers
status: planned
updated: 2026-07-24
@acp.meta.end -->

**Planned version**: none (ops/review campaign — ship fixes as follow-up patches if needed)  
**Status**: planned (0/5)  
**Estimated effort**: ~12h (5 tasks)  
**Source**: Maintainer request 2026-07-24 — thorough codebase review using local repo + CodeRabbit CLI  
**Depends on**: M80 (green suite/CI), CodeRabbit CLI installed & authenticated locally  
**Does not replace**: M81 fixture gate (ADR-22 still requires sanitized **PR-comment** export)

## Constraint (binding)

**CodeRabbit CLI reviews git diffs only — it does not audit an entire repository in one shot.**

A “thorough” local campaign therefore means:

1. **ACP native** `/acp-review` — full deterministic rule set (already overdue on `weekly-code-review`).
2. **CodeRabbit CLI chunked** — multiple scoped reviews (`--dir` + `--base` / `--base-commit`) so each run stays under CLI file limits.
3. **Triage** — merge findings into `audit-carryovers.md` (live shape); dedupe against ACP review.
4. **Honest artifacts** — CLI `--agent` JSON is useful for triage and *may* inform M81 importer design, but **does not alone** satisfy ADR-22’s PR findings fixture.

## Goal

Produce a dated, reproducible local review campaign report for ACP Enhanced, with actionable carryovers, using tools already on the maintainer’s machine — without waiting for M81 unblocking.

## Scope boundary

| In scope (M82) | Out of scope |
|----------------|--------------|
| Sync `develop` ↔ `mainline` before review | Inventing a whole-repo CodeRabbit mode |
| Overdue weeklies (`/acp-review`, `/acp-integrity`) | Replacing `/acp-review` with CodeRabbit |
| Chunked CLI playbook + execution | Installing CodeRabbit GitHub App on this repo (optional later) |
| Triage → carryovers (live ledger shape) | Shipping `acp.findings-import.sh` (M81) |
| Campaign report under `agent/reports/` | Claiming ADR-22 gate satisfied by CLI-only sample |
| Optional *annotated* CLI sample note for M81 (gap documented) | Aikido / M76 / M77 |

## Anti-shortcut guardrails

1. Do not stage a synthetic “all files changed” commit on `develop`/`mainline` just to force a full-repo CLI scan.
2. Phase 1 ACP rules stay authoritative; CodeRabbit findings are additive.
3. Carryover entries match **live** ledger fields (no invented `source:` fields).
4. Scrub secrets/PII before any findings land in-repo.
5. Do not change `current_milestone` away from M81 until M81 closes or maintainer explicitly switches.

## Suggested CLI chunk map

| Chunk | Command sketch |
|-------|----------------|
| Scripts (TS) | `coderabbit review --dir scripts --base origin/mainline --agent` *(or `--base-commit <tag>` when no diff)* |
| Agent bash | `coderabbit review --dir agent/scripts --base-commit <window> --agent` |
| E2E / tests | `coderabbit review --dir e2e --base-commit <window> --agent` (+ `tests/`) |
| CI workflows | `coderabbit review --dir .github/workflows --base-commit <window> --agent` |
| Recent product surface | `coderabbit review --base v6.27.0 --agent` (M78–M81 era) |

When a chunk has **no diff**, use a **historical window** (`--base-commit` between two tags/SHAs that touch that tree) — never invent vendor schema.

If CLI skips for “too many files”, narrow further (`--dir` subpaths) per CLI suggestions.

## Build order

| Phase | Task | Title | Est. |
|-------|------|-------|------|
| **0** | task-275 | Sync branches + run overdue ACP weeklies | 2h |
| **1** | task-276 | Document chunked CodeRabbit CLI playbook | 2h |
| **2** | task-277 | Execute chunked CLI reviews; capture `--agent` JSON | 4h |
| **2** | task-278 | Triage → carryovers; dedupe vs ACP review | 3h |
| **3** | task-279 | Campaign report + optional CLI sample note for M81 | 1h |

**Dependencies:** 275 → 276 → 277 → 278 → 279.

## Verification gates (M82 closure)

- [ ] `weekly-code-review` + `weekly-integrity-scan` `last_run` / `next_due` updated
- [ ] Playbook committed under `agent/wiki/` (or reports)
- [ ] ≥3 CLI chunk runs captured under `agent/reports/coderabbit-local-<date>/` (sanitized)
- [ ] Carryovers appended for accepted findings; schema validates
- [ ] Campaign report published; next_steps updated
- [ ] Explicit note: ADR-22 fixture still required for M81 270+

## Relationship to M81

M81 remains `current_milestone`. M82 is a **parallel ops track**. If CLI JSON helps design the importer, attach a *gap note* — PR export remains the gate artifact.
