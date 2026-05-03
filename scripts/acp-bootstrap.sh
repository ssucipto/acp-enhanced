#!/bin/bash
# =============================================================================
# ACP Enhanced Bootstrap Script
# Run once from your project root: bash scripts/acp-bootstrap.sh
# =============================================================================

set -e
trap 'echo "Bootstrap failed at line $LINENO — check output above for details." >&2; exit 1' ERR

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== ACP Enhanced Bootstrap ===${NC}"
echo "Setting up Agent Context Protocol Enhanced in: $(pwd)"
echo ""

# --- 1. Directory Structure ---
echo -e "${YELLOW}[1/7] Creating directory structure...${NC}"
mkdir -p agent/core
mkdir -p agent/skills
mkdir -p agent/memory
mkdir -p agent/wiki
mkdir -p agent/routing
mkdir -p agent/tasks
mkdir -p .github/prompts
mkdir -p scripts
echo -e "${GREEN}✓ Directories created${NC}"

# --- 2. Create AGENTS.md from template ---
echo -e "${YELLOW}[2/7] Creating AGENTS.md context loading protocol...${NC}"
if [ ! -f AGENTS.md ]; then
  # Try to copy from ACP Enhanced scripts/ if available alongside this script
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "${SCRIPT_DIR}/AGENTS.md" ]; then
    cp "${SCRIPT_DIR}/AGENTS.md" AGENTS.md
    echo -e "${GREEN}✓ AGENTS.md copied from ACP Enhanced template${NC}"
  else
    # Fallback: create minimal template for user to populate
    cat > AGENTS.md << 'MD'
# ACP Enhanced — Agent Context Protocol

> This file is auto-loaded by GitHub Copilot, Cursor, and Claude Code.
> Do NOT add project content here. This file contains ONLY the context
> loading protocol. All content lives in agent/ subdirectories.

---

## Who You Are

You are an AI coding assistant working on this project under the
Agent Context Protocol (ACP) Enhanced framework. You have structured
access to persistent project memory, a task routing system, and a
self-improving correction layer.

<!-- TODO: Add 2-3 sentences here describing what this project is -->

---

## Context Loading Protocol

**Run this protocol at the START of every session, before any task.**

### Step 1 — Load Core (always, every session)
Read these files in order. They are small and always relevant:
1. `agent/core/identity.yml` — project identity and stack
2. `agent/core/constraints.yml` — hard rules and context budget
3. `agent/core/routing.yml` — which executor you are this session

### Step 2 — Identify Task Domain
From the developer's request, determine the task_type by reading:
`agent/routing/taxonomy.yml`

Match the request to the closest task_type entry.
If uncertain between two types, choose the one with the higher-risk executor.

### Step 3 — Load Skill (one file only)
Based on task_type, load EXACTLY ONE skill file from `agent/skills/`.
Create one skill file per domain relevant to your project (e.g. `backend.md`, `ui.md`, `deploy.md`).
Map task types → skill files in `agent/routing/taxonomy.yml`.

Do NOT load multiple skill files unless the task explicitly spans two domains.

### Step 4 — Load Working Memory (filtered)
1. Read last 3 entries from `agent/memory/sessions.md` only
2. Read `agent/memory/lessons.md` — filter to entries where
   `trigger` matches current task_type OR `priority: high`
   Load maximum 5 lesson entries.

### Step 5 — Load Reference (section only, if needed)
Only if the task requires it:
- Domain model / entity definitions → load relevant section of `agent/wiki/domain.yml`
- Architecture or integration details → load relevant section of `agent/wiki/architecture.md`
- Architecture decisions → load specific ADR from `agent/memory/decisions.md` by ID

Add your own wiki files under `agent/wiki/` as the project grows.

**Never load an entire wiki file. Load one section at a time.**

### Step 6 — Confirm and Proceed
Before starting the task, output one line:
`[ACP] Loaded: [files loaded] | est. [N] tokens | executor: [executor value]`
Then proceed with the task.

---

## Context Budget Hard Limits

Enforce these limits. If exceeded, drop lower-tier content first:
- Layer 1 (core): max 300 tokens
- Layer 2 (skills): max 500 tokens
- Layer 3 (memory + wiki): max 2,000 tokens
- Total session context: max 2,800 tokens (before task content)

