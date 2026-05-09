# System Architecture
# Update monthly or when service boundaries change
# Load ONE section at a time — never fully loaded
# last_verified: 2026-05-04

## Command → Script Binding

Commands in `agent/commands/` are LLM directives — they tell the agent WHAT to do.
Scripts in `agent/scripts/` are bash implementations — they DO the work.

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
