# ACP Enhanced — Core Terminology Glossary

<!-- @acp.meta.artifact
topic: glossary, terminology, onboarding
last_verified: 2026-06-15
confidence: high
status: active
updated: 2026-06-15
@acp.meta.end -->

**Type**: glossary
**Created**: 2026-05-04
**Category**: Terminology
**Total Terms**: 48

---

## Purpose

This glossary defines all ACP Enhanced-specific terms to ensure consistent understanding across the framework, documentation, and agent sessions. It covers the protocol itself, the routing system, model terminology, and the opencode integration.

---

## Protocol & Architecture

| Term | Definition |
|------|------------|
| **ACP** | Agent Context Protocol — a documentation-first development methodology where markdown command files act as agent directives. Agents treat command files as executable scripts (supporting branching, loops, arguments, and subroutines). |
| **ACP Enhanced** | A fork of the original `prmichaelsen/agent-context-protocol` that adds a structured context management layer (`agent/` framework) with tiered memory, task routing, skill files, and 58 slash commands. |
| **Context Loading Protocol** | The 6-step deterministic protocol defined in `AGENTS.md`/`CLAUDE.md` that every session must follow: identity → taxonomy → skill → memory → reference → confirm. Produces reproducible, token-budgeted context on every session start. |
| **Token Budget** | The disciplined cap on how many tokens are loaded into context per session (default: 2,800 tokens for the structured layers, max 5,000 before task content). Exists for reproducibility and cost discipline, not technical necessity. |
| **Context Window** | The total text an AI model can process in one call. ACP Enhanced loads ~1,700–2,230 tokens per task vs. 10,000–18,000 for unstructured usage. |
| **Layer 1 (Core)** | The always-loaded context: `agent/core/identity.yml`, `constraints.yml`, `routing.yml`. ~180 tokens. Prompt-cached after first call. |
| **Layer 2 (Skills)** | One skill file loaded per session based on task type. ~240–350 tokens. Semi-static. |
| **Layer 3 (Ephemeral)** | Dynamic per-task context: last 3 session summaries, filtered lessons, active task file, one wiki section. ~1,200–1,700 tokens. Never cached. |
| **Prompt Caching** | Provider-side optimization (Claude, Gemini) where identical prefix bytes are stored and re-used across calls. Layer 1 + Layer 2 are designed to be prompt-cached, reducing token costs on repeated calls. |
| **Bootstrap** | Running `scripts/acp-bootstrap.sh` to install the ACP Enhanced framework into a new or existing project. Creates `agent/`, `AGENTS.md`, slash command directories. Safe to re-run — user state is protected by existence-check guards so memory files are never overwritten. |

---

## Routing & Model Selection

| Term | Definition |
|------|------------|
| **Task Taxonomy** | `agent/routing/taxonomy.yml` — maps every `task_type` to an `executor` (model), complexity level, required context files, and token estimate. The ground truth for model selection. |
| **Executor** | The AI model designated to run a specific task type. Values in taxonomy: `deepseek-v4-flash`, `deepseek-v4-pro`, `claude-sonnet`, `local-script`. |
| **task_type** | A classification label for a unit of work (e.g., `bash-script-create`, `command-doc-update`, `bug-fix-complex`). Determines which executor and skill file to load. |
| **Routing Rules** | `agent/routing/rules.md` — human-readable tie-breakers for when a task matches multiple task_types. Priority order: architecture/whole-system → pro → flash → local. |
| **Route File** | A task file in `agent/routing/tasks/route-NNN.md` created by `/acp-route`. Contains YAML frontmatter with `executor`, `task_type`, `tokens_est`, `created`, `completed`. |
| **override_executor** | A YAML frontmatter field on a route file that overrides the taxonomy-assigned executor. Example: `override_executor: claude-sonnet` for a critical bug. |
| **Dispatch** | Running `scripts/acp-dispatch.ts` with a route file path to automatically call the assigned model via OpenRouter API, with context assembly and cost logging. |
| **Ledger** | `agent/routing/ledger.md` — a markdown table logging every dispatched task: date, task ID, task type, executor, input tokens, output tokens, USD cost. |
| **`/acp-route`** | Slash command that classifies a natural-language task description into a `task_type`, creates a route file, and reports the recommended executor. |

---

## Personas (Deployment Modes)

| Term | Definition |
|------|------------|
| **Persona A** | GitHub Copilot Pro only. No additional setup. Executor field is a manual recommendation — you choose the model in Copilot's dropdown. Primary benefit: memory layer eliminates 20–30% of clarification turns. |
| **Persona B** | DeepSeek / multi-model via OpenRouter. Uses `acp-dispatch.ts` for fully automatic model routing. 50–65% cost reduction. No Copilot subscription required. Opencode is the primary UI. |
| **Persona C** | Copilot Pro + DeepSeek (recommended). Copilot for tab completion/PR review; DeepSeek via dispatch for heavy sessions. 60–85% cost reduction vs. all-Claude baseline. |
| **`agent/core/routing.yml`** | Records which persona, executor, and model are active for the current session. Updated automatically by `acp-dispatch.ts`; updated manually by the developer for Persona A/B. |

