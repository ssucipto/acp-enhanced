#!/bin/bash
# =============================================================================
# ACP Enhanced Bootstrap Script
# Run from your project root: bash scripts/acp-bootstrap.sh
# Or: curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/scripts/acp-bootstrap.sh | bash
# =============================================================================
# ⚠️  Safety: Before the curl pipe, cd to your target project directory first.
#    This script will create files in $(pwd) and cannot be undone automatically.
# =============================================================================

set -e
set -o pipefail

# ── Argument Parsing (must be before pre-flight checks) ─────────
TEAM_SIZE="small"
GENERATE_PROMPTS="false"
GENERATE_OPENCODE="true"
SKIP_WARNING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --team-size)
            TEAM_SIZE="$2"
            shift 2
            ;;
        --generate-prompts)
            GENERATE_PROMPTS="true"
            shift
            ;;
        --no-opencode)
            GENERATE_OPENCODE="false"
            shift
            ;;
        --yes|-y)
            SKIP_WARNING=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# ── Cleanup Definition (must be before trap) ────────────────────
_BOOTSTRAP_START_DIR="$(pwd)"
cleanup_on_failure() {
    local _rc=$?
    if [ "$_rc" -ne 0 ] && [ -n "$_BOOTSTRAP_START_DIR" ] && [ "$_BOOTSTRAP_START_DIR" != "/" ]; then
        echo ""
        echo "Cleaning up partial installation in $_BOOTSTRAP_START_DIR..."
        # Only remove files bootstrap itself creates — never touch user data
        for _f in AGENTS.md CLAUDE.md .github/copilot-instructions.md; do
            [ -f "$_BOOTSTRAP_START_DIR/$_f" ] && rm -f "$_BOOTSTRAP_START_DIR/$_f" 2>/dev/null && echo "  Removed $_f"
        done
        # Only remove agent/ if we created it (directory is empty or only has our stubs)
        if [ -d "$_BOOTSTRAP_START_DIR/agent" ]; then
            # Check if agent/ only contains bootstrap-created subdirs
            _user_files=$(find "$_BOOTSTRAP_START_DIR/agent" -maxdepth 2 -type f 2>/dev/null | grep -v "template\|stub\|\.md$\|\.yml$" | head -1 || true)
            if [ -z "$_user_files" ]; then
                rm -rf "$_BOOTSTRAP_START_DIR/agent" 2>/dev/null && echo "  Removed agent/"
            else
                echo "  ⚠️  agent/ contains user files — skipping removal"
            fi
        fi
        [ -d "$_BOOTSTRAP_START_DIR/.opencode" ] && rm -rf "$_BOOTSTRAP_START_DIR/.opencode" 2>/dev/null && echo "  Removed .opencode/"
        echo "Cleanup complete."
    fi
}

trap 'echo "Bootstrap failed at line $LINENO — check output above for details." >&2; cleanup_on_failure; exit 1' ERR

# ── Pre-flight Safety Checks ───────────────────────────────────
# curl-pipe-bash mode: stdin is consumed by curl, so interactive prompts don't
# work. Instead, we validate the environment and abort with a clear message.

# Check 1: Already installed?
if [ -f "agent/core/identity.yml" ] && [ -f "AGENTS.md" ]; then
    CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
    SCRIPT_COUNT=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$CMD_COUNT" -ge 40 ] && [ "$SCRIPT_COUNT" -ge 18 ]; then
        echo "ACP Enhanced is already installed ($CMD_COUNT commands, $SCRIPT_COUNT scripts)."
        echo "To reinstall, remove AGENTS.md and agent/ first."
        echo "To update, use:"
        echo "  ./agent/scripts/acp.version-update.sh"
        echo "  # or: /acp-version-update in Copilot chat"
        exit 0
    else
        echo "⚠️  Partial install detected ($CMD_COUNT commands, $SCRIPT_COUNT scripts)."
        echo "   Completing installation..."
        # Fall through to complete remaining steps
    fi
fi

# Check for partial installation (one exists but not the other)
if [ -f "agent/core/identity.yml" ] || [ -f "AGENTS.md" ]; then
    echo ""
    echo "⚠️  Partial ACP installation detected in: $(pwd)"
    echo "   Some ACP files exist but installation is incomplete."
    echo "   This bootstrap will attempt to complete the installation."
    echo "   If you encounter issues, remove agent/ and AGENTS.md manually,"
    echo "   then re-run this script."
    echo ""
