# Milestone 26: ACP Protocol Usability Improvements

**Goal**: Reduce friction and confusion for new and existing ACP users by fixing systemic protocol gaps identified in audit-002 and the critical review of ACP Enhanced.  
**Duration**: ~2 weeks (11–17 total agent-hours across 6 tasks)  
**Dependencies**: M25 (ACP Progress Visualizer) — may run concurrently; no hard dependency  
**Status**: completed

---

## Overview

audit-002 (2026-05-04) and the accompanying critical review identified five systemic gaps in the ACP Enhanced protocol that affect usability without touching the core workflow. These are not feature additions — they are corrections to the self-consistency and predictability of the protocol itself.

The gaps fall into three categories:

### Category A — Self-maintaining documentation fails to maintain itself

The protocol's own task-file status tracking is unreliable:
- `/acp-commit` does not automatically stamp `completed:` on routing task files — agents must do it manually and often forget (BUG-01 pattern)
- Two competing status formats exist (`**Status**: Not Started` markdown vs YAML `completed:`) creating ambiguity about which is authoritative

### Category B — Conceptual framing creates incorrect expectations

The context loading protocol's 2,800-token budget was designed for GPT-3.5-era models (4K–8K context). Modern frontline models (Claude 3.5+, GPT-4o) have 100K–200K context. The budget is now a *discipline practice*, not a technical necessity — but the docs don't make this clear, creating confusion about whether it's a hard limit.

### Category C — Invocation surface is ambiguous

Two command invocation syntaxes coexist without clear routing:
- `/acp-*` — VS Code Copilot slash commands (autocomplete via `.github/prompts/`)
- `@acp.*` — generic agent invocation (reading command files directly)

AGENT.md and README mix both styles with no "which do I use?" guidance. Users on Cursor, Claude Code, or CLI agents have no clear entry point.

The sessions system is described as "advisory-only (no locking)" — two agents can simultaneously edit the same files with no warning, which is increasingly likely as multi-agent workflows grow.

---

## Deliverables

- `agent/commands/acp.commit.md` (or `agent/commands/git.commit.md`) — auto-`completed:` stamping step added
- `agent/commands/acp.task-create.md` — updated task template to include `completed:` YAML field
- `agent/milestones/milestone-26-*.md` template section updated (already correct format)
- `AGENTS.md` — token budget rationale section added ("Why constrain context?")
- `AGENT.md` and `README.md` — "Which invocation syntax?" guidance added
- `agent/commands/acp.sessions.md` — concurrent modification heuristic added

---

## Success Criteria

- [ ] `/acp-commit` workflow includes a step to set `completed: <date>` on routing task files for each task in the session's `tasks:` list
- [ ] `task.template.md` (and any `task-create` output) uses `completed:` YAML frontmatter, not `**Status**:` markdown
- [ ] `AGENTS.md` and `agent/core/constraints.yml` include a rationale comment explaining *why* the token budget exists independent of context window size
- [ ] `AGENT.md` contains a clear "Command Invocation Styles" section distinguishing `/acp-*` (VS Code) from `@acp.*` (generic agents)
- [ ] `README.md` contains the same distinction in the Quick Start or Available Commands section
- [ ] `agent/commands/acp.sessions.md` warns when another session was recently active in the same milestone/task area

---

## Key Files to Create / Modify

| File | Change |
| --- | --- |
| `agent/commands/git.commit.md` | Add Step N: auto-stamp `completed:` on routing task files |
| `agent/commands/acp.sessions.md` | Add concurrent modification warning heuristic |
| `agent/artifacts/task.template.md` or equivalent | Standardize to `completed:` YAML frontmatter |
| `AGENTS.md` | Token budget rationale section |
| `AGENT.md` | Command invocation syntax disambiguation section |
| `README.md` | Command invocation syntax disambiguation (brief) |
| `agent/core/constraints.yml` | Token budget rationale inline comment |

---

## Tasks

| Task | Name | Est. Hours |
| --- | --- | --- |
| task-145 | Auto-`completed:` stamping in `/acp-commit` | 2–3 h |
| task-146 | Standardize task status format (deprecate `**Status**:`) | 3–4 h |
| task-147 | Document token budget as discipline, not technical necessity | 1–2 h |
| task-148 | Resolve `@acp.*` vs `/acp-*` dual-syntax confusion in docs | 1–2 h |
| task-149 | Add concurrent modification warning to sessions system | 2–3 h |
| task-150 | Separate routing task system from milestone task system (`route-NNN.md`) | 2–3 h |

---

## Rationale

These improvements keep ACP Enhanced true to its core purpose: **making the agent context problem solvable by any agent, on any fresh start, with predictable behaviour**. Each task removes a source of unpredictability:

- task-145/146: The protocol can't credibly claim to solve documentation drift if its own task files drift
- task-147: New users misread "2,800 token budget" as a hard constraint and over-restrict themselves
- task-148: Ambiguous invocation surface means users on non-VS Code agents have no clear starting point
- task-149: Silent multi-agent conflicts undermine the reliability the protocol is meant to provide
- task-150: Two "task-NNN" directories with incompatible purposes creates immediate confusion for new agents and contributors