---

## Memory System

| Term | Definition |
|------|------------|
| **sessions.md** | `agent/memory/sessions.md` — YAML list of session summaries. Written by `/acp-commit`. The agent loads the last 3 entries at session start. Primary mechanism for context continuity across sessions. |
| **lessons.md** | `agent/memory/lessons.md` — self-improving correction log. Every time a developer corrects the agent's output, a lesson entry is appended with task_type, mistake, and correction. Filtered on load by task_type. |
| **patterns.md** | `agent/memory/patterns.md` — reusable solutions. Written when a pattern is identified during `/acp-commit`. Loaded as part of Layer 3 context for relevant task types. |
| **decisions.md** | `agent/memory/decisions.md` — ADR (Architectural Decision Record) log. Written by `/acp-decide`. Marked "DO NOT re-open" to prevent re-debating settled decisions. |
| **`/acp-commit`** | Slash command that writes a session summary to `sessions.md`, auto-stamps `completed:` on finished route files, checks for new patterns, and prompts for ADRs if needed. Must be run at end of every session. |
| **`/acp-resume`** | Slash command that runs the 6-step context loading protocol at the start of a session. Loads identity, routing, skill, last 3 sessions, filtered lessons, and confirms readiness. |

---

## Commands & Slash Commands

| Term | Definition |
|------|------------|
| **Slash Command** | A `/acp-*` or `/git-*` command invoked in an IDE or terminal agent (Copilot, opencode). Each command reads a markdown directive file and executes its steps. |
| **Command Doc** | A markdown file in `agent/commands/*.md` defining the full executable directive for a slash command. Identical body content is replicated to `.github/prompts/` (Copilot) and `.opencode/commands/` (opencode). |
| **`/acp-proceed`** | Executes the current task or milestone. `--yolo` flag runs the full milestone autonomously with atomic git commits per task. |
| **`/acp-plan`** | Generates milestone and task breakdown from a design document. Produces planning artifacts in `agent/tasks/`. |
| **`/acp-status`** | Reports current milestone progress, completed tasks, open tasks, and blockers. |
| **`/acp-audit`** | Reviews all framework files for consistency issues, stale entries, missing docs, and cross-reference integrity. |
| **`/acp-handoff`** | Creates a handoff document capturing current state before switching context (PR, break, model switch). |
| **`/acp-decide`** | Prompts for decision context and appends an ADR to `decisions.md`. |
| **`/acp-init`** | Initializes ACP in a project — reads the codebase and populates `agent/wiki/domain.yml` and `agent/wiki/integrations.md`. |

---

## opencode Integration

| Term | Definition |
|------|------------|
| **opencode** | A terminal-based AI coding agent (TUI) that supports slash commands, multi-model switching, and session persistence. ACP Enhanced registers all 58 slash commands in `.opencode/commands/`. |
| **`.opencode/commands/`** | Directory created by `acp-bootstrap.sh` containing 58 `.md` files — one per slash command. opencode auto-discovers and registers these. Format: YAML frontmatter with `description:` + command body. |
| **`deepseek-v4-flash`** | Fast, cheap DeepSeek model (~$0.14 input / $0.28 output per million tokens). Used for low-complexity tasks: doc updates, simple fixes, test writing, schema changes, doc syncs, status checks. |
| **`deepseek-v4-pro`** | Powerful DeepSeek model (~$0.435 input / $0.87 output per million tokens). Used for medium/high-complexity tasks: new scripts from scratch, complex bug fixes, command doc writing, preference system changes. |
| **OpenRouter** | API gateway (openrouter.ai) that provides unified access to multiple AI models (DeepSeek, Claude, Gemini, etc.) via a single OpenAI-compatible endpoint. Required for `acp-dispatch.ts`. |
| **`acp-dispatch.ts`** | TypeScript script at `scripts/acp-dispatch.ts`. Reads a route file's `executor:` field, assembles context (Layer 1 + Layer 2 + dynamic Layer 3), calls the correct model via OpenRouter, streams output, logs tokens and cost to the ledger. |

---

## Integrity & Security