fi

# Check 2: Is this a project directory? Look for common indicators.
HAS_GIT=""
HAS_PROJECT_FILE=""
if [ -d ".git" ]; then HAS_GIT="yes"; fi
for _pf in package.json Cargo.toml go.mod pyproject.toml requirements.txt \
           Makefile CMakeLists.txt pom.xml build.gradle *.sln *.csproj \
           Gemfile Dockerfile docker-compose.yml; do
    # shellcheck disable=SC2086
    [ -f "$_pf" ] 2>/dev/null && HAS_PROJECT_FILE="yes" && break
done
if [ "$HAS_GIT" != "yes" ] && [ -z "$HAS_PROJECT_FILE" ]; then
    echo ""
    echo "⚠️  WARNING: No project files detected in $(pwd)"
    echo "   This script sets up ACP Enhanced in the CURRENT directory."
    echo "   It creates files in: $(pwd)"
    echo ""
    echo "   If you intended to install in a different project:"
    echo "     1. Press Ctrl+C now"
    echo "     2. cd /path/to/your/project"
    echo "     3. Run the curl command again"
    echo ""
    if [ "$SKIP_WARNING" != "true" ]; then
        echo "   If this IS your target directory, wait 5 seconds or pass --yes"
        echo "   Continuing in 5 seconds..."
        sleep 5
    else
        echo "   --yes passed, skipping delay."
    fi
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== ACP Enhanced Bootstrap ===${NC}"
echo "Setting up Agent Context Protocol Enhanced in: $(pwd)"
echo ""

# ── Scaffold Configuration ─────────────────────────────────────
# Added v6.8.2 (audit-022 R3+R4, M44 route-059). Controls what gets
# generated. Also reads agent/manifest.yaml → scaffold block if present.

# Read manifest overrides if present (args already parsed above)
if [ -f "agent/manifest.yaml" ]; then
    MANIFEST_TEAM=$(grep -A5 "^scaffold:" agent/manifest.yaml 2>/dev/null | grep "team_size:" | awk '{print $2}' || echo "")
    MANIFEST_PROMPTS=$(grep -A5 "^scaffold:" agent/manifest.yaml 2>/dev/null | grep "generate_prompts:" | awk '{print $2}' || echo "")
    MANIFEST_OPENCODE=$(grep -A5 "^scaffold:" agent/manifest.yaml 2>/dev/null | grep "generate_opencode:" | awk '{print $2}' || echo "")
    [ -n "$MANIFEST_TEAM" ] && TEAM_SIZE="$MANIFEST_TEAM"
    [ -n "$MANIFEST_PROMPTS" ] && GENERATE_PROMPTS="$MANIFEST_PROMPTS"
    [ -n "$MANIFEST_OPENCODE" ] && GENERATE_OPENCODE="$MANIFEST_OPENCODE"
fi

echo -e "${BLUE}Scaffold: team_size=${TEAM_SIZE} prompts=${GENERATE_PROMPTS} opencode=${GENERATE_OPENCODE}${NC}"
echo ""

# ── Directory Creation ─────────────────────────────────────────
# solo: core + memory + wiki + routing + 10 essential commands
# small: + skills + scripts + milestones + design + index + schemas
# team: all 20+ directories

echo -e "${YELLOW}[1/8] Creating directory structure (${TEAM_SIZE})...${NC}"
mkdir -p agent/core
mkdir -p agent/memory
mkdir -p agent/wiki
mkdir -p agent/routing
mkdir -p agent/routing/tasks
mkdir -p agent/tasks

if [ "$TEAM_SIZE" != "solo" ]; then
    mkdir -p agent/skills
    mkdir -p agent/design
    mkdir -p agent/milestones
    mkdir -p agent/index
    mkdir -p agent/schemas
fi

if [ "$TEAM_SIZE" = "team" ]; then
    mkdir -p agent/artifacts
    mkdir -p agent/clarifications
    mkdir -p agent/drafts
    mkdir -p agent/feedback
    mkdir -p agent/preferences
    mkdir -p agent/configurables
    mkdir -p agent/patterns
    mkdir -p agent/specs
    mkdir -p agent/reports
    mkdir -p agent/benchmarks/runner
    mkdir -p agent/benchmarks/suite
