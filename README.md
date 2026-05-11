# ACP Enhanced — Agent Context Protocol

> **This is a fork of [Agent Context Protocol](https://github.com/prmichaelsen/agent-context-protocol) by [@prmichaelsen](https://github.com/prmichaelsen).**
> ACP Enhanced adds a structured context management layer (`agent/` framework) on top of the original ACP command and script system.
> The original ACP content — commands, scripts, schemas, and workflow — is preserved in full.

---

## What is ACP Enhanced?

ACP Enhanced consists of two layers built on top of the original ACP:

1. **Original ACP** — command documents (`agent/commands/*.md`), bash scripts (`agent/scripts/*.sh`), YAML schemas (`agent/schemas/*.yaml`), the full planning and package workflow.
2. **Enhanced Framework Layer** — a structured `agent/` directory that gives the AI agent a 5,000-token context budget system with tiered memory, skill routing, a task taxonomy, and a self-improving correction log.

The framework layer solves a specific problem: as your project grows, the AI agent starts every session with zero context. ACP Enhanced makes the agent systematically load only what it needs, in priority order, within a strict token budget.

### What the `agent/` layer adds

| Directory | Purpose |
|---|---|
| `agent/core/` | Identity, hard constraints, token budget — loaded every session |
| `agent/skills/` | Domain-specific guidance (scripts, schemas, testing, TypeScript, etc.) — one file per session |
| `agent/routing/` | Task taxonomy and routing rules — classifies what type of work this session is |
| `agent/memory/` | Session log, lessons learned, patterns, architectural decisions |
| `agent/wiki/` | Reference docs loaded section-by-section (never all at once) |

---

## Install ACP Enhanced in a New Project

### One command — installs everything

```bash
# From your target project root
curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/scripts/acp-bootstrap.sh | bash
```

This runs in seven steps:
1. **Core layer** — creates `agent/` directory structure, `AGENTS.md`, and core YAML files (`identity.yml`, `constraints.yml`, `routing.yml`)
2. **Skill files** — installs one skill file per task domain into `agent/skills/`
3. **Memory + wiki stubs** — creates `agent/memory/` and `agent/wiki/` with empty starter files
4. **Routing layer** — installs `agent/routing/taxonomy.yml`, `rules.md`, and routing task template
5. **Prompt files** — generates `.github/prompts/*.prompt.md` for VS Code Copilot
6. **opencode commands** — mirrors all prompts to `.opencode/commands/*.md` for opencode TUI
7. **Commands + scripts** — downloads and installs `agent/commands/`, `agent/scripts/`, `agent/schemas/`

After it completes, **customize** `agent/core/identity.yml` for your project (name, stack, team, repo URL).

> If you've cloned this repo locally, you can also run:
> ```bash
> bash /path/to/acp-enhanced/scripts/acp-bootstrap.sh
> ```
> Local clone is detected automatically — the `agent/` content is already present and won't be re-downloaded.

### Update when this fork changes

```
/acp-package-update acp-enhanced

> Repository: <https://github.com/ssucipto/acp-enhanced>
```

Only files that changed since last install are updated. Locally modified files are flagged as conflicts.

---

## Slash Commands

ACP Enhanced registers **59 slash commands** across two tools — available after bootstrapping:

| Tool | How to invoke | Source files |
|---|---|---|
| VS Code Copilot | `/acp-*` — autocomplete in Copilot Chat | `.github/prompts/*.prompt.md` |
| opencode | `/acp-*` — autocomplete in opencode TUI | `.opencode/commands/*.md` |
| Any other agent | Tell your agent: *"Read and execute `agent/commands/acp.init.md`"* | `agent/commands/*.md` (59 commands) |

```text
/acp-init          /acp-proceed       /acp-plan          /acp-status
/acp-resume        /acp-report        /acp-audit         /acp-handoff
/acp-package-*     /acp-project-*     /acp-preferences-* /acp-clarification-*
/acp-design-*      /acp-artifact-*    /git-commit        /git-init
```

> VS Code Copilot requires agent/chat mode enabled. The `.github/prompts/` directory is created by `acp-bootstrap.sh` automatically.  
> opencode requires the `.opencode/commands/` directory, also created by `acp-bootstrap.sh` automatically.  
> **Note**: All 59 commands are available in `agent/commands/*.md`, `.github/prompts/*.prompt.md`, and `.opencode/commands/*.md`. Framework-layer commands (`/acp-route`, `/acp-commit`, `/acp-decide`, `/acp-cost-report`, `/acp-memory-sync`, `/acp-wiki-update`) are fully documented command files — invoke them via VS Code Copilot, opencode, or by asking any agent to read the corresponding `agent/commands/acp.*.md` file.

---

## AI Tools & Model Routing

ACP Enhanced supports three deployment configurations depending on your tooling and budget. Every ACP feature works with all three — the difference is only in which models execute your tasks and how routing happens.

### Choose Your Setup (Persona)

| Persona | Tools | Setup | Cost Profile | Primary Gain |
|---|---|---|---|---|
| **A — Copilot Only** | VS Code Copilot | None | Fixed subscription | Memory + ADRs cut 20–30% of clarification turns |
| **B — DeepSeek / opencode** | opencode + OpenRouter | API key + `scripts/acp-dispatch.ts` | ~$5–20/mo pay-per-token | 50–65% cost reduction via automatic model routing |
| **C — Copilot + DeepSeek** *(recommended)* | Both | Both | Fixed + small variable | Each tool used for its strength; 60–85% total savings |

### Model Selection — Which Model for Which Task

ACP's `agent/routing/taxonomy.yml` already encodes the right model for every task type:

| Model | When to use | Example task types | Cost (per 1M tokens) |
|---|---|---|---|
| **deepseek-v4-flash** | Low complexity, fast iteration | Doc updates, simple bug fixes, test writing, schema edits, status checks | $0.14 in / $0.28 out |
| **deepseek-v4-pro** | Medium complexity, new implementation | New scripts from scratch, complex bugs, command doc writing, preference system | $0.44 in / $0.87 out |
| **claude-sonnet** | High complexity, architecture | Design documents, architecture decisions, full system reasoning | $3.00 in / $15.00 out |

**The routing rule in one sentence**: if the task creates something new with cross-component reasoning → pro; if it fixes or updates something existing → flash; if it requires reasoning about the whole system → claude-sonnet.

### How Routing Works Day-to-Day

**Semi-automatic (Persona A/B with opencode):**
1. `/acp-route "describe your task"` — AI reads taxonomy + rules, classifies the task, creates a route file, and tells you the recommended model
2. You switch to that model in opencode's model picker (one click)
3. `/acp-proceed` — execute the task

**Fully automatic (Persona B/C with `acp-dispatch.ts`):**
```bash
# 1. Classify and create route file
/acp-route "Add retry logic to the auth service"
# → route file created: agent/routing/tasks/route-042.md
# → executor: deepseek-v4-pro

# 2. Dispatch — reads executor field, calls correct model, logs cost
npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/route-042.md
# → [ACP] Dispatching route-042 → deepseek-v4-pro (deepseek/deepseek-v4-pro)
# → [ACP] Context: ~420 system (cached) + ~1840 user tokens
# → ... model output streamed to terminal ...
# → [ACP] Tokens: 2260 in / 847 out | Cost: $0.0017
# → [ACP] Ledger updated: agent/routing/ledger.md
```

No model-switching needed — dispatch handles it automatically.

### Setting Up OpenRouter + acp-dispatch.ts (Persona B/C)

**Prerequisites**: Node.js 18+, an [OpenRouter](https://openrouter.ai) account with credits loaded for DeepSeek models.

**Step 1 — Install dispatch dependencies**
```bash
cd scripts
npm install
cd ..
```

**Step 2 — Add your API key**
```bash
# Add to your project .env (never commit this file)
echo "OPENROUTER_API_KEY=sk-or-v1-your-key-here" >> .env
export OPENROUTER_API_KEY="sk-or-v1-your-key-here"
```

**Step 3 — Test the dispatch loop**
```bash
# Create a route file via /acp-route in your AI tool first, then:
npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/route-001.md
```

**Step 4 — Review the cost ledger**
```bash
cat agent/routing/ledger.md
# | Date | Task ID | Type | Executor | In Tokens | Out Tokens | Cost |
# | 2026-05-04 | route-001 | bash-script-fix | deepseek-v4-flash | 1840 | 412 | $0.0004 |
```

**Step 5 — Update `agent/core/routing.yml`** to reflect your persona:
```yaml
session:
  executor: deepseek-v4-pro
  model: deepseek/deepseek-v4-pro
  persona: B
```

> **Override when needed**: Add `override_executor: claude-sonnet` to any route file's frontmatter to force a specific model regardless of taxonomy. Use this for critical tasks, then update taxonomy.yml if the pattern repeats.

### Daily opencode Workflow

```
Morning    → /acp-resume        (flash — loads context in 6 steps, ~30 sec)
New task   → /acp-route "task"  (flash — classifies task, creates route file)
Switch     → Change to pro/flash based on route recommendation
Execute    → /acp-proceed       (pro or flash — do the work)
EOD        → /acp-commit        (flash — writes sessions.md, stamps route files)
```

Weekly: `/acp-cost-report` — reviews ledger, suggests taxonomy corrections, reports total spend.

---

## Differences from Original ACP

| | Original ACP | ACP Enhanced |
| --- | --- | --- |
| Context loading | AI loads files ad hoc | Structured 6-step protocol with token budget |
| Memory | None — every session starts cold | sessions.md + lessons.md + ADRs + patterns |
| Task routing | None | Taxonomy-based routing to skill files |
| Mistake learning | None | Correction log appended per task type |
| VS Code commands | Manual file reference | 59 slash commands with autocomplete |
| opencode support | None | 59 slash commands in `.opencode/commands/` |
| Preferences | None | 4-level hierarchy (project > workspace > user > default) |
| Project registry | None | Global `~/.acp/projects.yaml` for multi-project tracking |
| Cost tracking | None | Per-task token + USD ledger via dispatch |
| Knowledge preservation | None | Proactive 7-trigger WAL system — writes session/lessons at moment of discovery, not only at session end |
| Git branch safety | None | Step 1b branch guard — warns if working on production branch; configurable via `git_workflow:` in `identity.yml` |
| Pre-impl audit | None | `/acp-audit --pre-impl` — 4-phase readiness check before coding: plan correctness, code cross-reference, carryover validation, operational completeness |
| Audit carryovers | None | `agent/memory/audit-carryovers.md` — tracks unresolved findings across sessions; surfaced at session start via Step 4.4 |
| Install | `curl \| bash` from original repo | Single bootstrap script from this fork |

The ACP command and workflow system (clarifications → design → plan → proceed) is identical to the original at the time of the fork.

> **Note**: The upstream [Agent Context Protocol](https://github.com/prmichaelsen/agent-context-protocol) continues to evolve independently. This comparison reflects our fork point. The upstream now has its own extended features (v7.x+) and the two implementations have diverged. Check the upstream README for its current capabilities.

### Recent Protocol Enhancements (v6.4–v6.6)

Three milestones shipped in May 2026 added significant protocol improvements on top of the base memory system:

#### M38 — Knowledge Preservation (v6.4.13)
Solved the "context overflow kills memory" problem. Previously, `/acp-commit` was framed as a passive end-of-session act. If context overflow terminated a session before commit, all in-session knowledge was permanently lost.

**Fix**: Proactive 7-trigger Write-Ahead Log (WAL) system. The agent now writes memory entries at the **moment of discovery**, not at session end:
- After every audit report is created → write session entry + lessons immediately
- After every git commit touching >5 files → treat as phase boundary → write session entry
- When a correction is given → write lesson immediately
- When a new pattern emerges → append to `patterns.md` before continuing
- When context window approaches capacity → write all pending ACP entries first

#### M39 — Git Branch Awareness (v6.5.0)
Prevents accidental commits to production branches. Configurable via `identity.yml`:

```yaml
# agent/core/identity.yml — uncomment to enable
git_workflow:
  default_working_branch: develop
  production_branch: main
  branch_model: gitflow-lite
```

When enabled:
- **Step 1b** in context-loading protocol warns if the agent is on the production branch and stops execution
- **Step 0** in `/acp-commit` blocks commits to the production branch
- `branch:` field added to sessions.md entry schema for session-level branch tracking

#### M40 — Pre-Implementation Audit Protocol (v6.6.0)
Catches implementation bugs before coding starts — wrong field names, missing imports, stale carryovers.

**`/acp-audit --pre-impl <route-or-task-file>`** runs 4 phases before implementation:
1. **Plan Correctness** — route file complete, `files_affected` accurate, no open blockers
2. **Code Cross-Reference** — reads actual codebase files and verifies field names, enums, HTTP methods, response shapes match
3. **Carryover Check** — reads `agent/memory/audit-carryovers.md` for pending items from prior audits
4. **Operational Completeness** — version bump planned, wiki updates planned if introducing new protocol

**`agent/memory/audit-carryovers.md`** — new persistent memory layer that tracks unresolved audit findings across sessions. The agent reads this at every session start (Step 4.4) and surfaces pending items before any work begins.

---

**Is ACP Enhanced worth it without the routing/dispatch system?** Yes — the memory layer is the primary value. Without memory, every AI session starts cold and you re-explain context every time. With ACP Enhanced, sessions compound: corrections are remembered by task type, architectural decisions never get re-debated, and session summaries load automatically. Routing is additive on top of that.

> **Detailed breakdown — what's automatic vs what requires your action**: [`docs/USAGE.md` → "ACP Enhanced vs Original ACP — The Memory Layer Explained"](docs/USAGE.md#acp-enhanced-vs-original-acp--the-memory-layer-explained)

---

# What is Agent Context Protocol (ACP)
ACP is an agent harness. It centers around markdown command files located in a project-level
or user-level `agent/commands` directory that agents treat as
directives. When an agent reads a command file, it enters "script execution mode".
In this mode, the agent will follow all steps and directives in that file the same way a standard scripting language might work. Commands support if statements,
branching, loops, subroutines, invoking external programs, arguments, and verification steps.
The second flagship feature is pattern documents to enforce best practices. Patterns are distributed via publishable,
consumable, and portable ACP patterns packages.

> **ACP Formal Definition**: documentation-first development methodology that enables AI agents to understand, build, and maintain complex software projects through structured knowledge capture.

If it's still unclear to you what ACP is or does or why it exists,
please read the section below. It's easier to show you common ACP
workflows and usecases than it is to try and explain ACP in abstract terms.

## Primary ACP workflow

### Generate and implement milestone from feature concept
ACP's primary workflow centers around generating markdown artifacts
complete enough for your agent to autonomously implement an 
entire milestone with no guidance in a single
continuous session. Milestones often contain anywhere from
three to twelve tasks. ACP faithfully and autonomously executes
milestones and tasks effectively even at the higher bound.
Below is a typical ACP workflow from concept to feature 
complete.

#### Define draft
Start by creating a file such as `agent/drafts/my-feature.draft.md`.

Drafts are free-form, but you may consider providing
any or none of following items:
- Feature concept
- Goal
- Pain point
- Problem statement
- Proposed solution
- Requirements

Instead of creating a draft, you may also discuss your feature interactively via chat.

#### Clarification
Once you have completed your draft, invoke `/acp-clarification-create` and your
agent will generate a comprehensive clarifications document which focuses on:
- Gaps in your requirements or proposed solution
- Ambiguous requirements
- Open questions
- Poorly defined specs

Respond to the agent's questions in part or in whole by providing your
input on the lines marked `>`. Your responses can include directives,
such as:
- Explore the codebase to answer this question yourself
- Research this using the web
- Read `agent/design/existing-relevant-design.md`
- Clarify your question
- Provide tradeoffs
- Propose alternate solutions
- Provide a recommendation
- Analyze this approach
- Use MCP tool `tool_name`

> Tip: If an answer you provided would have cascading effects
> on all subsequent questions, for instance, your response
> would make subsequent questions null and void,
> respond with "This decision has cascading effects on the
> rest of your questions".

Once you are satisfied with your partial or complete responses,
invoke `/acp-clarification-address`. This instructs the agent
to process your responses, execute any directives, and consider
any cascading effects of decisions. Once your agent completes your directives,
it rewrites the clarifications document, inserting its analysis,
recommendations, tradeoffs and other perspectives into the document
in `<!-- comment blocks -->` to provide visual emphasis on the portions
of the document it addressed or updated.

Proof the agent responses in the document and provide follow up
responses if necessary. It is recommended to iterate on your
clarifications doc via several chained `/acp-clarification-address`
invocations until all gaps and open questions are addressed
with concrete decisions. 

Simple features with low impact may require a single pass while
larger architectural features with high impact on your system would
benefit from many passes. It's not uncommon to make up to 
ten passes on features such as this. This part of the workflow
is key to the effectiveness of the rest of the ACP workflow.

It is recommended to spend the most time on clarifications and
to use as many passes as necessary to generate a bullet proof
mutual understanding of your feature specification. Gaps in your
specification will lead to subpar, unexpected and undesirable results.

The more gaps you leave in your clarification, the more likely
your agent will make implementation decisions you would not make yourself and
you will spend more time directing your agent to rewrite features
than you would have spent simply iterating on your clarifications 
document.

#### Design
If you took the time to generate a bullet proof clarifications document,
this step is essentially a noop. Invoke `/acp-design-create --from clar`.
This command invokes the subroutine `/acp-clarification-capture` in addition
to its primary routine. `/acp-clarification-capture` ensures every decision
made in your clarification document is captured in a key decisions appendix.
Clarifications are designed to be ephemeral which means your design is the
ultimate source of truth for your feature. Review the design carefully
and optionally iterate on it using chat. 

#### Planning
Once you are satisfied with the design, invoke `/acp-plan`. 
Your agent will propose a milestone and task breakdown.
Once you approve the proposal, the agent will generate planning
artifacts autonomously in one pass.

#### Proof the planning artifacts
Reviewing the planning artifacts is the second most important
part of the ACP workflow after clarifications. It is recommended
to thoroughly read and evaluate all planning documents meticulously.

Each planning artifact describes the specific changes the agent
will make and should be completely self contained. 

Planning artifacts are complete enough
that the agent does not need to read other documents in order to implement them.

However, they do include references to relevant design documents and patterns.
Your agent will do exactly what the planning artifacts instruct the agent to do.
If your planning artifacts do not match your expectations, you must iterate
on them or your agent will produce garbage. Therefore it is critical
to interrogate the planning artifacts rigorously.

You may consider using the [ACP visualizer](https://github.com/prmichaelsen/acp-visualizer)
to review your planning artifacts by running `npx @prmichaelsen/acp-visualizer`
in your project directory. This launches a web portal that ingests your
`progress.yaml` and generates a project status dashboard. The dashboard includes
milestone tree views, a kanban board, and dependency graphs. You can preview
milestones and tasks in a side panel or drill into them directly.

> **Why write planning documents?** Planning documents are essential to
> ACP's two primary value propositions: **a)** solving the agent context problem and
> **b)** maintaining context on long-lived, large scope projects.
> Because planning documents are self contained, your agent can refresh
> context on a task easily after context is condensed. Planning artifacts
> generate auditable and historical artifacts that inform how features were
> implemented and why they were implemented. They capture the entire history
> of your project and stay in sync with `progress.yaml`. They enable your
> agent to understand the entire lifecycle of your project as the scope
> of your project inevitably grows.

#### Fully autonomous implementation
The final and easiest step in the ACP workflow is invoking 
`/acp-proceed` to actually implement your feature.

If you are confident in your planning, run 
`/acp-proceed --yolo`, and the agent will
implement your entire milestone from start to finish,
committing each task along the way, with no input from
you. 

The agent will:
- Capture each milestone and task start timestamps in `progress.yaml`
- Use sub-agents as necessary (use `--noworktrees` if you do not want to use subagents)
- Run task completion verification steps, including tests or E2E tests
- Make atomic git commits after each task completion
- Update `progress.yaml` and capture completion timestamps
- Track metadata such as implementation notes

While it runs:
- Generate other planning docs for other features
- Play with dog at dog park (if vibecoding remotely)

#### Key Takeaways
- Crystal clear picture before 4-hour agent runs
- Task files create audit trails and reusable SOP
- Manual review gates prevent scope creep
- Use autonmous execution only after thorough planning

## How commands work
Each command file has a very heavy handed, hardened prompt directive at the top of each
command file that essentially hijacks your agent.

> **🤖 Agent Directive**: If you are reading this file, the command `@acp-index` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `@acp-index` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

In general, all agents respect this directive, however, Claude is the only agent I've tested ACP
with that never fails to enter execution mode on the first command read (which is just one of the
many reasons I recommend Claude over any other agent provider).

---

## Useful References

> *[Search ACP packages](https://prmichaelsen.github.io/agent-context-protocol/)*  

> *[Visualize your project](https://github.com/prmichaelsen/agent-context-protocol-visualizer)*   - `yes | npx @prmichaelsen/acp-visualizer` 

> *[CLI visualizer](https://github.com/prmichaelsen/acp-visualizer-tui)* - `npx acp-visualizer-tui` 

> *[Project dashboard](https://viz.agentcontextprotocol.net/?repo=prmichaelsen%2Fagent-context-protocol)*

> *[Claude Code](https://code.claude.com/docs/en/overview) is ACP's preferred coding agent provider, however any provider will work out of the box.*
---

## Quick Start

> **Using ACP Enhanced?** See the [Install ACP Enhanced in a New Project](#install-acp-enhanced-in-a-new-project) section above.

The steps below describe the original ACP bootstrap from the upstream repository.

### Requirements

- **OS**: Linux or macOS
- **Shell**: Bash 3.2+ (macOS system bash works; Bash 4+ recommended for best compatibility)
- **Git**: 2.x+

> macOS note: The default `/bin/bash` on macOS is 3.2. ACP Enhanced scripts are tested against bash 3.2 for compatibility — no Homebrew bash required. Homebrew's bash (`/opt/homebrew/bin/bash`) is typically 5.x and also works.

### Bootstrap a New Project (Original ACP)

```bash
curl -fsSL https://raw.githubusercontent.com/prmichaelsen/agent-context-protocol/mainline/agent/scripts/acp.install.sh | bash
```

### Update an Existing Project

You can update an existing project via `/acp-version-update` command or by running the update script directly:

```bash
curl -fsSL https://raw.githubusercontent.com/prmichaelsen/agent-context-protocol/mainline/agent/scripts/acp.version-update.sh | bash
```

Or if you have ACP already installed locally:

```bash
./agent/scripts/acp.version-update.sh
```

---

## Visualize Your Project

See your milestones, tasks, and progress in a live dashboard:

```bash
npx @prmichaelsen/acp-visualizer
```

Runs a local dashboard that reads your `agent/progress.yaml` and renders it as an interactive admin panel with table/tree views, search, filtering, and auto-refresh.

```bash
# Run from any ACP project directory
cd my-project
npx @prmichaelsen/acp-visualizer

# Or point at a specific file
npx @prmichaelsen/acp-visualizer /path/to/agent/progress.yaml

# Custom port
npx @prmichaelsen/acp-visualizer --port 4000
```

**Features**: Sortable milestone table, expandable tree view, fuse.js fuzzy search, status filtering, SSE auto-refresh (updates live as agents work), lenient YAML parsing that handles agent-maintained drift.

---

## What is ACP?

The **Agent Context Protocol** is a standardized directory structure and documentation pattern that transforms implicit project knowledge into explicit, machine-readable documentation. It provides:

- **Design Documents** - Architectural decisions and technical specifications
- **Milestones** - Project phases with clear deliverables
- **Tasks** - Granular, actionable work items
- **Patterns** - Reusable architectural and coding patterns
- **Progress Tracking** - YAML-based progress monitoring

This enables AI agents to pick up where previous agents left off, preserving all context and decisions across sessions.

---

This will create:
- `AGENT.md` - Complete ACP methodology documentation
- `agent/` directory with all template files
- `agent/scripts/` directory with update utilities

---

## Usage

Once ACP is installed, use these commands with your AI agent:

### Start Working on a Project

Type: **`/acp-init`** in VS Code Copilot or opencode.

> **Other agents?** Tell your agent: *"Read and execute `agent/commands/acp.init.md`"*

This will:
- Check for ACP updates
- Read all agent documentation
- Review source code
- Update stale documentation
- Prepare to work on tasks

### Continue Working

Type: **`/acp-proceed`** (or `AGENT.md: Proceed`)

This will:
- Continue with current or next task
- Update progress tracking
- Maintain documentation

### Resume a Previous Session

Type: **`/acp-resume`** ⭐ Recommended

This convenient command automatically:
- Initializes context (`/acp-init`)
- Reviews latest session report
- Continues with next task (`/acp-proceed`)

Perfect for starting new sessions or returning after breaks.

### Check Project Status

Type: **`/acp-status`**

This will:
- Display current milestone and progress
- Show current task
- List recent work and next steps

### Available Commands

**Workflow Commands** (`/acp-*` in VS Code Copilot or opencode | manual read on any agent):
- **`/acp-resume`** ⭐ - Resume work (init + report + proceed)
- **`/acp-init`** - Initialize agent context
- **`/acp-proceed`** - Continue with next task
- **`/acp-status`** - Display project status
- **`/acp-sync`** - Sync documentation with code
- **`/acp-validate`** - Validate ACP structure
- **`/acp-audit`** - Audit task completion status, bugs, and improvement opportunities
- **`/acp-report`** - Generate session report
- **`/acp-index`** - Manage the key file index (list, add, remove, explore, show)

**Package Management**:
- **`/acp-package-install`** - Install packages (supports `--global` flag)
- **`/acp-package-list`** - List installed packages (supports `--global` flag)
- **`/acp-package-info`** - Show package details (supports `--global` flag)
- **`/acp-package-update`** - Update packages (supports `--global` flag)
- **`/acp-package-remove`** - Remove packages (supports `--global` flag)
- **`/acp-package-search`** - Search for packages
- **`/acp-package-validate`** - Validate package structure
- **`/acp-package-publish`** - Publish package
- **`/acp-package-create`** - Create new package

**Entity Creation**:
- **`/acp-command-create`** - Create command files
- **`/acp-pattern-create`** - Create pattern files
- **`/acp-design-create`** - Create design documents
- **`/acp-task-create`** - Create task files
- **`/acp-spec`** - Generate spec from clarification, design, draft, requirements, or interactive

**Version Commands**:
- **`/acp-version-check`** - Show current ACP version
- **`/acp-version-check-for-updates`** - Check for updates
- **`/acp-version-update`** - Update ACP to latest version

**Project Registry**:
- **`/acp-project-list`** - List registered projects
- **`/acp-project-set`** - Switch to a project
- **`/acp-project-info`** - Show project details
- **`/acp-project-update`** - Update project metadata
- **`/acp-project-remove`** - Remove project from registry
- **`/acp-projects-sync`** - Discover unregistered projects

**Sessions** (Experimental):
- **`/acp-sessions`** - Manage and view active agent sessions across projects

**Git Commands**:
- **`/git-commit`** - Intelligent version-aware commits
- **`/git-init`** - Initialize git repository

See [AGENT.md](./AGENT.md) for complete command documentation and methodology.

---

## Global Package Installation

Install packages globally to `~/.acp/agent/` for package development or global command libraries:

```bash
# Install package globally
./agent/scripts/acp.package-install.sh --global https://github.com/user/acp-firebase.git

# Or via command
/acp-package-install --global https://github.com/user/acp-firebase.git

# List global packages
/acp-package-list --global

# Update global packages
/acp-package-update --global firebase

# Remove global packages
/acp-package-remove --global firebase
```

**Global vs Local**:
- **Global**: Installed to `~/.acp/agent/`, available for discovery in any project
- **Local**: Installed to `./agent/`, only available in current project
- **Precedence**: Local packages always override global packages

**Use cases for global installation**:
- Package development with full ACP tooling
- Common utilities used across many projects
- Building a personal command library
- Experimenting with packages before local installation

---

## Experimental Features

Install packages with experimental features:

```bash
# Install only stable features (default)
/acp-package-install --repo https://github.com/user/acp-firebase.git

# Install including experimental features
/acp-package-install --repo https://github.com/user/acp-firebase.git --experimental
```

**What are experimental features?**
- Bleeding-edge features that may change
- Require explicit opt-in via --experimental flag
- Once installed, update normally

See [AGENT.md](./AGENT.md#experimental-features) for complete documentation.

---

## Key File Index

ACP includes a weighted key file index (`agent/index/`) that ensures agents read critical project files before making decisions. Each entry declares a file path, priority weight, and which commands should read it.

```bash
# Manage the key file index
/acp-index list              # List all indexed key files
/acp-index add <path>        # Add a file to the index
/acp-index remove <path>     # Remove a file from the index
```

Packages can ship their own index files (`contents.indices` in package.yaml), which are automatically installed to `agent/index/` and discovered by commands.

See [AGENT.md](./AGENT.md#key-file-index) for complete documentation.

---

## Benchmark Suite

ACP includes an automated benchmark system that measures the impact of ACP on AI-driven development. It runs identical tasks with and without ACP, comparing metrics like token usage, code quality, and task completion.

```bash
# Run all benchmarks
bash agent/benchmarks/runner/run-benchmark.sh

# Run a specific task
bash agent/benchmarks/runner/run-benchmark.sh --task complex-auth-system

# View HTML reports
bash agent/benchmarks/runner/serve-reports.sh
```

**6 benchmark tasks** ranging from simple (hello-world) to complex (order pipeline with event-driven refactor). Each task includes automated verification and LLM-based quality evaluation.

See [AGENT.md](./AGENT.md#benchmark-suite) for complete documentation. On-demand CI via GitHub Actions (`workflow_dispatch`).

---

## Project Registry

Manage multiple ACP projects with the global project registry at `~/.acp/projects.yaml`:

```bash
# List all registered projects
/acp-project-list

# Switch to a specific project
/acp-project-set my-project

# View current project details
/acp-project-info

# Update project metadata (tags, status, description)
/acp-project-update --tags "typescript,api" --status in_progress

# Discover unregistered projects in ~/.acp/projects/
/acp-projects-sync

# Remove project from registry (keeps files)
/acp-project-remove old-project
```

**Key Features**:
- **Project Discovery**: List and filter projects by type, status, or tags
- **Context Switching**: Quickly switch between projects
- **Metadata Tracking**: Track type, status, tags, and relationships
- **Auto-Registration**: Projects auto-register when created via `/acp-project-create`

See [AGENT.md](./AGENT.md#project-registry-system) for complete documentation.

---

## Examples

### Sample ACP Projects

See these repositories for real-world examples of ACP in action:

- **[remember-mcp-server](https://github.com/prmichaelsen/remember-mcp-server)** - Multi-tenant memory system with vector search
- **[remember-mcp](https://github.com/prmichaelsen/remember-mcp)** - Memory management MCP implementation
- **[agentbase-mcp-server](https://github.com/prmichaelsen/agentbase-mcp-server)** - Agent base server implementation
- **[agentbase-mcp](https://github.com/prmichaelsen/agentbase-mcp)** - Agent base MCP tools
- **[google-calendar-mcp](https://github.com/prmichaelsen/google-calendar-mcp)** - Google Calendar integration MCP server
- **[mcp-auth](https://github.com/prmichaelsen/mcp-auth)** - Authentication framework for MCP servers

---

## Directory Structure

```
project-root/
├── AGENT.md                        # ACP documentation (this pattern)
├── agent/                          # Agent directory
│   ├── commands/                   # Command system
│   │   ├── .gitkeep
│   │   ├── command.template.md     # Command template
│   │   ├── acp.init.md             # /acp-init
│   │   ├── acp.proceed.md          # /acp-proceed
│   │   ├── acp.status.md           # /acp-status
│   │   └── ...                     # More commands
│   │
│   ├── design/                     # Design documents
│   │   ├── .gitkeep
│   │   ├── design.template.md      # Template for design docs
│   │   └── requirements.md         # Your project requirements
│   │
│   ├── milestones/                 # Project milestones
│   │   ├── .gitkeep
│   │   ├── milestone-1-{title}.template.md
│   │   └── milestone-1-foundation.md
│   │
│   ├── patterns/                   # Architectural patterns
│   │   ├── .gitkeep
│   │   ├── pattern.template.md
│   │   ├── bootstrap.template.md
│   │   └── typescript/             # Language-specific patterns
│   │       └── *.md
│   │
│   ├── tasks/                      # Granular tasks
│   │   ├── .gitkeep
│   │   ├── task-1-{title}.template.md
│   │   └── task-1-setup.md
│   │
│   ├── index/                      # Key file index
│   │   ├── local.main.yaml         # Project's key files
│   │   └── {pkg}.main.yaml         # Package-shipped indices
│   │
│   └── progress.yaml               # Progress tracking
│
└── (your project files)
```

---

## Template Files

ACP provides template files for each document type:

- **`design.template.md`** - Template for design documents
- **`milestone-1-{title}.template.md`** - Template for milestone documents
- **`task-1-{title}.template.md`** - Template for task documents
- **`pattern.template.md`** - Template for pattern documents
- **`bootstrap.template.md`** - Template for project bootstrap patterns
- **`progress.template.yaml`** - Template for progress tracking

Each template includes:
- Section headers with descriptions
- Example content showing proper usage
- Guidance on what to include
- Best practices and conventions

---

## Key Principles

1. **Documentation is Infrastructure** - Treat it with the same care as code
2. **Explicit Over Implicit** - Document everything that matters
3. **Structure Enables Scale** - Organization makes complexity manageable
4. **Agents Need Context** - Provide complete, accessible context
5. **Progress is Measurable** - Track objectively with YAML
6. **Patterns Ensure Quality** - Document and follow best practices
7. **Knowledge Persists** - No more lost tribal knowledge

---

## When to Use ACP

✅ **Use ACP when:**
- Complex projects (>1 month)
- Multiple contributors (agents or humans)
- Long-term maintenance required
- Quality and consistency critical
- Knowledge preservation important

❌ **Don't use ACP for:**
- Trivial scripts (<100 lines)
- One-off prototypes
- Throwaway code
- Simple, well-understood problems

---

## Documentation

For complete documentation, see [`AGENT.md`](./AGENT.md), which includes:

- Detailed explanation of each component
- Step-by-step usage instructions
- Best practices and conventions
- Problem-solving patterns
- Real-world examples

---

## Preferences System

Configure ACP behavior at user, workspace, or project level — without modifying commands or scripts.

### Quick Start

```bash
# See what's currently active
/acp-preferences-show acp

# Set a personal default (applies to all your projects)
/acp-preferences-set acp plan.draft.create_mode guided --user

# Use a one-click workflow preset
/acp-plan --preset acp.batch-planning
```

### Preference Levels

| Level | Location | When to use |
|-------|----------|-------------|
| **Project** | `agent/preferences/<ns>.default.yaml` | Project conventions |
| **Workspace** | `.vscode/preferences/<ns>.yaml` | Team / IDE settings |
| **User** | `~/.acp/agent/preferences/<ns>.default.yaml` | Personal defaults |
| **Default** | `agent/configurables/<ns>.configurables.yaml` | Package baseline |

**Precedence**: Project > Workspace > User > Default

### Key Preferences

| Preference | Default | Description |
|------------|---------|-------------|
| `plan.draft.create_mode` | `structured` | How drafts are created: `structured`, `guided`, `contextual`, `unstructured` |
| `plan.batch.auto_confirm` | `false` | Skip confirmation prompts in batch mode |
| `task.create.granularity` | `3` | Default task size in hours (1–8) |
| `validation.auto_fix.enabled` | `true` | Auto-fix validation issues |
| `output.verbosity.level` | `normal` | Output level: `quiet`, `normal`, `verbose` |

### Built-in Presets

| Preset | Mode | Auto-confirm | Verbosity |
|--------|------|-------------|-----------|
| `acp.batch-planning` | contextual | true | quiet |
| `acp.interactive-planning` | guided | false | verbose |
| `acp.rapid-prototyping` | contextual | true | quiet |

Usage: `/acp-plan --preset acp.batch-planning`

### Preference Commands

| Command | Purpose |
|---------|---------|
| `/acp-preferences-show acp` | View effective preferences with source |
| `/acp-preferences-show acp --presets` | List available presets |
| `/acp-preferences-create --level user` | Create user preference file |
| `/acp-preferences-set acp <path> <value>` | Set a preference value |
| `/acp-preferences-validate` | Validate all preference files |

See [AGENT.md](AGENT.md#acp-preferences-system) for complete documentation.

---

## Contributing

Contributions are welcome! Please:

1. Follow the existing template structure
2. Document your changes in design documents
3. Update relevant patterns
4. Add examples where helpful

---

## License

MIT License - See [LICENSE](./LICENSE) for details

---

## Links

- **Repository**: https://github.com/ssucipto/acp-enhanced
- **Issues**: https://github.com/ssucipto/acp-enhanced/issues
- **Upstream (Original ACP)**: https://github.com/prmichaelsen/agent-context-protocol
- **Documentation**: See [AGENT.md](./AGENT.md)

---

**The Agent Context Protocol is not just documentation—it's a development methodology that makes complex software projects tractable for AI agents.**