---

## Correction Protocol

When the developer corrects your output, IMMEDIATELY:
1. Append to `agent/memory/lessons.md`:
```yaml
- date: [today]
  task_type: [current task type]
  mistake: [what went wrong in one sentence]
  correction: [correct behaviour]
  priority: [high if critical, normal otherwise]
```
2. Acknowledge: "[ACP] Correction logged to lessons.md"

---

## Session Commit Protocol (/acp-commit)

When developer runs /acp-commit or /acp-commit:
1. Write session summary to `agent/memory/sessions.md` in YAML format:
```yaml
- date: [today]
  executor: [executor used]
  tasks: [list of task IDs]
  done: [kebab-case list of completed items]
  deferred: [item → task-ID for each deferred item]
  key_fact: [single most important thing learned, if any]
```
2. Check: did this session produce a reusable code pattern? If yes, append to
   `agent/memory/patterns.md`
3. Check: did you make an architectural decision? If yes, prompt:
   "An architectural decision was made: [decision]. Create ADR? (y/n)"
4. Count entries in sessions.md. If > 15, auto-compact oldest 10 entries:
   - Extract all key_facts → check if any belong in patterns.md
   - Replace the 10 entries with a single weekly summary block
5. Confirm: "[ACP] Session committed. [N] entries in sessions.md."
MD
    echo -e "${GREEN}✓ AGENTS.md created from embedded template${NC}"
  fi
fi

# Wire AGENTS.md to other IDEs
# Use cp (not symlinks) — symlinks break on Windows and WSL cross-drive setups
mkdir -p .github/prompts
if [ ! -f CLAUDE.md ]; then
  cp AGENTS.md CLAUDE.md
  echo -e "${GREEN}✓ CLAUDE.md created (Claude Code auto-load)${NC}"
fi
if [ ! -f .github/copilot-instructions.md ]; then
  cp AGENTS.md .github/copilot-instructions.md
  echo -e "${GREEN}✓ .github/copilot-instructions.md created (Copilot priority 1)${NC}"
fi
echo -e "${YELLOW}  Note: CLAUDE.md and copilot-instructions.md are copies of AGENTS.md.${NC}"
echo -e "${YELLOW}  When you update AGENTS.md, re-run: cp AGENTS.md CLAUDE.md && cp AGENTS.md .github/copilot-instructions.md${NC}"

# --- 3. Core Layer Files ---
echo -e "${YELLOW}[3/7] Creating core layer files...${NC}"

cat > agent/core/identity.yml << 'YAML'
# DO NOT add dynamic content to this file (no dates, no task IDs)
# This file is prompt-cached by the LLM API after first call
# TODO: Fill in your project details below

project: YOUR_PROJECT_NAME
type: YOUR_PROJECT_TYPE      # e.g. web-app, mobile-app, api, cli-tool, library
description: >
  One or two sentences describing what this project does.

stack:
  - primary: YOUR_MAIN_LANGUAGE  # e.g. TypeScript, Python, Go
  - framework: YOUR_FRAMEWORK    # e.g. React, FastAPI, gin
  - backend: YOUR_BACKEND        # e.g. PostgreSQL, Firebase, None
  - deployment: YOUR_DEPLOY      # e.g. Vercel, AWS Lambda, Docker

team: solo-developer   # or: small-team, open-source
priorities:
  - code-quality
  - correctness
  - maintainability

repo: github.com/YOUR_USERNAME/YOUR_REPO
YAML

cat > agent/core/constraints.yml << 'YAML'
# Hard rules — never violate these
# DO NOT add dynamic content to this file
# TODO: Add project-specific code rules below

rules:
  - never_load_all_wiki_files: load one section at a time
  - never_load_full_sessions: last 3 entries only
  - never_load_all_lessons: filter by task_type first
  - never_skip_acp_commit: required at end of every session
  - never_reopen_closed_adrs: respect DO NOT re-open flags

context_budget:
  layer1_max_tokens: 300
  layer2_max_tokens: 500
  layer3_max_tokens: 2000
  total_max_tokens: 2800
  warning_threshold: 0.80

# Add project-specific coding rules here, for example:
# code_rules:
#   - prefer_immutable_data: true
#   - require_error_handling: true
YAML