fi

mkdir -p agent/commands
mkdir -p agent/scripts
mkdir -p .github
mkdir -p scripts
echo -e "${GREEN}✓ Directories created${NC}"

# --- 2. Create AGENTS.md from template ---
echo -e "${YELLOW}[2/8] Creating AGENTS.md context loading protocol...${NC}"
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

When developer runs /acp-commit:
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
if [ "$GENERATE_PROMPTS" = "true" ]; then
  mkdir -p .github/prompts
fi
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
echo -e "${YELLOW}[3/8] Creating core layer files...${NC}"

[ -f agent/core/identity.yml ] || cat > agent/core/identity.yml << 'YAML'
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

[ -f agent/core/constraints.yml ] || cat > agent/core/constraints.yml << 'YAML'
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

[ -f agent/core/routing.yml ] || cat > agent/core/routing.yml << 'YAML'
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

# Copy drafts template (idempotent — only if absent)
ACP_DRAFTS_SRC="${SCRIPT_DIR}/../agent/drafts/draft.template.md"
if [ -f "${ACP_DRAFTS_SRC}" ] && [ ! -f "agent/drafts/draft.template.md" ]; then
  mkdir -p agent/drafts
  cp "${ACP_DRAFTS_SRC}" "agent/drafts/draft.template.md"
  echo -e "${GREEN}✓ draft.template.md copied to agent/drafts/${NC}"
fi

# --- 4. Memory + Wiki Stubs ---
echo -e "${YELLOW}[4/8] Creating memory and wiki stubs...${NC}"

[ -f agent/memory/sessions.md ] || cat > agent/memory/sessions.md << 'MD'
# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

MD

[ -f agent/memory/decisions.md ] || cat > agent/memory/decisions.md << 'MD'
# Architecture Decision Records (ADR Log)
# Loaded by section (ADR ID) only — never fully loaded
# Add entries via /acp-decide command

MD

[ -f agent/memory/patterns.md ] || cat > agent/memory/patterns.md << 'MD'
# Reusable Code Patterns
# Populated automatically by /acp-commit when patterns are identified
# Format: date-stamped YAML entries, max 60 days active

MD

[ -f agent/memory/lessons.md ] || cat > agent/memory/lessons.md << 'MD'
# Correction Log — Filtered by task_type before loading
# Populated automatically when developer says "log it" or "wrong, log this"
# Max 5 entries loaded per session, filtered to current task_type + priority:high

MD

[ -f agent/wiki/domain.yml ] || cat > agent/wiki/domain.yml << 'YAML'
# Domain Entity Model
# TODO: Describe the core entities your project works with
# Run /acp-init to auto-populate from your source code

entities: []     # Core domain objects (User, Order, Product, etc.)
operations: []   # Key operations grouped by category
modules: []      # Main modules or packages
YAML

[ -f agent/wiki/integrations.md ] || cat > agent/wiki/integrations.md << 'MD'
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

[ -f agent/wiki/architecture.md ] || cat > agent/wiki/architecture.md << 'MD'
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
echo -e "${YELLOW}[5/8] Creating routing layer...${NC}"

[ -f agent/routing/config.yml ] || cat > agent/routing/config.yml << 'YAML'
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

[ -f agent/routing/taxonomy.yml ] || cat > agent/routing/taxonomy.yml << 'YAML'
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

[ -f agent/routing/rules.md ] || cat > agent/routing/rules.md << 'MD'
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
[ -f agent/routing/ledger.md ] || cat > agent/routing/ledger.md << 'MD'
# ACP Cost Ledger
# Auto-appended by scripts/acp-dispatch.ts after every task
# Never edit manually

| Date | Task ID | Task Type | Executor | Input Tokens | Output Tokens | Cost USD | Notes |
|------|---------|-----------|----------|-------------|---------------|----------|-------|
MD

echo -e "${GREEN}✓ Routing layer created${NC}"

# --- 6. Prompt Files ---
if [ "$GENERATE_PROMPTS" = "true" ]; then
echo -e "${YELLOW}[6/8] Creating Copilot prompt files (opt-in)...${NC}"

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

