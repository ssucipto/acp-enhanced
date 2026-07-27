# ACP Enhanced — Product Requirements Document
**Version:** 2.3 (Implemented + Active Roadmap)
**Date:** 2026-05-01 (updated 2026-06-15)
**Author:** Project Owner
**Status:** ✅ Core implemented — current release v6.29.0 (M83 deterministic local review engine shipped; see `agent/progress.yaml` and `CHANGELOG.md` for current milestone state)
**Forked from:** prmichaelsen/agent-context-protocol

> **Note (2026-06-15):** This PRD describes the original vision for ACP Enhanced (May 2026)
> plus the current implementation state. M55 (v6.11.0) delivered `/acp-review` — 77-rule code
> quality and security enforcement. M56 (v6.12.0) delivered `/acp-integrity` v1.0 — 55-rule
> trust scan with 6 deterministic bash scripts. M57 (v6.12.1) added recurring tasks scheduler
> and pre-commit hook framework. M58 is in progress (integrity v2.0 semantic analysis).
> M59–M65 cover CI/critical fixes, gateway truth/test (M64), tracking reconciliation (M65),
> and production-readiness test tracks. See `agent/progress.yaml`, README.md, and CHANGELOG.md
> for current state. Naming: `/acp-` prefix, 9 skills via `@{skill-name}`, routes in
> `agent/routing/tasks/`.

---

## Executive Summary

ACP Enhanced transforms the prmichaelsen agent-context-protocol from a static
documentation-first system into a self-optimising, context-aware development
protocol that reduces AI token costs by 60–85%, eliminates repeated project
re-explanation, and intelligently routes tasks to the most cost-effective model.

It works for three developer personas:
- Persona A: GitHub Copilot Pro only ($10/month)
- Persona B: Multi-model DeepSeek via Continue/Cline (pay-per-token)
- Persona C: Copilot Pro + DeepSeek combined (recommended)

---

## Problem Statement

### What the Original ACP Does Well
- Provides a structured `agent/` directory alongside source code
- `AGENT.md` gives AI assistants persistent project context
- Command pattern (`/acp-init`, `/acp-commit`) is intuitive
- Zero infrastructure — lives entirely in the repository

### What It Fails To Do
1. **Monolithic context** — AGENT.md loads everything for every task, poisoning
   context with irrelevant information and wasting tokens on every call
2. **No task routing** — all tasks hit the same model regardless of complexity
   or cost profile
3. **No persistent memory** — completed session knowledge is discarded entirely
4. **No format optimisation** — prose-heavy markdown uses 30–40% more tokens
   than equivalent YAML/XML for the same information
5. **No cache strategy** — static and dynamic content mixed together, preventing
   prompt cache hits (which deliver 50–97x cost reduction on static prefixes)
6. **No compaction** — context files grow unboundedly and eventually become
   more expensive to load than the value they provide
7. **No cost visibility** — no mechanism to measure or verify savings

---

## Goals

### Primary Goals
- Reduce AI token spend by ≥60% vs baseline (all-Claude, no context structure)
- Eliminate repeated project re-explanation across sessions
- Route tasks to cheapest appropriate model automatically
- Maintain zero external infrastructure dependency (files only)

### Secondary Goals
- Work with Copilot Pro, DeepSeek API, and mixed setups without code changes
- Self-improve over time via correction capture and ledger-driven taxonomy tuning
- Bootstrap in under 4 hours from a cold start
- Daily maintenance overhead under 5 minutes

### Non-Goals
- Building a live agent orchestration server
- Replacing IDE-native features (tab completion, PR review)
- Semantic wiki staleness detection (use date-based freshness instead)
- VS Code extension development (CLI dispatch is sufficient)

---

## Architecture Overview

### Three-Layer Context Model

```
LAYER 1 — CORE (Always loaded, static, prompt-cached)
  agent/core/identity.yml        ~60 tokens
  agent/core/constraints.yml     ~80 tokens
  agent/core/routing.yml         ~40 tokens
  Total Layer 1:                  ~180 tokens, cached after first call

LAYER 2 — SKILLS (Loaded per task type, semi-static)
  agent/skills/ui.md             ~300 tokens
  agent/skills/data.md           ~350 tokens
  agent/skills/deploy.md         ~280 tokens
  agent/skills/gamification.md   ~260 tokens
  agent/skills/auth.md           ~200 tokens
  agent/skills/crosscut.md       ~240 tokens
  Only ONE skill file loaded per task

LAYER 3 — EPHEMERAL (Session-specific, never cached)
  agent/memory/sessions.md       ~500 tokens max (last 3 entries)
  agent/memory/lessons.md        ~200 tokens max (filtered by task_type)
  [active task file]              ~400 tokens average
  [relevant wiki section]         ~600 tokens max (section only, not full file)
  Total Layer 3:                  ~1,200–1,700 tokens per task
```

