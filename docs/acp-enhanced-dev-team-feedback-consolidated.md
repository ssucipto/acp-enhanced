# ACP Enhanced — Consolidated Development Team Feedback

**Compiled by**: ChoreHive (solo-developer, React Native + FastAPI + Firestore)
**Original Feedback Author**: `ssucipto/ChoreHive`
**Audit Number**: #50 (research-backed cross-reference)
**Compilation Date**: 3 June 2026
**Period Covered**: 4 weeks of daily use (7 May – 3 June 2026)
**Scale**: 34 milestones, 54 audits, 14 sessions
**Versions tested**: Base ACP v5.41.0 → v7.2.1 → **ACP Enhanced v6.8.1 (current)**

> **Purpose**: This document consolidates `acp-enhanced-team-feedback.md` and `audit-50-research-backed-review.md` into a single, gap-resolved, deduplicated reference for the ACP Enhanced development team. Gaps, inconsistencies, and newly surfaced recommendations from the audit cross-reference are called out explicitly.

---

## Gap & Inconsistency Audit (Meta-Review)

Before the consolidated recommendations, this section documents discrepancies, omissions, and misalignments found between the two source documents.

### 🔴 Critical Gaps

| Gap | Where It Appears | Impact |
|-----|-----------------|--------|
| **R6 recommendation changed without updating R6 in feedback doc** | feedback doc says "auto-deprecation"; audit-50 says "convert to @-mention pattern" — these are materially different | Dev team may implement auto-deprecation when @-mention is the right solution |
| **Finding 6 (Anthropic 6 Workflows) not included in feedback doc** | audit-50 only — parallelization gap and orchestrator-workers gap not surfaced | Two architectural gaps (parallelization, orchestrator-workers) are invisible to dev team |
| **Finding 4 (Mention-based skills) only partially added to feedback doc** | audit-50 calls it out explicitly; feedback doc keeps the "auto-deprecation" framing | @-mention as the preferred pattern is missing from the main feedback |
| **R8 (Observability) present in feedback doc but absent from audit scorecard** | Audit scorecard table does not include R8 | Scorecard is incomplete — R8 is a substantive new recommendation |

### 🟡 Inconsistencies

| Inconsistency | Document A | Document B |
|--------------|-----------|-----------|
| **R6 label** | feedback doc: "Skill File Auto-Deprecation" | audit-50: "Skills → @-mention (LangChain Interpreters pattern)" — fundamentally different approach |
| **File-Based Memory classification** | feedback doc: listed under "What Works Brilliantly #3" | audit-50: recommends elevating to a formal standalone recommendation |
| **R2 scope** | feedback doc: proposes key_fact → lessons migration with priority inference | audit-50: recommends adding scope fields + dedup + composite scoring (recency/importance weighting) — broader scope |
| **R8 priority** | feedback doc: P1 | audit-50 (ACP dev team table): not listed at all in the dev team recommendations section |
| **Routing system assessment** | feedback doc: no explicit mention of routing being "ahead of industry" | audit-50: explicitly calls it a strength and recommends mention-based routing as enhancement |

### 🟢 Confirmed Alignments (no action needed)

- R1 (Light Mode), R3 (--team-size), R4 (Prompt Wrappers), R5 (AGENTS/CLAUDE merge), R7 (Manifest/Progress split) are consistent across both documents
- Version history and metrics are consistent
- 6.8.1 delta analysis is consistent (R2 and R5 partially addressed, all others unaddressed)
- Research citations in both documents point to the same primary sources

---

## Executive Summary

ACP Enhanced's core loop — **audit → plan → implement → update → commit** — is genuinely excellent and measurably improves development velocity. The file-based, zero-dependency architecture (markdown + YAML, git-tracked) is a competitive advantage over SQLite/embedding-based alternatives.

However, **only ~10% of the system surface area sees active use**. 43 of 48 commands were never invoked. The context loading protocol was executed 0 of 14 sessions. Skill files were loaded 0 times. This is not a user behaviour problem — it is a system design problem: the system generates too much surface area for its target users, and the protocols were designed for cold-start sessions that rarely occur in daily use.

ACP Enhanced v6.8.1 partially addressed 2 of 7 original recommendations (R2, R5). This document provides 9 consolidated recommendations (R1–R8 plus a new R9), prioritised and research-backed.

---

## Version History

| Version | Date | What Changed |
|---------|------|-------------|
| Base ACP 5.41.0 | 7 May 2026 | Initial scaffold (~310 files) |
| Base ACP 7.2.1 | 3 June 2026 | Upstream: AGENT.md docs, templates, scripts, `.gitignore` — no recommendation addressed |
| **ACP Enhanced 6.8.1** | 3 June 2026 | Routing layer, cost tracking, ADR creation, memory sync, wiki update, opencode commands, AGENTS.md sync hook |