cat > agent/core/routing.yml << 'YAML'
# Updated per session by dispatch script or manually
# DO NOT mix static and dynamic content in the same file

session:
  executor: unset        # updated by acp-dispatch.ts at runtime
  model: unset           # updated by acp-dispatch.ts at runtime
  persona: unset         # A (copilot-only), B (deepseek-only), C (mixed)
YAML

echo -e "${GREEN}✓ Core layer files created${NC}"

# --- 3b. Skill Files (copy from ACP Enhanced if available) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACP_SKILLS_SRC="${SCRIPT_DIR}/../agent/skills"
if [ -d "${ACP_SKILLS_SRC}" ]; then
  cp "${ACP_SKILLS_SRC}"/*.md agent/skills/
  echo -e "${GREEN}✓ Skill files copied from ACP Enhanced (agent/skills/)${NC}"
else
  # Fallback: create a minimal stub so AGENTS.md Step 3 doesn't fail silently
  cat > agent/skills/backend.md << 'SKILL'
<skill name="backend">
<rules>
- TODO: Add project-specific coding rules here (error handling, naming, patterns)
- Each rule should be one line, actionable, and specific to your stack
</rules>
<patterns>
TODO: Add reusable code snippets / templates specific to your framework
</patterns>
<anti_patterns>
TODO: Add things the agent should NEVER do in this codebase
</anti_patterns>
</skill>
SKILL
  echo -e "${YELLOW}✓ Skill stub created (agent/skills/backend.md) — populate with your project rules${NC}"
fi

# --- 4. Memory + Wiki Stubs ---
echo -e "${YELLOW}[4/7] Creating memory and wiki stubs...${NC}"

cat > agent/memory/sessions.md << 'MD'
# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

MD

cat > agent/memory/decisions.md << 'MD'
# Architecture Decision Records (ADR Log)
# Loaded by section (ADR ID) only — never fully loaded
# Add entries via /acp-decide command

MD

cat > agent/memory/patterns.md << 'MD'
# Reusable Code Patterns
# Populated automatically by /acp-commit when patterns are identified
# Format: date-stamped YAML entries, max 60 days active

MD

cat > agent/memory/lessons.md << 'MD'
# Correction Log — Filtered by task_type before loading
# Populated automatically when developer says "log it" or "wrong, log this"
# Max 5 entries loaded per session, filtered to current task_type + priority:high

MD

cat > agent/wiki/domain.yml << 'YAML'
# Domain Entity Model
# TODO: Describe the core entities your project works with
# Run /acp-init to auto-populate from your source code

entities: []     # Core domain objects (User, Order, Product, etc.)
operations: []   # Key operations grouped by category
modules: []      # Main modules or packages
YAML

cat > agent/wiki/integrations.md << 'MD'
# Service Integrations — XML-tagged sections, load one section at a time
# TODO: Replace with your actual external service config. Delete unused sections.

<database>
  type: YOUR_DB_TYPE  # e.g. PostgreSQL, MongoDB, Firebase
  host: YOUR_HOST
  schemas: []        # list main schemas/collections
</database>

<auth>
  provider: YOUR_AUTH_PROVIDER  # e.g. Auth0, Firebase Auth, custom JWT
  flows: []                      # e.g. email-password, oauth-google
</auth>

<external_apis>
  # List any third-party APIs your project calls
  # - name: Stripe
  #   base_url: https://api.stripe.com
  #   env_var: STRIPE_SECRET_KEY
</external_apis>
MD

cat > agent/wiki/architecture.md << 'MD'
# System Architecture
# Update monthly or when service boundaries change
# last_verified: YYYY-MM-DD (update this date when you verify)

last_verified: $(date +%Y-%m-%d 2>/dev/null || echo 'YYYY-MM-DD')

## System Map
[Describe your high-level architecture here — major components and how they connect]

## Service Boundaries
[What does each service/module own? What are the contracts between them?]

## Key Data Flows
[Describe the critical paths through the system, e.g. user request → DB → response]

## External Dependencies
[List services this project depends on and why]
MD

echo -e "${GREEN}✓ Memory and wiki stubs created${NC}"

# --- 5. Routing Layer ---
echo -e "${YELLOW}[5/7] Creating routing layer...${NC}"

cat > agent/routing/config.yml << 'YAML'
version: "1.0"
default_model: claude-sonnet

models:
  claude-sonnet:
    provider: anthropic
    model_id: anthropic/claude-sonnet-4-5
    cost_input_per_1m: 3.00
    cost_output_per_1m: 15.00
    use_for: [architecture, security, complex-business-logic, multi-service]

  deepseek-v4-flash:
    provider: deepseek
    model_id: deepseek/deepseek-v4-flash
    cost_input_per_1m: 0.14
    cost_output_per_1m: 0.28
    use_for: [crud, boilerplate, ui-component, types, simple-bugfix]

  deepseek-v4-pro:
    provider: deepseek
    model_id: deepseek/deepseek-v4-pro
    cost_input_per_1m: 0.435
    cost_output_per_1m: 0.87
    use_for: [reasoning, complex-algorithm, security-review]

  gemini-flash:
    provider: google
    model_id: google/gemini-2.0-flash-exp
    cost_input_per_1m: 0.075
    cost_output_per_1m: 0.30
    use_for: [gcp-native, google-cloud, data-analysis]

  local-script:
    provider: local
    cost_input_per_1m: 0.00
    cost_output_per_1m: 0.00
    use_for: [test-run, lint, build, format, git-operations]

complexity_thresholds:
  low:    { max_files: 3,  tokens_est: 6000  }
  medium: { max_files: 6,  tokens_est: 12000 }
  high:   { max_files: 99, tokens_est: 25000 }
YAML

cat > agent/routing/taxonomy.yml << 'YAML'
# Project Task Taxonomy
# Maps task types to executor + required context
# TODO: Add task types specific to your project's domains

task_types:

  # ── FEATURES ──────────────────────────────────────────────
  feature-small:
    executor: fast-model
    complexity: low
    context_required: [memory/sessions.md]
    tokens_est: 4000
    skill: backend  # TODO: change to your relevant skill file

  feature-large:
    executor: smart-model
    complexity: high
    context_required: [wiki/architecture.md, wiki/domain.yml, memory/decisions.md]
    tokens_est: 20000
    skill: backend

  # ── BUG FIXES ─────────────────────────────────────────────
  bug-fix-simple:
    executor: fast-model
    complexity: low
    context_required: [memory/sessions.md]
    tokens_est: 3000
    skill: backend

  bug-fix-architectural:
    executor: smart-model
    complexity: high
    context_required: [wiki/architecture.md, memory/decisions.md, memory/sessions.md]
    tokens_est: 15000
    skill: backend

  # ── TESTS ─────────────────────────────────────────────────
  test-write:
    executor: fast-model
    complexity: low
    context_required: [active-task-only]
    tokens_est: 4000
    skill: backend

  # ── ARCHITECTURE ──────────────────────────────────────────
  architecture-design:
    executor: smart-model
    complexity: high
    context_required: [wiki/architecture.md, wiki/domain.yml, memory/decisions.md]
    risk: high
    tokens_est: 20000
    skill: backend

  # ── DEPLOYMENT / CI ───────────────────────────────────────
  deploy-config:
    executor: fast-model
    complexity: low
    context_required: [wiki/integrations.md]
    tokens_est: 4000
    skill: backend

  ci-pipeline:
    executor: smart-model
    complexity: medium
    context_required: [wiki/integrations.md, memory/decisions.md]
    tokens_est: 10000
    skill: backend

  # ── DATA SCHEMA ───────────────────────────────────────────
  data-schema:
    executor: smart-model
    complexity: medium
    context_required: [wiki/domain.yml, memory/decisions.md]
    risk: high
    tokens_est: 8000
    skill: backend

  # ── DOCS / CROSS-CUTTING ──────────────────────────────────
  documentation:
    executor: fast-model
    complexity: low
    context_required: [memory/sessions.md]
    tokens_est: 3000
    skill: backend
YAML

cat > agent/routing/rules.md << 'MD'
# Routing Rules — Human-readable version of taxonomy.yml
# AI reads this when taxonomy.yml match is ambiguous
# TODO: Customize these rules for your project's executors and risk levels

## Priority Order (when task spans multiple domains)
1. Security concern present → always smart-model regardless of other factors
2. Task touches core data schema or auth → smart-model
3. Task touches ≤ 3 files AND no business logic → fast-model
4. Tests only → fast-model or local-script
5. Default → smart-model

## Override Triggers
- Developer adds `override_executor: [model]` to task frontmatter → use that model
- Task has `risk: critical` → escalate to smart-model regardless of other rules
- Task is in lessons.md with routing correction → follow lessons.md correction

## Ambiguity Resolution
When uncertain between two executors:
- Prefer cheaper option for output quality risk < medium
- Prefer more capable option for output quality risk ≥ medium
MD

# Initialise ledger with header
cat > agent/routing/ledger.md << 'MD'
# ACP Cost Ledger
# Auto-appended by scripts/acp-dispatch.ts after every task
# Never edit manually

| Date | Task ID | Task Type | Executor | Input Tokens | Output Tokens | Cost USD | Notes |
|------|---------|-----------|----------|-------------|---------------|----------|-------|
MD

echo -e "${GREEN}✓ Routing layer created${NC}"

# --- 6. Prompt Files ---
echo -e "${YELLOW}[6/7] Creating Copilot prompt files...${NC}"

cat > .github/prompts/acp-route.prompt.md << 'MD'
---
mode: agent
description: Classify and route a task to the cheapest appropriate executor
---

Given the task description: ${input}

1. Read `agent/routing/taxonomy.yml` and `agent/routing/rules.md`
2. Match to the closest task_type
3. If uncertain, read `agent/routing/rules.md` ambiguity resolution section
4. Get next task ID from the highest existing ID in `agent/routing/tasks/`
5. Create `agent/routing/tasks/task-[ID].md` with complete YAML frontmatter
6. Append a pending row to `agent/routing/ledger.md`
7. Output: "Task [ID] created | executor: [X] | est. [N] tokens | [file path]"
MD

cat > .github/prompts/acp-commit.prompt.md << 'MD'
---
mode: agent
description: End-of-session memory commit — run before closing VS Code
---

Perform ACP session commit:

1. Ask: "Which task IDs were completed this session?" if not obvious from context
2. Write YAML session entry to `agent/memory/sessions.md`:
   - date, executor, tasks completed, done items (kebab-case), deferred items,
     key_fact (most important thing learned today, if any)
3. Check: did this session produce a reusable code pattern?
   If yes → append to `agent/memory/patterns.md` with date and code_ref
4. Check: was an architectural decision made?
   If yes → prompt "Create ADR for [decision]? (y/n)"
5. Count entries in sessions.md. If > 15 → compact oldest 10 entries:
   a. Extract key_facts → check if any belong in patterns.md or decisions.md
   b. Replace 10 entries with single weekly summary block
6. Mark completed tasks as done in their agent/routing/tasks/ files
7. Confirm: "[ACP] Session committed | [N] entries in sessions.md | [compacted? y/n]"
MD

cat > .github/prompts/acp-cost-report.prompt.md << 'MD'
---
mode: agent
description: Weekly token spend report with taxonomy improvement suggestions
---

Generate ACP cost report:

1. Read `agent/routing/ledger.md` — all entries
2. Group by executor and calculate: total tokens, total cost, task count
3. Calculate: what would same tasks cost if all used claude-sonnet?
4. Output table:
   | Executor | Tasks | Input Tokens | Output Tokens | Actual Cost | If All Claude |
5. Find tasks where tokens_actual > tokens_est × 1.5 (likely misrouted)
6. Find rows where executor differs from taxonomy default (manual overrides)
7. Output 3 specific suggestions for taxonomy.yml updates
8. Output: "Total saved this period: $[X] vs all-Claude baseline"
MD

cat > .github/prompts/acp-memory-sync.prompt.md << 'MD'
---
mode: agent
description: Monthly memory compaction — run first Friday of each month
---

Perform ACP monthly memory sync:

1. Read `agent/memory/sessions.md`
2. Find all weekly summary entries older than 4 weeks
3. Compress them into a monthly summary block:
   - month, features_shipped, architectural_changes (ADR IDs), recurring_issues,
     net_new_patterns count
4. Read `agent/memory/patterns.md`
5. Flag entries older than 60 days as stale (add `stale: true` flag)
6. Read `agent/wiki/architecture.md` — check last_verified date
7. If last_verified > 30 days ago → output: "⚠ architecture.md needs verification"
8. Output: "[ACP] Memory sync complete | sessions.md: [N] entries | [N] stale patterns flagged"
MD

cat > .github/prompts/acp-decide.prompt.md << 'MD'
---
mode: agent
description: Create a new Architecture Decision Record
---

Create a new ADR for the decision: ${input}

1. Get next ADR ID from `agent/memory/decisions.md`
2. Prompt for (or infer from context):
   - Why this decision was needed
   - What options were considered
   - What was decided
   - What the consequences are
   - What would trigger re-opening this decision
3. Append to `agent/memory/decisions.md`:
   ## ADR-[ID] | [date] | [title]
   **Status:** Accepted
   **Context:** ...
   **Options considered:** ...
   **Decision:** ...
   **Consequences:** ...
   **DO NOT re-open** unless [trigger].
4. Confirm: "ADR-[ID] created: [title]"
MD

cat > .github/prompts/acp-wiki-update.prompt.md << 'MD'
---
mode: agent
description: Update a wiki file section after architectural changes
---

Update wiki for: ${input}

1. Determine which wiki file is affected:
   - Domain entity/operation changes → `agent/wiki/domain.yml`
   - External service/integration changes → `agent/wiki/integrations.md`
   - Service boundary/architecture changes → `agent/wiki/architecture.md`
2. Read the current content of the relevant section
3. Update ONLY the affected section — do not rewrite other sections
4. Update `last_verified` date in the file header
5. Confirm: "[ACP] Wiki updated: [file] | section: [section] | [date]"
MD

cat > .github/prompts/acp-init.prompt.md << 'MD'
---
mode: agent
description: Bootstrap domain knowledge from codebase — run ONCE on new project
---

Bootstrap ACP domain knowledge from this codebase:

1. Scan the project source files to understand the structure
2. Extract and write to `agent/wiki/domain.yml`:
   - entities: core domain objects (data models, types, interfaces)
   - operations: major functions/endpoints grouped by category
   - modules: main packages or modules in the project
3. Identify any external service dependencies (APIs, databases, cloud services)
4. Write placeholders to `agent/wiki/integrations.md` for each external dependency:
   - service name and type
   - environment variable names used (values redacted)
   - any config file references found
5. Fill in `agent/core/identity.yml` stack fields based on actual tech stack found
6. Confirm: "[ACP] Domain extraction complete | [N] entities | [N] modules | [N] external services"
MD

echo -e "${GREEN}✓ Prompt files created${NC}"

# --- 7. Install agent/ commands, scripts and schemas ---
echo -e "${YELLOW}[7/7] Installing ACP commands, scripts and schemas (agent/ directory)...${NC}"

if [ -d "agent/commands" ] && [ -d "agent/scripts" ]; then
  echo -e "${GREEN}✓ agent/ already present (running from local ACP Enhanced clone)${NC}"
else
  INSTALL_URL="https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh"
  echo "Downloading ACP installer..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$INSTALL_URL" | bash
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$INSTALL_URL" -O - | bash
  else
    echo -e "${YELLOW}WARNING: curl and wget not found.${NC}"
    echo "Install agent/ manually after bootstrap:"
    echo "  curl -fsSL $INSTALL_URL | bash"
  fi
fi
echo ""

# --- Summary ---
echo ""
echo -e "${BLUE}=== Bootstrap Complete ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit AGENTS.md — fill in the 'Who You Are' section with your project description"
echo "  2. Edit agent/core/identity.yml — fill in project name, stack, repo URL"
echo "  3. Run /acp-init in Copilot chat to extract domain knowledge from your source files"
echo "  4. Write 3 ADRs: /acp-decide for your top architectural decisions"
echo "  5. Edit agent/routing/taxonomy.yml — replace generic task types with your project's domains"
echo "  6. Run first task: /acp-route \"[your first task description]\""
echo ""
echo "Copilot slash commands available:"
echo "  /acp-init        Bootstrap domain knowledge"
echo "  /acp-route       Create and route a new task"
echo "  /acp-commit      End-of-session memory commit"
echo "  /acp-decide      Create architecture decision record"
echo "  /acp-cost-report Weekly spend report"
echo "  /acp-memory-sync Monthly compaction"
echo "  /acp-wiki-update Update wiki after changes"
echo ""
echo -e "${GREEN}Done. ACP Enhanced is ready.${NC}"