### Context Budget Per Task Type

| Task Type           | Layer 1 | Layer 2 | Layer 3 | Total  |
|---------------------|---------|---------|---------|--------|
| UI component        |   180   |   300   |  1,200  | ~1,680 |
| Firestore query     |   180   |   350   |  1,400  | ~1,930 |
| Security rules      |   180   |   350   |  1,700  | ~2,230 |
| Gamification logic  |   180   |   260   |  1,500  | ~1,940 |
| Deployment config   |   180   |   280   |  1,300  | ~1,760 |
| Bug fix (simple)    |   180   |   300   |    900  | ~1,380 |
| Architecture design |   180   |   350   |  2,200  | ~2,730 |

Compared to original ACP: 10,000–18,000 tokens per task.
Reduction: 75–88% on input tokens alone.

### Routing Architecture

```
Developer creates task
        ↓
/acp-route classifies task_type
        ↓
taxonomy.yml assigns: executor + context_required
        ↓
        ├─ local-script  → run npm/jest locally, no API call
        ├─ deepseek-v4-flash → dispatch.ts → OpenRouter/DeepSeek
        ├─ gemini-flash  → dispatch.ts → OpenRouter/Google
        └─ claude-sonnet → dispatch.ts → OpenRouter/Anthropic
                                   ↓
                        ledger.md auto-appended
                        sessions.md updated via /acp-commit
```

---

## Complete Directory Structure

```
[repo-root]/
├── AGENTS.md                          ← PRIMARY: auto-loaded by all IDEs
├── CLAUDE.md → AGENTS.md             ← symlink for Claude Code
├── .github/
│   ├── copilot-instructions.md → ../AGENTS.md   ← symlink for Copilot
│   └── prompts/                       ← 69 Copilot slash commands (*.prompt.md)
├── .opencode/commands/                ← 69 opencode slash commands (*.md)
├── .cursor/commands/                  ← 69 Cursor slash commands (*.md)
├── agent/
│   ├── core/                          ← Layer 1: always loaded, cached
│   │   ├── identity.yml
│   │   ├── constraints.yml
│   │   └── routing.yml
│   ├── skills/                        ← Layer 2: one per task session (9 files)
│   │   ├── commands.md
│   │   ├── scripts.md
│   │   ├── schemas.md
│   │   ├── testing.md
│   │   ├── typescript.md
│   │   ├── crosscut.md
│   │   ├── upstream-sync.md
│   │   ├── code-review.md
│   │   └── code-integrity.md
│   ├── memory/                        ← Layer 3: ephemeral, session-specific
│   │   ├── sessions.md
│   │   ├── decisions.md
│   │   ├── patterns.md
│   │   └── lessons.md
│   ├── wiki/                          ← Layer 3: reference, section-loaded
│   │   ├── domain.yml
│   │   ├── integrations.md
│   │   └── architecture.md
│   ├── routing/
│   │   ├── taxonomy.yml
│   │   ├── config.yml
│   │   ├── rules.md
│   │   └── ledger.md
│   └── tasks/                         ← Active task files
│       └── task-template.md
└── scripts/
    ├── acp-bootstrap.sh               ← One-time setup script
    ├── acp-dispatch.ts                ← Routing dispatch script
    └── acp-validate.ts                ← Task frontmatter validator
```

---

## Feature Specifications

### F1 — AGENTS.md (Replaces AGENT.md)

AGENTS.md is the root file loaded by all major IDEs automatically:
- GitHub Copilot reads it natively (highest instruction priority)
- Cursor reads it natively
- Claude Code reads CLAUDE.md (symlinked from AGENTS.md)

AGENTS.md contains ONLY the Context Loading Protocol — it is not a
monolith. All substantive content lives in the layered `agent/` files.

### F2 — Core Layer (Layer 1)

Three small YAML files that form the permanent, cacheable system prefix.
These files NEVER contain dynamic content (no dates, no task IDs).
They are identical on every API call = prompt cache hits every time.

**identity.yml:** Project identity, stack, priorities
**constraints.yml:** Hard rules, context budget limits, anti-patterns
**routing.yml:** Executor identity (which model this session is running on)

### F3 — Skills Layer (Layer 2)