### 6.8.1 Delta: Recommendation Status

| R# | Recommendation | Status After 6.8.1 |
|----|---------------|-------------------|
| R1 | Light-mode context protocol | ❌ Unaddressed |
| R2 | Auto-populate lessons from key_facts | 🟡 Partial — `/acp-memory-sync` added but no key_fact → lessons migration |
| R3 | `--team-size` flag for scaffold | ❌ Unaddressed |
| R4 | Prompt wrappers optional | ❌ Unaddressed |
| R5 | Merge AGENTS.md / CLAUDE.md | 🟡 Partial — pre-commit sync hook added, three-copy architecture remains |
| R6 | Skills → @-mention (revised from "auto-deprecation") | ❌ Unaddressed |
| R7 | Document manifest vs progress split | ❌ Unaddressed |
| R8 | Observability dashboard | ❌ Unaddressed (new in this doc) |
| R9 | Parallelization support | ❌ Unaddressed (new in this doc) |

---

## What Works Brilliantly

### 1. Audit → Implement → Verify Cycle

The structured audit command is ACP Enhanced's killer feature. 54 audit reports over 4 weeks caught security gaps (IDOR vulnerabilities, missing auth guards), correctness bugs (missed-count inflation, week-boundary errors), design inconsistencies, and test coverage gaps. Audits are narrow and deep, not broad and shallow. The `--output` flag makes them persistent and reviewable.

### 2. progress.yaml as Single Source of Truth

A single 3200-line YAML file tracks all milestones, tasks, recent work, next steps, and blockers. Milestone progress percentages auto-compute from task completion counts. The `recent_work` section with dated entries provides a chronological narrative. In 12 of 14 sessions, `progress.yaml` was the agent's first read — more consistently consulted than any formally specified protocol file.

### 3. File-Based Architecture (Formal Competitive Advantage)

> **Audit-50 upgrade**: This was listed under "What Works Brilliantly" in the original feedback. Based on the research cross-reference, it should be elevated to a formal architectural recommendation. ACP Enhanced's markdown + YAML approach is objectively superior to CrewAI's SQLite + vector stores and Mem0's embedding APIs for solo/small teams.

Specific advantages:
- **Git-diffable**: Every change is visible in PRs
- **Human-readable**: No special tooling to inspect state
- **Zero infrastructure**: No database, no server, no migration scripts
- **Portable**: Survives environment changes (machine switches, CI contexts)
- **Zero-cost**: No API calls for embedding or storage

**Recommendation**: Lean into this as a differentiator in ACP Enhanced's documentation and marketing. Explicitly compare against CrewAI/Mem0 approaches.

### 4. Command Files as Self-Documenting Scripts

The agent directive pattern reliably causes agents to follow numbered step-by-step instructions. The pattern of explicit "Actions" and "Expected Outcome" blocks per step is clear and executable across all tested models.

### 5. Session Key Fact Capture

The `/acp-commit` protocol's `key_fact` field reliably captures high-signal, durable lessons every session. Over 14 sessions, 18 key facts were captured covering IDOR guard patterns, Python mock gotchas, Expo deep-link handlers, IANA timezone pitfalls, and React Native Hermes freeze root causes. The problem is that these never migrate to `lessons.md` — see R2.

### 6. ACP Enhanced Routing System — Ahead of Industry

> **New finding from audit-50**: The routing system (`taxonomy.yml` + `skills/`) is conceptually ahead of LangChain's Interpreters/Skills pattern (May 2026). However, the current auto-load approach adds context overhead. See R6 for the recommended conversion to mention-based routing.

---

## Metrics: ChoreHive Usage Data

| Metric | Value |
|--------|-------|
| Days of active use | 29 (7 May – 3 June 2026) |
| Development sessions | 14 |
| Milestones (32 complete, 1 blocked, 1 in progress) | 34 |
| Audit reports generated | 54 |
| Commands actively used | 5 of 48 (10%) |
| Commands never invoked | 43 of 48 |
| Prompt wrappers used | 7 of 57 (12%) |
| Task files created | 148 |
| Task files actively referenced | ~30 (M29–M34 only) |
| Lessons captured (manual) | 12 (frozen since 7 May) |
| Key facts captured (auto) | 18 (7 May – 3 June) |
| Key facts migrated to lessons.md | **0** |
| Skills loaded per session | **0** |
| Context Loading Protocol executions | **0 of 14 sessions** |
| Backend tests at start → now | 424 → 839 |
| Frontend tests at start → now | 0 → 217 |

