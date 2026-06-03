# System Architecture
# Update monthly or when service boundaries change
# Load ONE section at a time — never fully loaded
# last_verified: 2026-06-03

## Command → Script Binding

Commands in `agent/commands/` (63 files) are LLM directives — they tell the agent WHAT to do.
Scripts in `agent/scripts/` (29 files) are bash implementations — they DO the work.
Binding: command frontmatter lists scripts in **Scripts**: field; package.yaml
contents.commands[].scripts array is the authoritative source.

## Context Loading Protocol (v6.8.2)

Two modes defined in `agent/core/routing.yml → context_modes`:
- **Light mode** (default): identity.yml + progress.yaml + last 3 sessions (~200 tokens)
- **Full mode** (/acp-init): all 6 steps including skills, taxonomy, memory, wiki (~800 tokens)
- Mode switching: light→full via /acp-init; full→light via new session
- Mode tracked in routing.yml → context_modes.current

## Package Management

`package.yaml` → defines package contents (commands, scripts, patterns, designs, files)
`agent/manifest.yaml` → tracks installed packages with versions and checksums
Key scripts: acp.package-install.sh, acp.package-update.sh, acp.package-remove.sh

## YAML Parser Chain

acp.yaml-parser.sh → pure-bash AST-based parser (zero dependencies)
  ├─ yaml_parse(file) → build AST
  ├─ yaml_get(file, path) → query via dot-path
  ├─ yaml_set(file, path, value) → update in-place
  └─ sourced by: acp.common.sh → all package/project/preferences scripts

## Routing + Dispatch

taxonomy.yml → task_type → executor + context_required + mention
routing.yml → session config + context_modes + command_suggestions
ledger.md → cost tracking per task
acp-dispatch.ts → TypeScript dispatch engine (OpenRouter API)

## Skills System (v6.8.2, R6)

7 skill files in agent/skills/ — invoked via @{skill-name} in chat:
@{commands} @{scripts} @{schemas} @{testing} @{typescript} @{crosscut} @{upstream}
Catalog in taxonomy.yml → skills_catalog maps mentions to files and triggers.

## Parallel Tasks (v6.8.2, R9)

task_type: parallel — sub-tasks form DAG via depends_on
Schema: agent/schemas/task.schema.yaml
Spawning: acp.proceed.md A3.1 — independent sub-tasks run concurrently

Each command's `**Scripts**:` field lists which bash scripts it invokes.
Example: `acp.package-install.md` binds to `acp.package-install.sh`.

Binding is validated by `/acp-package-validate` Step: Script-Command Binding check.
The `package.yaml` at repo root lists all commands with their `scripts:` arrays.

## Package System Data Flow

```
User runs /acp-package-install github-user/repo
     ↓
acp.package-install.sh
     ↓
  git clone to temp dir
  read package.yaml from repo
  validate against package.schema.yaml
  copy commands/ → project/agent/commands/
  copy scripts/ → project/agent/scripts/
  copy patterns/ → project/agent/patterns/
  write to project/agent/manifest.yaml (tracking)
```

## YAML Parser Dependency Chain

```
All scripts that read/write YAML:
  source acp.yaml-parser.sh    (provides yaml_get, yaml_set, yaml_get_array)
  source acp.common.sh         (provides higher-level helpers using the parser)

acp.yaml-validate.sh is standalone — does NOT source yaml-parser (different purpose)
```

## Global ACP Directory (~/.acp/)

```
~/.acp/
  manifest.yaml     ← globally installed packages
  projects.yaml     ← registered ACP projects (from /acp-project-create)
  packages/         ← globally installed package files
  sessions.yaml     ← concurrent agent sessions (from /acp-sessions)
```

## ACP Enhanced Layer Structure

```
LAYER 1 — CORE (always loaded, ~180 tokens, prompt-cached)
  agent/core/identity.yml
  agent/core/constraints.yml
  agent/core/routing.yml

LAYER 2 — SKILLS (one per task, ~400 tokens)
  agent/skills/commands.md    ← command doc writing
  agent/skills/scripts.md     ← bash shell scripting
  agent/skills/schemas.md     ← YAML schema design
  agent/skills/testing.md     ← E2E and unit tests
  agent/skills/typescript.md  ← dispatch/validate TS
  agent/skills/crosscut.md    ← docs, AGENT.md, README

LAYER 3 — EPHEMERAL (session-specific, filtered, ~1,200 tokens)
  agent/memory/sessions.md    (last 3 entries only)
  agent/memory/lessons.md     (filtered by task_type)
  agent/memory/decisions.md   (loaded by ADR ID only)
  agent/wiki/domain.yml       (one section at a time)
  agent/wiki/architecture.md  (one section at a time)
```

## Context Loading Protocol — Step 1b Git Branch Safety Check