Nine XML-tagged skill files, one per domain. Only the relevant skill
file is loaded per task (invoked via `@{skill-name}`). XML tags chosen over markdown headers for
superior model attention accuracy on structured instructions.

Format: `<skill name="..."><rules>...<patterns>...<anti_patterns>...</skill>`

### F4 — Memory Layer (Layer 3, dynamic)

Four files with strict size budgets enforced by dispatch script:

**sessions.md** — YAML blocks, max 15 entries before auto-compaction
**decisions.md** — ADR log, section-level loading only (by ADR ID)
**patterns.md** — Reusable code patterns, date-stamped, max 60 days active
**lessons.md** — Correction capture, filtered by task_type before loading

### F5 — Wiki Layer (Layer 3, reference)

Three reference files loaded by section only, never wholesale:

**domain.yml** — Entity model in YAML (entities, operations, screens, state)
**integrations.md** — Firebase/GCP/Expo config, XML-tagged by service
**architecture.md** — System map, updated monthly only

### F6 — Routing Layer

**taxonomy.yml** — Task types mapped to executor + context_required
**config.yml** — Model definitions with cost per 1M tokens
**rules.md** — Human-readable routing decisions (AI reads this)
**ledger.md** — Auto-appended by dispatch script after every task

### F7 — Dispatch Script (scripts/acp-dispatch.ts)

The execution engine that makes routing real (not just advisory):
1. Reads task file YAML frontmatter
2. Looks up executor in taxonomy.yml
3. Assembles context: Layer 1 (static) + Layer 2 (skill) + Layer 3 (filtered)
4. Separates static system prompt from dynamic user message (cache optimisation)
5. Calls correct model API via OpenRouter or direct provider
6. Streams response to terminal
7. Captures actual token usage from response headers
8. Appends to ledger.md automatically

### F8 — Prompt Files (.github/prompts/)

Copilot slash commands that replace manual @command invocation.
Each .prompt.md file maps to an ACP operation:
- `/acp-route` — classify and route current task
- `/acp-commit` — end-of-session memory commit
- `/acp-cost-report` — weekly spend summary
- `/acp-memory-sync` — monthly compaction
- `/acp-decide` — create new ADR
- `/acp-wiki-update` — update a wiki file

### F9 — Bootstrap Script (scripts/acp-bootstrap.sh)

One-time setup that scaffolds the entire directory structure,
creates symlinks for all IDEs, initialises empty files with
correct headers, and installs npm dependencies for dispatch script.

Run once: `bash scripts/acp-bootstrap.sh`

---

## Self-Learning Mechanism

The system improves through four automated loops:

### Loop 1 — Correction Capture (triggers: developer corrects AI)
Developer says "that's wrong, log it". AI appends structured entry
to memory/lessons.md. Lessons are filtered by task_type on next load.
Accumulates ~15–25 project-specific corrections in 30 days.

### Loop 2 — Pattern Extraction (triggers: /acp-commit / /acp-commit)
At end of every session, AI checks: "did this session produce a
reusable pattern?" If yes, appends to memory/patterns.md with code ref.
No manual curation — patterns emerge from real work.

### Loop 3 — Taxonomy Tuning (triggers: /acp-cost-report, weekly)
Ledger analysis finds tasks where tokens_actual >> tokens_est (misrouted)
and executor overrides in git history (routing failures).
Outputs 3 specific taxonomy.yml update suggestions.
Developer accepts/rejects in 5 minutes.

### Loop 4 — Context Compaction (triggers: sessions.md > 15 entries)
/acp-commit detects entry count. When > 15, oldest 10 entries are
compressed into a weekly summary. Key facts promoted to patterns.md
or decisions.md. sessions.md stays under 1,500 tokens permanently.

---

## Automation Depth by Feature

| Feature                     | Automation Level | Trigger             |
|-----------------------------|------------------|---------------------|
| AGENTS.md IDE loading       | 100% automatic   | IDE opens project   |
| Task routing classification | 90% automatic    | /acp-route command  |
| API dispatch to right model | 100% automatic   | dispatch.ts script  |
| Ledger token logging        | 100% automatic   | dispatch.ts script  |
| Session memory write        | 95% automatic    | /acp-commit command |
| Correction logging          | 95% automatic    | "log it" instruction|
| Pattern extraction          | 80% automatic    | /acp-commit command |
| Context compaction          | 90% automatic    | /acp-commit command |
| Taxonomy tuning             | 50% automatic    | Weekly review       |
| Wiki updates                | 20% automatic    | Manual + /acp-wiki  |
| ADR creation                | 30% automatic    | /acp-decide command |