---

## Consolidated Recommendations

### R1 (P0): Add a "Light Mode" Context Loading Protocol

**Research backing**: Anthropic — Building Effective Agents (Dec 2024) Principle 1: "Start with simple patterns; add complexity only when needed." Cursor Rules (2026): auto-attach by glob + description-based relevance, not a fixed protocol. CrewAI loads memory selectively by scope, not universally.

**Problem**: The 6-step full protocol was designed for cold-start sessions. In daily use, the platform already injects auto-attached instructions, conversation summaries, and session memory. In 14 ChoreHive sessions, the full protocol executed **zero times** — agents skip it because 5 extra file reads add no value when context already exists. Token waste: ~500/session, ~7,000 over 14 sessions.

**Gap note**: The full protocol also notably excludes `progress.yaml`, which agents read in 12 of 14 sessions anyway. Light mode should formalise this.

#### Mode Selection Logic

| Scenario | Mode |
|----------|------|
| First session in a new workspace | `full` |
| `@acp.init` invocation | `full` |
| Architecture / design session | `full` |
| New agent/executor joining project | `full` |
| Daily development (any task) | `light` |
| Bug fix (≤ 3 files) | `light` |
| Code review / audit | `light` |
| CRUD / boilerplate / UI component | `light` |

#### Proposed Implementation (routing.yml)

```yaml
context_modes:
  light:
    steps:
      - load_identity       # agent/core/identity.yml
      - load_progress       # agent/progress.yaml (most-consulted file)
      - load_recent         # last 3 entries from agent/memory/sessions.md
      - confirm             # output: [ACP] light | executor | last session date
    budget_limit_tokens: 800

  full:
    steps:
      - load_core           # identity.yml + constraints.yml + routing.yml
      - load_taxonomy       # routing/taxonomy.yml
      - load_skill          # one matching skill file
      - load_memory         # last 3 sessions + filtered lessons (max 5)
      - load_reference      # wiki section (only if task requires it)
      - confirm             # output budget + executor
    budget_limit_tokens: 2800

mode_selection:
  default: light
  auto_full_triggers:
    - command: acp.init
    - first_session: true
    - task_type: [architecture-design, data-schema]
```

#### Measurable Impact (from ChoreHive data)

| Metric | Full Protocol | Light Mode |
|--------|:---:|:---:|
| Files loaded per session | 8–10 | 3 |
| Context tokens (layers 1–3) | ~800 | ~200 |
| Stale context risk | High | Low |
| progress.yaml formally loaded | No | **Yes** |

---

### R2 (P0): Auto-Populate lessons.md from Session key_facts

**Research backing**: CrewAI Hierarchical Memory (2026) — auto-consolidation, composite scoring (semantic 0.5 + recency 0.3 + importance 0.2), LLM-driven deduplication and merge.

**Problem**: 18 key_facts accumulated in sessions.md. Lessons.md has 12 entries, all from 7 May (day of scaffold). Zero migration has occurred in 4 weeks. The Correction Protocol also never fires because developer corrections happen in natural chat, not via a formal `/acp-correction` command.

**Audit-50 expansion (gap in original feedback doc)**: The original R2 proposed basic key_fact → lessons migration. Audit-50 recommends going further:
- Add `scope` field to lessons (e.g., `backend-python`, `frontend-react-native`, `testing`)
- Auto-deduplication on save to prevent duplicate lessons
- Composite scoring: recency decay + importance flag
- This brings ACP Enhanced's memory system to CrewAI parity

#### Proposed Implementation

Extend `/acp-commit` Step 2:

```
2a. Did this session produce a reusable code pattern?
    → If yes, append to agent/memory/patterns.md with date + code_ref

2b. Does this session's key_fact contain a reusable lesson?
    → If yes, append to agent/memory/lessons.md:
      - date: [today]
        scope: [inferred from task_type: backend-python | frontend-react-native | testing | ...]
        task_type: [from session]
        lesson: [key_fact text, first paragraph]
        priority: [high if CRITICAL/SECURITY/BROKEN/CRASH/CORRUPTION/never/must/always/IDOR, else normal]
        source: session-key-fact
    → Check for duplicates before writing (fuzzy match on lesson text)

2c. Was an architectural decision made?
    → Prompt: "Create ADR for [decision]? (y/n)"
```

---

### R3 (P1): Add `--team-size` Flag to Scaffold

**Research backing**: Industry-wide trend toward minimal scaffolding. Anthropic: "Start simple." Vercel and Cursor both ship minimal defaults with opt-in expansion.