cat > .github/prompts/acp-proceed.prompt.md << 'MD'
---
mode: agent
description: Implement tasks — single-task (default) or autonomous milestone completion (with arguments)
---

Read and execute `agent/commands/acp.proceed.md`.
MD

cat > .github/prompts/acp-status.prompt.md << 'MD'
---
mode: agent
description: Display current project status including milestone progress, current task, recent work, and next steps
---

Read and execute `agent/commands/acp.status.md`.
MD

cat > .github/prompts/acp-plan.prompt.md << 'MD'
---
mode: agent
description: Plan milestones OR tasks for undefined items in progress.yaml or new requirements
---

Read and execute `agent/commands/acp.plan.md`.
MD

cat > .github/prompts/acp-update.prompt.md << 'MD'
---
mode: agent
description: Update progress.yaml with latest project status, task completion, and recent work
---

Read and execute `agent/commands/acp.update.md`.
MD

cat > .github/prompts/acp-report.prompt.md << 'MD'
---
mode: agent
description: Generate a comprehensive project status report including progress, accomplishments, and next steps
---

Read and execute `agent/commands/acp.report.md`.
MD

cat > .github/prompts/acp-resume.prompt.md << 'MD'
---
mode: agent
description: Resume work on a project by initializing context, reviewing recent progress, and continuing
---

Read and execute `agent/commands/acp.resume.md`.
MD

cat > .github/prompts/acp-audit.prompt.md << 'MD'
---
mode: agent
description: Deep-dive investigation of a subject, producing a structured report in agent/reports/
---

Read and execute `agent/commands/acp.audit.md`.
MD

cat > .github/prompts/acp-handoff.prompt.md << 'MD'
---
mode: agent
description: Generate a context-aware handoff report for transferring work to an agent in a different context
---

Read and execute `agent/commands/acp.handoff.md`.
MD

cat > .github/prompts/acp-sync.prompt.md << 'MD'
---
mode: agent
description: Synchronize documentation with source code by identifying and updating stale documentation
---

Read and execute `agent/commands/acp.sync.md`.
MD

cat > .github/prompts/acp-validate.prompt.md << 'MD'
---
mode: agent
description: Validate all ACP documents for structure, consistency, correctness, and namespace conventions
---

Read and execute `agent/commands/acp.validate.md`.
MD

cat > .github/prompts/acp-index.prompt.md << 'MD'
---
mode: agent
description: Manage the key file index — list, add, remove, explore, and show indexed key files
---

Read and execute `agent/commands/acp.index.md`.
MD

cat > .github/prompts/acp-spec.prompt.md << 'MD'
---
mode: agent
description: Generate a specification document from a clarification, design, draft, or requirements doc
---

Read and execute `agent/commands/acp.spec.md`.
MD

cat > .github/prompts/acp-task-create.prompt.md << 'MD'
---
mode: agent
description: Create task files with proper structure, milestone linking, and automatic progress.yaml updates
---

Read and execute `agent/commands/acp.task-create.md`.
MD

cat > .github/prompts/acp-command-create.prompt.md << 'MD'
---
mode: agent
description: Create command files with namespace enforcement, draft support, and automatic package updates
---

Read and execute `agent/commands/acp.command-create.md`.
MD

cat > .github/prompts/acp-design-create.prompt.md << 'MD'
---
mode: agent
description: Create design documents with namespace enforcement, draft support, and automatic package updates
---

Read and execute `agent/commands/acp.design-create.md`.
MD

cat > .github/prompts/acp-design-reference.prompt.md << 'MD'
---
mode: agent
description: Discover and cross-reference design documents to ensure tasks have complete implementation detail
---

Read and execute `agent/commands/acp.design-reference.md`.
MD

cat > .github/prompts/acp-pattern-create.prompt.md << 'MD'
---
mode: agent
description: Create pattern files with namespace enforcement, draft support, and automatic package updates
---

Read and execute `agent/commands/acp.pattern-create.md`.
MD

cat > .github/prompts/acp-clarification-create.prompt.md << 'MD'
---
mode: agent
description: Create clarification documents from file input or chat to gather detailed requirements
---

Read and execute `agent/commands/acp.clarification-create.md`.
MD