Added in v6.5.0 (M39). Step 1b is a **conditional** step that runs between Step 1 (Load Core)
and Step 2 (Identify Task Domain) when `agent/core/identity.yml` contains a `git_workflow:` block.

**Purpose**: Prevent accidental direct commits to the production branch by halting the session
before any task steps run.

**Trigger condition**: `git_workflow:` block present and uncommented in `identity.yml`.

**Flow**:
1. Run `git branch --show-current`
2. Compare result to `git_workflow.default_working_branch`
3. If on `default_working_branch` → proceed normally
4. If on `production_branch` → output warning, **STOP** — developer must switch branch
5. If on `feature/*`, `fix/*`, or other → note in session, proceed normally
6. If `git_workflow` not defined → skip silently (no-op)

**Safe no-op by default**: `git_workflow:` is commented out in the identity.yml template.
Projects that don't configure it skip Step 1b entirely. No behavioral change for existing projects.

## Context Loading Protocol — Step 4.4 Audit Carryover Check

Added in v6.6.0 (M40). Step 4.4 is a sub-step that runs at the end of Step 4 (Load Working Memory)
to surface unresolved audit findings from previous sessions before any work begins.

**Purpose**: Prevent re-discovering fixed or stale issues that were already found in prior audits.

**File read**: `agent/memory/audit-carryovers.md` (if it exists)

**Flow**:
1. If file does not exist → skip silently (no-op for projects without audits)
2. Read `carryovers:` list from the file
3. If all entries are `status: fixed` or list is empty → skip silently
4. If any entries have `status: pending` → output before starting any work:
   ```
   ⚠️ [ACP] Open audit carryovers: [N] pending items require attention.
   [finding_id]: [one-line finding description]
   Review before starting to avoid re-discovering fixed or stale items.
   ```

**Carryover file lifecycle**:
- **Written by**: `/acp-audit` (end of any audit with actionable findings — standard AND --pre-impl)
- **Read by**: Step 4.4 at every session start
- **Updated by**: Agent — set `status: fixed` and `fix_applied_date` when fix applied
- **Verified by**: Next audit — set `verified_in_audit` when fix confirmed
- **Removed**: Safe to delete entry once `verified_in_audit` is set

## Pre-Implementation Audit Protocol (v6.6.0)

Added in v6.6.0 (M40). The `/acp-audit --pre-impl` flag triggers a 4-phase structured readiness
check before implementation begins. Run before any coding task to catch invisible gaps.

**Purpose**: Catch field name mismatches, missing imports, stale carryovers, and planning gaps
that would cause bugs or rework once coding starts.

**Invocation**: `/acp-audit --pre-impl route-NNN` or `/acp-audit --pre-impl <subject>`

**4 Phases** (execute after standard investigation, before generating report):

| Phase | Name | Checks |
|-------|------|--------|
| 1 | Plan Correctness | Route/task file completeness, files_affected accuracy, open blockers |
| 2 | Code Cross-Reference | Field names, enum values, import paths, HTTP methods vs. actual codebase |
| 3 | Carryover Check | Reads `carryovers:` from audit-carryovers.md; surfaces pending as blocking |
| 4 | Operational Completeness | Version bump planned? Wiki update planned? Route file exists? |

**Verdict**: READY or BLOCKED — single-sentence summary of overall readiness.

**Report**: Adds `## Pre-Implementation Readiness` section to standard audit report.
Standard report sections + readiness section are both included in output.

## Session Memory Write Protocol (v6.4.13+)

sessions.md is treated as a WAL (write-ahead log) — written at the **moment of discovery**, not
deferred to session end. Context overflow is silent: a session can terminate at any point without
a final turn, permanently losing any knowledge not written to disk.

**7 proactive write triggers** (any one fires → write sessions.md immediately):

| Trigger | Action |
|---------|--------|
| Milestone phase completes | Write sessions.md entry NOW |
| Audit report created (`audit-N.md` committed) | Capture findings in lessons.md |
| Architectural decision made | Create ADR in decisions.md |
| New reusable pattern found | Append to patterns.md |
| Correction given by developer | Append to lessons.md (Correction Protocol) |
| Context approaching overflow | Write sessions.md BEFORE overflow |
| git commit touching >5 files | Treat as phase boundary → write sessions.md |

**Corollary**: `/acp-commit` is NOT an end-of-session-only command. It runs at every phase boundary.
The session-end `/acp-commit` finalises a session that already has most entries written.

## Dispatch Script Flow (Persona B/C)

```
npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/task-NNN.md
     ↓
  Read task frontmatter (gray-matter)
  Look up executor in taxonomy.yml
  Assemble system prompt (Layer 1 + skill) — STATIC for caching
  Assemble user message (sessions + lessons + task) — dynamic
  Enforce 6,500 token budget
  Update agent/core/routing.yml with executor
  Call OpenRouter API (streaming)
  Append row to agent/routing/ledger.md
```