**Problem**: `acp init` generates ~310 files regardless of project scale. For a solo developer, ~30 files cover all active use cases.

```
acp init --team-size solo     # ~30 files
acp init --team-size small    # ~80 files (2–5 devs, current default)
acp init --team-size team     # ~310 files (5+ devs, full surface area)
```

**Solo preset excludes**: skills/, taxonomy.yml, 40 unused commands, 49 unused prompts, package/project/artifact/clarification/version/design subsystems.

---

### R4 (P2): Make Prompt Wrappers Optional

**Problem**: 57 `.github/prompts/` wrapper files, each a thin redirect to the actual command file. Agents in all 14 sessions read command files directly — wrappers were never consulted.

**Proposal**: Opt-in via manifest flag:

```yaml
# agent/manifest.yaml
prompts:
  generate_wrappers: false   # default: false
  wrapper_path: .github/prompts/
```

Rationale: Wrappers are platform-specific (some platforms require prompt files per command). Make them opt-in, not default.

---

### R5 (P1): Resolve AGENTS.md / CLAUDE.md Three-Copy Architecture

**Status in 6.8.1**: 🟡 Partial — pre-commit hook auto-syncs on commit. Three-copy architecture remains.

**Problem**: AGENTS.md (118 lines) and CLAUDE.md (111 lines) define the same protocol. With the 6.8.1 sync hook, `copilot-instructions.md` is a third copy. Each platform reads one file — three copies is an anti-pattern per Cursor (`.cursorrules`), Copilot (`.github/copilot-instructions.md`), and Claude (`CLAUDE.md`) conventions.

**Proposal**: Generate `AGENTS.md` as canonical. Create `CLAUDE.md` as a 2-line redirect:

```markdown
# Claude Code Configuration
# See AGENTS.md for the ACP Enhanced context loading protocol.
```

Scaffold output should explicitly guide the choice:
```
✓ Created AGENTS.md (primary context protocol)
✓ Created CLAUDE.md → references AGENTS.md
  Delete CLAUDE.md if your platform only reads AGENTS.md.
```

---

### R6 (P2): Convert Skills from Auto-Load to @-Mention Pattern

> **Inconsistency resolved**: The original feedback doc recommended "auto-deprecation" of skill files. Audit-50 research cross-reference found this framing is incorrect — the right solution is converting to **mention-based explicit invocation**, not deprecation. This is a material change in recommendation direction.

**Research backing**: LangChain Interpreters + Skills (May 2026) — tasks are routed to specialised sub-agents via explicit @-mention, not auto-load. Cursor Rules (2026): description-based relevance, not automatic context injection.

**Problem**: Three skill files exist (`backend.md`, `frontend.md`, `eas-deploy.md`) — 0 loads across 14 sessions. Domain knowledge lives in `copilot-instructions.md` (160 lines, actively maintained, auto-attached). Skills are a second copy that nobody maintains and nobody reads.

**Proposal**: Convert skill files to mention-based triggers:
- `@backend` in chat → load `agent/skills/backend.md`
- `taxonomy.yml` becomes a **catalog** (discoverable reference), not a routing table
- Skills are not auto-loaded; they are invoked explicitly when the user needs specialised context

**New enhancement from audit-50**: Add a `rubric:` field to task frontmatter for agent self-evaluation after task completion (from LangChain Rubrics, June 2026).

---

### R7 (P3): Document manifest.yaml vs progress.yaml Split

**Status**: Low priority — the split is already clear in practice. Needs documentation only.

| File | Purpose | Update Frequency |
|------|---------|-----------------|
| `agent/manifest.yaml` | Static project identity, stack, constraints | Rarely (team changes, new platform) |
| `agent/progress.yaml` | Live tracking: milestones, tasks, recent work, blockers | Daily (`@acp-update`, `@acp-proceed`) |

Move all dynamic fields (version, status, current_milestone) from manifest.yaml to progress.yaml if not already there. Manifest should be "set once and forget."

---

### R8 (P1): Expand Routing Ledger into Observability Dashboard

> **Gap in audit-50 scorecard**: R8 was not included in the audit-50 scorecard table, though it appeared in the feedback doc's priority table. This is now resolved — R8 is a substantive recommendation with full research backing.

**Research backing**: LangSmith Engine + SmithDB (2026) — agent trace data layer, cost/latency dashboards, structured observability. LangChain Deep Agents include built-in tracing. The industry is moving from "what did the agent do?" to "why, and at what cost?"

**Problem**: The routing ledger tracks task → executor → tokens → cost as a static table. No latency tracking. No error rates. No per-session summaries. `/acp-cost-report` exists but requires manual invocation.