cat > .github/prompts/acp-clarification-address.prompt.md << 'MD'
---
mode: agent
description: Address clarification responses by researching, exploring code/web, using tools, and presenting recommendations
---

Read and execute `agent/commands/acp.clarification-address.md`.
MD

cat > .github/prompts/acp-clarification-capture.prompt.md << 'MD'
---
mode: agent
description: Capture decisions from ephemeral clarification files and chat context into permanent entity documents
---

Read and execute `agent/commands/acp.clarification-capture.md`.
MD

cat > .github/prompts/acp-artifact-glossary.prompt.md << 'MD'
---
mode: agent
description: Create and maintain project glossaries through auto-extraction and interactive refinement
---

Read and execute `agent/commands/acp.artifact-glossary.md`.
MD

cat > .github/prompts/acp-artifact-reference.prompt.md << 'MD'
---
mode: agent
description: Create reference guides for passive information after command-first principle check
---

Read and execute `agent/commands/acp.artifact-reference.md`.
MD

cat > .github/prompts/acp-artifact-research.prompt.md << 'MD'
---
mode: agent
description: Create long-lived research artifacts via systematic investigation with web/MCP integration
---

Read and execute `agent/commands/acp.artifact-research.md`.
MD

cat > .github/prompts/acp-sessions.prompt.md << 'MD'
---
mode: agent
description: Manage and view active agent sessions across projects
---

Read and execute `agent/commands/acp.sessions.md`.
MD

cat > .github/prompts/acp-package-install.prompt.md << 'MD'
---
mode: agent
description: Install third-party command packages from git repositories
---

Read and execute `agent/commands/acp.package-install.md`.
MD

cat > .github/prompts/acp-package-list.prompt.md << 'MD'
---
mode: agent
description: List installed ACP packages with versions, file counts, and optional details
---

Read and execute `agent/commands/acp.package-list.md`.
MD

cat > .github/prompts/acp-package-info.prompt.md << 'MD'
---
mode: agent
description: Display detailed information about a specific installed package (local or global)
---

Read and execute `agent/commands/acp.package-info.md`.
MD

cat > .github/prompts/acp-package-search.prompt.md << 'MD'
---
mode: agent
description: Discover ACP packages on GitHub using the GitHub API
---

Read and execute `agent/commands/acp.package-search.md`.
MD

cat > .github/prompts/acp-package-remove.prompt.md << 'MD'
---
mode: agent
description: Remove installed ACP packages and clean up manifest
---

Read and execute `agent/commands/acp.package-remove.md`.
MD

cat > .github/prompts/acp-package-update.prompt.md << 'MD'
---
mode: agent
description: Update installed ACP packages to their latest versions with smart conflict detection
---

Read and execute `agent/commands/acp.package-update.md`.
MD

cat > .github/prompts/acp-package-create.prompt.md << 'MD'
---
mode: agent
description: Create a new ACP package with full ACP installation, release branch configuration, and pre-commit hooks
---

Read and execute `agent/commands/acp.package-create.md`.
MD

cat > .github/prompts/acp-package-publish.prompt.md << 'MD'
---
mode: agent
description: Automated package publishing with validation, version detection, CHANGELOG generation, and testing
---

Read and execute `agent/commands/acp.package-publish.md`.
MD

cat > .github/prompts/acp-package-validate.prompt.md << 'MD'
---
mode: agent
description: Comprehensive package validation with shell and LLM checks, auto-fix, and test installation
---

Read and execute `agent/commands/acp.package-validate.md`.
MD

cat > .github/prompts/acp-project-create.prompt.md << 'MD'
---
mode: agent
description: Create a new generic ACP project with full ACP installation and guided setup
---

Read and execute `agent/commands/acp.project-create.md`.
MD

cat > .github/prompts/acp-project-list.prompt.md << 'MD'
---
mode: agent
description: List all projects registered in global workspace
---

Read and execute `agent/commands/acp.project-list.md`.
MD

cat > .github/prompts/acp-project-info.prompt.md << 'MD'
---
mode: agent
description: Display detailed information about a specific project from the global registry
---

Read and execute `agent/commands/acp.project-info.md`.
MD

cat > .github/prompts/acp-project-set.prompt.md << 'MD'
---
mode: agent
description: Switch to a different project in the global registry
---