---

## Daily Developer Workflow

### Start of Session (0 manual steps)
IDE opens → AGENTS.md auto-loaded → context already present.
No pasting. No explaining. No setup.

### Creating a Task (1 command, 90 seconds)
Type: /acp-route "Add haptic feedback to reward screen"
AI reads taxonomy.yml, assigns executor: deepseek-v4-flash,
creates agent/routing/tasks/task-NNN.md with full frontmatter.
Developer reviews frontmatter (30 seconds), overrides executor if wrong.

### Doing the Work — Persona A (Copilot Pro)
Work normally in VS Code. Copilot has full context via AGENTS.md.
For task classification, the executor field tells you which Copilot
model to select in the dropdown. No dispatch script needed.

### Doing the Work — Persona B/C (DeepSeek)
For in-IDE chat: use Continue.dev with model already selected by task.
For explicit dispatch: npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/task-NNN.md
Output streams to terminal. Ledger updated automatically.

### End of Session (1 command, 90 seconds)
Type: /acp-commit
AI writes session summary to memory/sessions.md.
Checks if patterns emerged. Checks if compaction needed.
Done. Close laptop.

### Weekly (1 command, 10 minutes)
Type: /acp-cost-report
AI reads ledger, outputs spend table + 3 taxonomy update suggestions.
Accept or reject suggestions. Done.

---

## Implementation Phases

### Phase 0 — Bootstrap (Day 1, 3–4 hours)
- [ ] Run acp-bootstrap.sh
- [ ] Run domain extraction prompt on src/
- [ ] Run git log taxonomy mining
- [ ] Write 3 foundational ADRs in memory/decisions.md
- [ ] Validate full loop: /acp-route → task → dispatch → ledger → /acp-commit

### Phase 1 — Core Context (Week 1)
- [ ] Write core/identity.yml, core/constraints.yml, core/routing.yml
- [ ] Write all 6 skills/ files with XML-tagged instructions
- [ ] Write wiki/domain.yml from codebase extraction
- [ ] Write wiki/integrations.md for Firebase + Expo + GCP
- [ ] Test context budget enforcement in dispatch script

### Phase 2 — Memory Layer (Week 2)
- [ ] Implement sessions.md YAML format
- [ ] Implement lessons.md with task_type filtering in dispatch script
- [ ] Implement patterns.md with date-stamped entries
- [ ] Implement auto-compaction trigger in /acp-commit
- [ ] Validate context size stays within budget across all task types

### Phase 3 — Routing Layer (Week 3)
- [ ] Complete taxonomy.yml with all ChoreHive task types
- [ ] Build acp-dispatch.ts with cache-optimised prompt assembly
- [ ] Configure OpenRouter API key + model aliases
- [ ] Validate ledger auto-append with real token counts
- [ ] Run first /acp-cost-report and verify numbers

### Phase 4 — Polish + Automation (Week 4)
- [ ] Add acp-validate.ts GitHub Actions check
- [ ] Add pre-commit hook for /acp-commit reminder
- [ ] Complete all .github/prompts/ slash command files
- [ ] Document persona-specific setup in QUICKSTART.md
- [ ] Retrospective: measure actual savings vs baseline estimate

---

## Success Metrics

| Metric                        | Target          | Measure via         |
|-------------------------------|-----------------|---------------------|
| Token cost reduction          | ≥60% vs baseline| routing/ledger.md   |
| Session context re-injection  | 0 manual pastes | Developer self-report|
| Routing accuracy              | ≥85% correct    | Override count/month|
| /acp-commit compliance        | ≥90% of sessions| sessions.md entry count|
| Monthly maintenance overhead  | ≤30 min/month   | Developer self-report|
| Bootstrap time                | ≤4 hours        | Measured on Day 1   |

---

## Risk Register

| Risk                          | Likelihood | Mitigation                              |
|-------------------------------|------------|-----------------------------------------|
| /acp-commit habit breaks      | High       | Pre-commit hook reminder; 90-second max |
| DeepSeek misroutes complex task| Medium     | override_executor field in frontmatter  |
| Wiki becomes stale            | Medium     | last_verified date + 30-day freshness rule|
| Dispatch script API changes   | Medium     | OpenRouter abstraction shields providers|
| sessions.md grows unbounded   | Low        | Auto-compaction at 15 entries           |
| Context budget exceeded       | Low        | Hard enforcement in dispatch script     |
| Second dev joins, no onboarding| Low       | agent/ IS the onboarding document      |
