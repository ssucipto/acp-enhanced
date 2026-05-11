# Audit Report: Milestone Completion Check + Documentation Update

**Audit**: #13  
**Date**: 2026-05-11  
**Subject**: Full milestone completion verification (M1–M40), gap and bug check, documentation refresh — README, lessons.md, progress.yaml  
**Mode**: Standard  
**Branch**: `mainline`

---

## Summary

Full milestone inventory and documentation audit triggered post-M40. All 40 milestones (M1–M40) confirmed **100% complete**. Four documentation gaps and two lessons gaps found — all fixed within this session. Primary deliverable is an up-to-date README with M38/M39/M40 features documented, corrected command count (58 → 59), and three new high-priority lessons captured for M39/M40 protocol decisions.

One structural gap (G1) is notable: `acp.visualize.md` existed in `agent/commands/` since M25 but had no corresponding `.github/prompts/` or `.opencode/commands/` file, making it invisible to VS Code Copilot and opencode users. Fixed by creating both companion files.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/progress.yaml` | progress | All milestone statuses, next_steps section |
| `README.md` | doc | Command count, feature table, M38/M39/M40 coverage |
| `agent/memory/lessons.md` | memory | M39/M40 lesson coverage |
| `agent/memory/audit-carryovers.md` | memory | Open carryovers check |
| `agent/commands/*.md` | commands | Command count (59 incl. visualize) |
| `.github/prompts/*.prompt.md` | prompts | Prompt count (58 — missing acp-visualize) |
| `.opencode/commands/*.md` | opencode | Opencode count (58 — missing acp-visualize) |
| `agent/routing/tasks/route-014..021.md` | routing | Prior audit gap verification |

---

## Key Findings

| ID | Finding | Severity | Location | Status |
|----|---------|----------|----------|--------|
| G1 | `acp.visualize.md` exists in `agent/commands/` but missing from `.github/prompts/` and `.opencode/commands/` — command invisible to VS Code Copilot and opencode | MEDIUM | `agent/commands/acp.visualize.md` | **FIXED** |
| G2 | README says "58 slash commands" in 3 places; actual count is 59 (with visualize) | LOW | `README.md:82,89,176` | **FIXED** |
| G3 | README note about "6 framework-layer commands defined in prompt/opencode files only" was stale — those 6 commands exist in `agent/commands/` | LOW | `README.md:92` | **FIXED** |
| G4 | README missing M38/M39/M40 features: WAL proactive commit system, git branch awareness, pre-impl audit protocol, audit-carryovers memory layer | LOW | `README.md` (Differences table + prose) | **FIXED** |
| G5 | `progress.yaml` next_steps showed M39 as "FUTURE: M39 — P1 visualizer" (wrong: M39 is now the completed git branch awareness milestone; P1 visualizer is future M41) | LOW | `agent/progress.yaml:5193` | **FIXED** |
| G6 | `lessons.md` missing 3 key lessons from M39/M40: route stamp timing, Phase Summary AC, command-prompt pairing requirement | LOW | `agent/memory/lessons.md` | **FIXED** |

---

## Milestone Completion Status

All planned milestones confirmed 100% complete as of 2026-05-11:

| Milestone | Name | Status | Completed |
|-----------|------|--------|-----------|
| M1 | ACP Commands Infrastructure | ✅ complete | 2026-02-16 |
| M2 | Documentation & Utility Commands | ✅ complete | 2026-05-01 |
| M3 | ACP Package Management System | ✅ complete | 2026-02-25 |
| M4 | ACP Package Development System | ✅ complete | 2026-02-21 |
| M5 | Global Package Installation | ✅ complete | — |
| M6 | ACP Preferences System | ✅ complete | — |
| M7 | Global ACP Project Registry | ✅ complete | — |
| M8 | Experimental Features System | ✅ complete | — |
| M9 | Template Source Files Support | ✅ complete | — |
| M10 | Command Enhancements | ✅ complete | — |
| M11 | ACP Benchmark Suite | ✅ complete | — |
| M12 | Sessions System | ✅ complete | — |
| M13 | Cross-Platform CI | ✅ complete | — |
| M14 | Key File Index System | ✅ complete | — |
| M15 | Clarification Capture System | ✅ complete | — |
| M16 | Design Reference System | ✅ complete | — |
| M17 | Artifact Commands System | ✅ complete | — |
| M18 | Index Semantic Entry Types | ✅ complete | — |
| M19 | Preferences System Bug Fix Sprint | ✅ complete | — |
| M20 | Consistency Cleanup | ✅ complete | — |
| M21 | Functional Readiness Audit | ✅ complete | — |
| M22 | Documentation Accuracy Audit | ✅ complete | — |
| M23 | ACP Enhanced Identity | ✅ complete | — |
| M24 | AGENT.md Completeness | ✅ complete | — |
| M25 | ACP Progress Visualizer (P0 MVP) | ✅ complete | — |
| M26 | Protocol Usability Improvements | ✅ complete | — |
| M27 | Distribution Readiness Fixes | ✅ complete | — |
| M28 | opencode Command Parity | ✅ complete | — |
| M29 | Upstream Integration Audit | ✅ complete | — |
| M30 | Drafts Convention Fix | ✅ complete | — |
| M31 | E2E Test Coverage | ✅ complete | — |
| M32 | AGENT.md Protocol Documentation | ✅ complete | — |
| M33 | Pluggable Driver System | ✅ complete | — |
| M34 | Command Naming Convention | ✅ complete | — |
| M35 | acp-validate.ts Enhancement | ✅ complete | — |
| M36 | saas-platform Benchmark Suite | ✅ complete | — |
| M37 | Audit-007 Fixes — gitignore Completeness | ✅ complete | — |
| M38 | Protocol Knowledge Preservation | ✅ complete | 2026-05-09 |
| M39 | Git Branch Awareness | ✅ complete | 2026-05-11 |
| M40 | Pre-Implementation Audit Protocol | ✅ complete | 2026-05-11 |

**40 of 40 milestones complete (100%).**

---

## Changes Applied

| File | Change |
|------|--------|
| `.github/prompts/acp-visualize.prompt.md` | Created — G1 fix |
| `.opencode/commands/acp-visualize.md` | Created — G1 fix |
| `README.md` | Command count 58→59 (×3), stale framework note fixed, M38/M39/M40 section added |
| `agent/progress.yaml` | next_steps: added M38/M39/M40 done items, renamed FUTURE M39→M41 for P1 visualizer, updated M28 count |
| `agent/memory/lessons.md` | 3 new lessons appended (route stamp timing, Phase Summary AC, command-prompt pairing) |

---

## Git History (relevant recent commits)

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-11 | `396cc1d` | fix(audit): stamp routes 014-017, Phase Summary table, audit-012 |
| 2026-05-11 | `c162092` | chore(memory): acp-commit M39+M40 session |
| 2026-05-11 | `413d27d` | feat(protocol): M40 pre-impl audit protocol |
| 2026-05-11 | `f677583` | feat(protocol): M39 git branch awareness |

---

## Recommendations

1. **M41 planning**: Next milestone opportunity is the P1 visualizer (kanban, GitHub remote, multi-project) — create a feedback/design doc before routing
2. **E2E test gap**: Prior audit noted 37/52 commands have no E2E test file — this remains open technical debt. A dedicated milestone or sprint would clear it systematically
3. **AGENT.md notes count**: `AGENT.md` references "27 scripts" and "48 commands" (2026-05-01 data) — these are now stale (59 commands, 28+ scripts). Consider updating in a maintenance pass
4. **acp.visualize.md prompt gap**: This pattern (command exists, prompt missing) should be prevented by always creating the 3-file set atomically — see lesson added to lessons.md

---

## Audit Carryover Actions

No items added to `agent/memory/audit-carryovers.md`. All 6 gaps fixed within this session. Recommendations 2 and 3 are informational/low-urgency — not severe enough to warrant carryover tracking.