Read and execute `agent/commands/acp.project-set.md`.
MD

cat > .github/prompts/acp-project-update.prompt.md << 'MD'
---
mode: agent
description: Update project metadata in the global registry
---

Read and execute `agent/commands/acp.project-update.md`.
MD

cat > .github/prompts/acp-project-remove.prompt.md << 'MD'
---
mode: agent
description: Remove a project from the global registry with optional directory deletion
---

Read and execute `agent/commands/acp.project-remove.md`.
MD

cat > .github/prompts/acp-projects-sync.prompt.md << 'MD'
---
mode: agent
description: Discover unregistered ACP projects in ~/.acp/projects/ and add them to the registry
---

Read and execute `agent/commands/acp.projects-sync.md`.
MD

cat > .github/prompts/acp-projects-restore.prompt.md << 'MD'
---
mode: agent
description: Restore/clone missing projects from their registered git origins
---

Read and execute `agent/commands/acp.projects-restore.md`.
MD

cat > .github/prompts/acp-preferences-show.prompt.md << 'MD'
---
mode: agent
description: Display the effective preference set for a namespace with source attribution for each value
---

Read and execute `agent/commands/acp.preferences-show.md`.
MD

cat > .github/prompts/acp-preferences-get.prompt.md << 'MD'
---
mode: agent
description: Resolve and display preferences for a given namespace
---

Read and execute `agent/commands/acp.preferences-get.md`.
MD

cat > .github/prompts/acp-preferences-set.prompt.md << 'MD'
---
mode: agent
description: Set a preference value at a specified level (user/workspace/project) with validation
---

Read and execute `agent/commands/acp.preferences-set.md`.
MD

cat > .github/prompts/acp-preferences-create.prompt.md << 'MD'
---
mode: agent
description: Create preference files at a specified level with default values from configurables
---

Read and execute `agent/commands/acp.preferences-create.md`.
MD

cat > .github/prompts/acp-preferences-validate.prompt.md << 'MD'
---
mode: agent
description: Validate all preference files across all levels against their configurables schemas
---

Read and execute `agent/commands/acp.preferences-validate.md`.
MD

cat > .github/prompts/acp-version-check.prompt.md << 'MD'
---
mode: agent
description: Display current ACP version and compatibility information
---

Read and execute `agent/commands/acp.version-check.md`.
MD

cat > .github/prompts/acp-version-check-for-updates.prompt.md << 'MD'
---
mode: agent
description: Check if a newer version of ACP is available without applying updates
---

Read and execute `agent/commands/acp.version-check-for-updates.md`.
MD

cat > .github/prompts/acp-version-update.prompt.md << 'MD'
---
mode: agent
description: Update ACP files (AGENT.md, templates, scripts) to the latest version
---

Read and execute `agent/commands/acp.version-update.md`.
MD

cat > .github/prompts/git-commit.prompt.md << 'MD'
---
mode: agent
description: Commit staged changes with a well-formatted conventional commit message
---

Read and execute `agent/commands/git.commit.md`.
MD

echo -e "${GREEN}✓ Prompt files created${NC}"
else
echo -e "${YELLOW}[6/8] Skipping prompt files (opt-in via --generate-prompts or manifest)${NC}"
fi