| Term | Definition |
|------|------------|
| **Integrity Scan** | `/acp-integrity` — a multi-script framework scan for Unicode injection, hidden entropy, data exfiltration, taint flow, and memory poisoning. v1.0 covers Categories 1–7 (IG-01–IG-44). v2.0 Phase 2 adds Categories 8–10 (IG-45–IG-62). 70 rules total. |
| **Phase 2** | M58 semantic analysis layer extending `/acp-integrity` with taint flow (Cat 8), prompt injection (Cat 9), and memory poisoning (Cat 10). All Phase 2 findings carry `verdict: REQUIRES_HUMAN_REVIEW`. |
| **Confidence Ceiling** | The maximum confidence level a Phase 2 rule may report, independent of severity. Cat 8: MEDIUM, Cat 9: LOW, Cat 10: LOW (except IG-61 at HIGH as script-backed). No Phase 2 finding auto-fails CI. |
| **Taint Flow** | Category 8 rules (IG-45–IG-50) that track untrusted data from source to sink across files. Detected via `acp.taint-scan.sh` heuristics (file-level flow analysis for indirect source→sink patterns). |
| **Memory Poisoning** | Category 10 rules (IG-58–IG-62) detecting adversarial content in `agent/memory/` files. Prep script `acp.memory-scan.sh` outputs structured YAML for LLM comparison against hard rules. LOW-confidence findings do NOT create audit carryovers. |
| **Self-Protection Protocol** | Agent behavior on detecting prompt injection (IG-53/54/56/57): flag with `INJECTION-RISK`, output `REQUIRES_HUMAN_REVIEW`, CONTINUE scanning — do NOT self-halt. |

---

## Workflow Terms

| Term | Definition |
|------|------------|
| **Clarification** | A structured document (`agent/clarifications/`) capturing ambiguous requirements, open questions, and decisions before design begins. Created by `/acp-clarification-create`. |
| **Design Document** | A technical specification in `agent/design/` describing what to build, how it works, and why. The source of truth for planning artifacts. |
| **Milestone** | A named project phase with a defined set of tasks and deliverables. Tracked in `agent/progress.yaml`. |
| **Task** | A single unit of work within a milestone. Described in `agent/tasks/milestone-XX-*/task-NNN-title.md` with acceptance criteria. Distinct from route files. |
| **ADR** | Architectural Decision Record. A permanent entry in `decisions.md` capturing what was decided, why, and what must not be re-opened. Created by `/acp-decide`. |
| **`/acp-cost-report`** | Weekly command that reviews the cost ledger, suggests taxonomy corrections for over/under-routed task types, and reports total spend. |

---

## Alphabetical Index

[A](#a) | [B](#b) | [C](#c) | [D](#d) | [E](#e) | [L](#l) | [M](#m) | [O](#o) | [P](#p) | [R](#r) | [S](#s) | [T](#t)

### A
- **ACP** → Protocol & Architecture
- **ACP Enhanced** → Protocol & Architecture
- **ADR** → Workflow Terms
- **`/acp-audit`** → Commands & Slash Commands
- **`/acp-commit`** → Memory System
- **`/acp-cost-report`** → Workflow Terms
- **`/acp-decide`** → Commands & Slash Commands
- **`/acp-handoff`** → Commands & Slash Commands
- **`/acp-init`** → Commands & Slash Commands
- **`/acp-plan`** → Commands & Slash Commands
- **`/acp-proceed`** → Commands & Slash Commands
- **`/acp-resume`** → Memory System
- **`/acp-route`** → Routing & Model Selection
- **`/acp-status`** → Commands & Slash Commands
- **`acp-dispatch.ts`** → opencode Integration

### B
- **Bootstrap** → Protocol & Architecture

### C
- **Clarification** → Workflow Terms
- **Command Doc** → Commands & Slash Commands
- **Confidence Ceiling** → Integrity & Security
- **Context Loading Protocol** → Protocol & Architecture
- **Context Window** → Protocol & Architecture

### D
- **decisions.md** → Memory System
- **deepseek-v4-flash** → opencode Integration
- **deepseek-v4-pro** → opencode Integration
- **Design Document** → Workflow Terms
- **Dispatch** → Routing & Model Selection

### E
- **Executor** → Routing & Model Selection

### I
- **Integrity Scan** → Integrity & Security

### L
- **Layer 1 (Core)** → Protocol & Architecture
- **Layer 2 (Skills)** → Protocol & Architecture
- **Layer 3 (Ephemeral)** → Protocol & Architecture
- **Ledger** → Routing & Model Selection
- **lessons.md** → Memory System

### M
- **Memory Poisoning** → Integrity & Security
- **Milestone** → Workflow Terms

### O
- **opencode** → opencode Integration
- **`.opencode/commands/`** → opencode Integration
- **OpenRouter** → opencode Integration
- **override_executor** → Routing & Model Selection

### P
- **patterns.md** → Memory System
- **Persona A** → Personas
- **Persona B** → Personas
- **Persona C** → Personas
- **Phase 2** → Integrity & Security
- **Prompt Caching** → Protocol & Architecture

### R
- **Route File** → Routing & Model Selection
- **Routing Rules** → Routing & Model Selection

### S
- **Self-Protection Protocol** → Integrity & Security
- **sessions.md** → Memory System
- **Slash Command** → Commands & Slash Commands

### T
- **Task** → Workflow Terms
- **Task Taxonomy** → Routing & Model Selection
- **task_type** → Routing & Model Selection
- **Taint Flow** → Integrity & Security
- **Token Budget** → Protocol & Architecture
