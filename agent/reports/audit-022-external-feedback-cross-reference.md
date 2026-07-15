# Audit Report: External Feedback Cross-Reference — ACP Enhanced Improvement Plan

**Audit**: #022  
**Date**: 2026-06-03  
**Subject**: Cross-reference 9 consolidated recommendations from 4 weeks of ChoreHive production use against ACP Enhanced v6.8.2 implementation

## Summary

Reviewed the consolidated feedback document from 4 weeks of daily ACP Enhanced use on the ChoreHive project (34 milestones, 54 audits, 14 sessions). The feedback identifies a critical insight: **only ~10% of the system surface area sees active use** — 5 of 48 commands, 0 of 14 context protocol executions, 0 skill file loads. This is a system design problem, not a user behavior problem.

Of 9 recommendations (R1–R9), **2 are quick wins we can implement immediately** (light-mode protocol, auto-populate lessons). The remaining 7 have clear implementation paths and are prioritized below.

## Current State vs Recommendations

| R# | Recommendation | Current State | Gap | Priority |
|----|---------------|--------------|-----|----------|
| R1 | Light-mode context protocol | Full 6-step protocol only; 0/14 sessions executed it | Add `light` mode: identity + progress + 3 sessions only (~200 tokens) | **P0** |
| R2 | Auto-populate lessons from key_facts | `/acp-commit` writes sessions.md but never migrates to lessons.md; 18 key_facts captured, 0 migrated | Add Step 2b to /acp-commit: auto-append key_fact to lessons.md with scope + dedup | **P0** |
| R3 | `--team-size` scaffold flag | Bootstrap generates ~310 files unconditionally | Add `--team-size` flag (solo/small/team) | P1 |
| R4 | Prompt wrappers optional | 63 `.github/prompts/` generated unconditionally | Make opt-in via manifest flag | P2 |
| R5 | Resolve three-copy AGENTS/CLAUDE/copilot-instructions | Pre-commit sync hook exists; 3 copies still maintained (2325 + 267 + 267 lines) | Convert CLAUDE.md + copilot-instructions.md to 2-line redirects | P1 |
| R6 | Skills → @-mention pattern | 7 skill files; auto-load by task_type; 0 loads in 14 sessions | Convert to explicit @-mention triggers | P2 |
| R7 | Document manifest vs progress split | Already correct in implementation — manifest has `packages: {}`, progress has all dynamic data | Add documentation table to AGENT.md | P3 |
| R8 | Observability dashboard | Routing ledger exists; no auto-aggregation or weekly trends | Auto-populate `observability:` section in progress.yaml on commit | P1 |
| R9 | Parallelization support | Not implemented | Add `task_type: parallel` with sub-tasks | P2 |

## P0 Actions — Implement Now

### R1: Light-Mode Context Protocol

**Problem**: The full 6-step protocol loads 8–10 files (~800 tokens). Agents skip it because it adds no value when conversation context already exists. In 14 ChoreHive sessions, it was executed 0 times.

**Fix**: Add a `light` mode to `agent/core/routing.yml` and the context-loading protocol in `AGENT.md` / `CLAUDE.md` / `copilot-instructions.md`.

Light mode loads only 3 files (~200 tokens):
1. `agent/core/identity.yml` — project identity
2. `agent/progress.yaml` — current milestone + task (most-consulted file — read in 12/14 sessions)
3. `agent/memory/sessions.md` — last 3 entries

Mode selection:
- `light` = default for all daily development sessions
- `full` = `/acp-init` invocation, architecture sessions, new workspace, new executor

**Files to change**: `agent/core/routing.yml`, `AGENT.md`, `CLAUDE.md`, `.github/copilot-instructions.md`

### R2: Auto-Populate lessons.md from Session key_facts

**Problem**: 18 key_facts accumulated in sessions.md. lessons.md has 10 entries, all from 7 May 2026. Zero migration in 4 weeks. The Correction Protocol never fires because corrections happen in natural chat.

**Fix**: Add Step 2b to the `/acp-commit` protocol:
- On commit, check if session's `key_fact` contains a reusable lesson
- Auto-append to `agent/memory/lessons.md` with: date, scope (inferred from task_type), task_type, priority (auto-detected from keywords), source: session-key-fact
- Check for duplicates before writing

**Files to change**: `AGENT.md` (commit protocol), `CLAUDE.md` (commit protocol), `.github/copilot-instructions.md` (commit protocol)

## P1 Actions — Plan This Week

### R5: Resolve Three-Copy Architecture

Current: AGENT.md (2325 lines), CLAUDE.md (267 lines), copilot-instructions.md (267 lines). Pre-commit hook syncs them.

Proposal: AGENT.md stays canonical. CLAUDE.md + copilot-instructions.md become redirects:
```markdown
# See AGENT.md for the ACP Enhanced context loading protocol.
```

### R3: --team-size Scaffold Flag

Add `--team-size solo` to `scripts/acp-bootstrap.sh` that generates ~30 files instead of ~310.

### R8: Observability Dashboard

Auto-populate `observability:` section in `agent/progress.yaml` on each `/acp-commit` with weekly cost summaries, per-executor stats, and trends.

## P2 Actions — Backlog

- R4: Make prompt wrappers opt-in via manifest flag
- R6: Convert skills to @-mention triggers (preserve taxonomy.yml as catalog)
- R9: Add `task_type: parallel` with sub-task support

## P3 Actions — Documentation Only

- R7: Add manifest-vs-progress table to AGENT.md

## Architectural Strengths Confirmed (DO NOT CHANGE)

The feedback explicitly validates these design decisions:
1. **File-based memory** over database/embedding — competitive advantage for solo/small teams
2. **Routing system** architecture — ahead of LangChain Interpreters pattern
3. **Audit → Implement → Verify loop** — the core loop works, don't break it
4. **`/acp-commit` as sync point** — hook all auto-behaviors here

## Implementation Plan

| Phase | Recommendations | Files Affected | Est. Complexity |
|-------|----------------|---------------|:---:|
| Phase 1 (now) | R1 light mode + R2 auto lessons | routing.yml, AGENT.md, CLAUDE.md, copilot-instructions.md | Low |
| Phase 2 (this week) | R5 redirects + R3 team-size + R8 observability | bootstrap.sh, CLAUDE.md, copilot-instructions.md, progress.yaml schema | Medium |
| Phase 3 (backlog) | R4 optional wrappers + R6 @-mention + R9 parallel | multiple | High |
| Phase 4 (docs) | R7 manifest-vs-progress table | AGENT.md | Trivial |