# --- 6b. Generate opencode commands (independent of prompt generation) ---
if [ "$GENERATE_OPENCODE" = "true" ]; then
echo -e "${YELLOW}[6b/8] Generating opencode slash commands...${NC}"
if ls .github/prompts/*.prompt.md >/dev/null 2>&1; then
mkdir -p .opencode/commands
_oc_count=0
for _oc_src in .github/prompts/*.prompt.md; do
  _oc_base="$(basename "$_oc_src" .prompt.md)"
  _oc_dst=".opencode/commands/${_oc_base}.md"
  _oc_desc=$(grep "^description:" "$_oc_src" | sed 's/^description: //')
  _oc_body=$(awk 'BEGIN{fm=0} /^---/{fm++; next} fm>=2{print}' "$_oc_src")
  {
    echo "---"
    echo "description: ${_oc_desc}"
    echo "---"
    printf '%s\n' "$_oc_body"
  } > "$_oc_dst"
  _oc_count=$((_oc_count + 1))
done
echo -e "${GREEN}✓ ${_oc_count} opencode slash commands generated in .opencode/commands/${NC}"
if [ "$_oc_count" -eq 0 ]; then
  echo -e "${YELLOW}⚠️  0 opencode commands generated — check .github/prompts/*.prompt.md${NC}"
fi
else
  echo -e "${YELLOW}  (no prompt files found — run with --generate-prompts first, or generate prompts in Copilot chat)${NC}"
fi
fi

# --- 7. Install agent/ commands, scripts and schemas ---
echo -e "${YELLOW}[7/8] Installing ACP commands, scripts and schemas (agent/ directory)...${NC}"

_CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
_SCRIPT_COUNT=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$_CMD_COUNT" -ge 40 ] && [ "$_SCRIPT_COUNT" -ge 18 ]; then
  echo -e "${GREEN}✓ agent/commands + agent/scripts already present (${_CMD_COUNT} commands, ${_SCRIPT_COUNT} scripts) — skipping download${NC}"
else
  if [ "$_CMD_COUNT" -gt 0 ] || [ "$_SCRIPT_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Partial install detected (${_CMD_COUNT} commands, ${_SCRIPT_COUNT} scripts) — downloading full set${NC}"
  fi
  INSTALL_URL="https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh"
  echo "Downloading ACP installer..."
  INSTALL_TMP=$(mktemp)
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$INSTALL_TMP" "$INSTALL_URL" || { echo "ERROR: Failed to download installer (curl)"; rm -f "$INSTALL_TMP"; exit 1; }
    bash "$INSTALL_TMP"
    rm -f "$INSTALL_TMP"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$INSTALL_TMP" "$INSTALL_URL" || { echo "ERROR: Failed to download installer (wget)"; rm -f "$INSTALL_TMP"; exit 1; }
    bash "$INSTALL_TMP"
    rm -f "$INSTALL_TMP"
  else
    echo -e "${RED}ERROR: Neither curl nor wget available. Cannot download installer.${NC}"
    echo "Install agent/ manually from a local ACP Enhanced clone:"
    echo "  bash /path/to/acp-enhanced/agent/scripts/acp.install.sh"
    exit 1
  fi
fi
echo ""

# Generate Cursor + Claude wrappers from command docs (after agent/scripts installed)
if [ -f "agent/scripts/acp.cursor-commands-sync.sh" ]; then
  echo -e "${YELLOW}Generating Cursor slash commands...${NC}"
  bash agent/scripts/acp.cursor-commands-sync.sh
elif [ ! -d ".cursor/commands" ] || [ -z "$(ls -A .cursor/commands 2>/dev/null)" ]; then
  echo -e "${YELLOW}⚠️  Cursor sync script not found — 0 cursor commands generated${NC}"
fi

if [ -f "agent/scripts/acp.claude-commands-sync.sh" ]; then
  echo -e "${YELLOW}Generating Claude Code slash commands...${NC}"
  bash agent/scripts/acp.claude-commands-sync.sh
elif [ ! -d ".claude/commands" ] || [ -z "$(ls -A .claude/commands 2>/dev/null)" ]; then
  echo -e "${YELLOW}⚠️  Claude sync script not found — 0 claude commands generated${NC}"
fi
echo ""

# --- 8. Install pre-commit hook for AGENTS.md sync ---
echo -e "${YELLOW}[8/8] Installing AGENTS.md sync pre-commit hook...${NC}"

ACP_HOOK_MARKER="# ACP: auto-sync AGENTS.md"
HOOK_FILE=".git/hooks/pre-commit"

ACP_HOOK_BLOCK='#!/bin/bash
# ACP: auto-sync AGENTS.md → CLAUDE.md + .github/copilot-instructions.md
if git diff --cached --name-only | grep -q "^AGENTS\.md$"; then
  cp AGENTS.md CLAUDE.md
  cp AGENTS.md .github/copilot-instructions.md
  git add CLAUDE.md .github/copilot-instructions.md
  echo "[ACP] CLAUDE.md and copilot-instructions.md synced from AGENTS.md"
fi'

if [ -d ".git" ]; then
  if [ -f "$HOOK_FILE" ]; then
    # Hook exists — check if ACP block already present
    if grep -q "$ACP_HOOK_MARKER" "$HOOK_FILE" 2>/dev/null; then
      echo -e "${GREEN}✓ pre-commit hook already has ACP sync block — skipped${NC}"
    else
      # Append ACP block to existing hook
      printf '\n%s\n' "$ACP_HOOK_BLOCK" >> "$HOOK_FILE"
      chmod +x "$HOOK_FILE"
      echo -e "${GREEN}✓ ACP sync block appended to existing pre-commit hook${NC}"
    fi
  else
    # No hook yet — create new
    printf '%s\n' "$ACP_HOOK_BLOCK" > "$HOOK_FILE"
    chmod +x "$HOOK_FILE"
    echo -e "${GREEN}✓ pre-commit hook installed (.git/hooks/pre-commit)${NC}"
  fi
  echo -e "${YELLOW}  Hook auto-syncs CLAUDE.md + copilot-instructions.md whenever AGENTS.md is committed${NC}"
else
  echo -e "${YELLOW}  No .git directory found — pre-commit hook not installed (run after git init)${NC}"
fi
echo ""

# --- Summary ---
echo ""
echo -e "${BLUE}=== Bootstrap Complete ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit AGENTS.md — fill in the 'Who You Are' section with your project description"
echo "  2. Edit agent/core/identity.yml — fill in project name, stack, repo URL"
echo "  2b. Optional: uncomment git_workflow: in identity.yml to enable branch safety checks"
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
echo "opencode slash commands: same /acp-* set (via .opencode/commands/)"
echo "Claude Code slash commands: same /acp-* set (via .claude/commands/)"
echo ""

# Post-install verification
_CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
_SCRIPT_COUNT=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Post-Install Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$_CMD_COUNT" -ge 40 ]; then
  echo -e "  ${GREEN}✅ agent/commands/: $_CMD_COUNT files${NC}"
else
  echo -e "  ${RED}❌ agent/commands/: $_CMD_COUNT files (expected 40+)${NC}"
fi
if [ "$_SCRIPT_COUNT" -ge 18 ]; then
  echo -e "  ${GREEN}✅ agent/scripts/: $_SCRIPT_COUNT files${NC}"
else
  echo -e "  ${RED}❌ agent/scripts/: $_SCRIPT_COUNT files (expected 18+)${NC}"
fi
[ -d ".opencode/commands" ] && echo -e "  ${GREEN}✅ .opencode/commands/: present${NC}" || echo -e "  ${YELLOW}⚠️ .opencode/commands/: missing${NC}"
_CURSOR_COUNT=$(find .cursor/commands -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ') || true
_CMD_SOURCE_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ') || true
if [ "$_CURSOR_COUNT" -ge "$_CMD_SOURCE_COUNT" ] 2>/dev/null; then
  echo -e "  ${GREEN}✅ .cursor/commands/: ${_CURSOR_COUNT} files${NC}"
else
  echo -e "  ${YELLOW}⚠️ .cursor/commands/: ${_CURSOR_COUNT} files (expected ≥${_CMD_SOURCE_COUNT})${NC}"
fi
_CLAUDE_COUNT=$(find .claude/commands -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ') || true
if [ "$_CLAUDE_COUNT" -ge "$_CMD_SOURCE_COUNT" ] 2>/dev/null; then
  echo -e "  ${GREEN}✅ .claude/commands/: ${_CLAUDE_COUNT} files${NC}"
else
  echo -e "  ${YELLOW}⚠️ .claude/commands/: ${_CLAUDE_COUNT} files (expected ≥${_CMD_SOURCE_COUNT})${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Exit non-zero if verification failed — prevents silent broken installs
_VERIFY_FAILED=false
[ "$_CMD_COUNT" -lt 40 ] && _VERIFY_FAILED=true
[ "$_SCRIPT_COUNT" -lt 18 ] && _VERIFY_FAILED=true

if [ "$_VERIFY_FAILED" = "true" ]; then
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}  ⚠️  INSTALL INCOMPLETE${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "  The bootstrap completed but agent/ files are missing."
  echo "  This is a known issue (audit-045). To complete the install:"
  echo ""
  echo "    curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh | bash"
  echo ""
  exit 1
fi

echo -e "${GREEN}Done. ACP Enhanced is ready.${NC}"