**Proposal**: Auto-populate an observability section in `progress.yaml` on each `/acp-commit`:

```yaml
observability:
  this_week:
    sessions: 5
    total_tokens: 125000
    total_cost_usd: 0.34
    avg_latency_ms: 4200
    top_executor: deepseek-v4-pro
  by_executor:
    deepseek-v4-pro:
      tasks: 12
      total_tokens: 98000
      total_cost_usd: 0.28
      error_rate: 0.02
  weekly_trend:
    - week: "2026-W23"
      cost_usd: 0.34
    - week: "2026-W22"
      cost_usd: 0.18
```

`/acp-cost-report` becomes auto-triggered weekly, not manual. ACP Enhanced's existing per-model pricing in `config.yml` provides the data — only aggregation is missing.

---

### R9 (P2 — NEW): Add Parallelization Support

> **Source**: audit-50 Finding 6. Completely absent from the original feedback doc. Surfaced by cross-referencing Anthropic's 6 agent workflows.

**Research backing**: Anthropic — Building Effective Agents (Dec 2024) defines 6 agent workflows. ACP Enhanced maps to 4 of 6. The two gaps are:

| Missing Workflow | Description | Use Case |
|----------------|-------------|----------|
| **Parallelization** | Multiple sub-tasks run concurrently in separate agent instances | "Add tests for endpoints A, B, and C" — independent, parallelisable |
| **Orchestrator-workers** | Orchestrator agent decomposes a task, dispatches to worker agents | Large refactors spanning multiple domains |

**Proposal**: Add `task_type: parallel` with sub-tasks that can run concurrently:

```yaml
# task with parallel sub-tasks
task:
  id: M34-T01
  title: Add endpoint tests
  task_type: parallel
  sub_tasks:
    - id: M34-T01a
      title: Tests for /api/chores
    - id: M34-T01b
      title: Tests for /api/members
    - id: M34-T01c
      title: Tests for /api/households
```

This is a medium-complexity addition that would make ACP Enhanced complete against Anthropic's workflow taxonomy.

---

## Priority Summary

| Priority | R# | Recommendation | Research Backing | 6.8.1 Status |
|:--------:|----|---------------|-----------------|:---:|
| **P0** | R1 | Light-mode context protocol | Anthropic Principle 1, Cursor auto-attach | ❌ |
| **P0** | R2 | Auto-populate lessons (with scope + dedup + scoring) | CrewAI Hierarchical Memory 2026 | 🟡 Partial |
| **P1** | R3 | `--team-size` scaffold flag | Industry-wide minimal scaffolding trend | ❌ |
| **P1** | R5 | Resolve AGENTS/CLAUDE three-copy architecture | Cursor/Copilot/Claude single-file conventions | 🟡 Partial |
| **P1** | R8 | Observability dashboard in progress.yaml | LangSmith Engine + SmithDB 2026 | ❌ |
| **P2** | R6 | Skills → @-mention (not auto-deprecation) | LangChain Interpreters + Skills May 2026 | ❌ |
| **P2** | R9 | Parallelization + orchestrator-workers support | Anthropic 6 Workflows (Dec 2024) | ❌ |
| **P2** | R4 | Prompt wrappers opt-in | Agents read command files directly | ❌ |
| **P3** | R7 | Document manifest vs progress split | CrewAI config-vs-state separation | ❌ |

---

## Architectural Strengths to Preserve

These are explicitly called out because they represent correct decisions that should not be changed under pressure to "simplify" or "modernise":

1. **File-based memory over database/embedding** — Zero dependencies, git-trackable, human-readable. Do not add SQLite, vector stores, or embedding APIs.
2. **Routing system design** — The taxonomy.yml + skills/ architecture is conceptually ahead of LangChain's Interpreters pattern. Preserve the architecture; convert invocation to @-mention.
3. **Audit → Implement → Verify loop** — The core loop is working. Do not break it chasing surface area reduction.
4. **`/acp-commit` as the sync point** — All automatic behaviours (lessons migration, observability update, memory compaction) should hook into the existing commit protocol, not create new session entry points.

---

## ChoreHive-Specific Cleanup Actions

The following are ChoreHive internal cleanup actions surfaced by audit-50. Included here for completeness, not as ACP Enhanced team action items.

- Delete `.opencode/commands/` (57 files for a platform not in use)
- Run `/acp-memory-sync` with scope metadata added to sessions
- Retire or convert `agent/skills/` files to @-mention triggers
- Add latency tracking to session commit

---

*ChoreHive — Family chore coordination app*
*React Native + Expo Router / FastAPI + Firestore*
*github.com/ssucipto/ChoreHive*
