# ACP Enhanced — Step-by-Step Usage Guide

> This guide covers the day-to-day ACP workflow after initial setup.  
> For first-time setup (bootstrap, identity, ADRs), see [`scripts/QUICKSTART.md`](../scripts/QUICKSTART.md).  
> For fork/install details, see the project [`README.md`](../README.md).

---

## What ACP Enhanced Actually Does

ACP Enhanced gives your AI agent two things:

1. **Command system** — Markdown files in `agent/commands/` that the agent reads as executable scripts. When you type `/acp-plan`, the agent reads `agent/commands/acp.plan.md` and follows it step-by-step, just like a shell script.
2. **Context framework** — The `agent/` directory gives the agent a structured memory system (session log, corrections, patterns, decisions) that it loads within a strict token budget at the start of every session.

---

## Prerequisites

- ACP Enhanced installed in your project (bootstrap ran, `agent/` directory exists)
- GitHub Copilot, Claude Code, or Cursor as your AI agent
- Git repository initialized

---

## Step 1 — Start Every Session with `/acp-init`

At the beginning of every new chat session, run:

```
/acp-init
```

The agent will:
- Check if ACP has updates
- Read `agent/progress.yaml` (current milestone, task status, recent work)
- Load all design docs, milestone files, and active task documents
- Identify the current task and review relevant source files
- Catch any documentation drift (code changed but docs weren't updated)

**Fast mode** (skip source file review and sync checks):
```
/acp-init --quick
```

**Expected output**: The agent prints a structured summary of project state and tells you what the next task is.

---

## Step 2 — Check Project Status at Any Time

```
/acp-status
```

Reads `agent/progress.yaml` and shows:
- Current milestone and progress percentage
- Active task
- Recent completed work
- What's next

Use this instead of `/acp-init` when you just want a quick summary without a full context reload.

---

## Step 3 — Plan New Work with `/acp-plan`

When you have new requirements or undefined milestones/tasks:

```
/acp-plan
```

The agent scans `agent/progress.yaml` for undefined items and presents options. You can also be direct:

```
/acp-plan --milestone M20                    # Plan a specific milestone
/acp-plan --draft agent/drafts/my-idea.md   # Use a prepared draft
/acp-plan new feature: user authentication  # Inline description
/acp-plan --batch                           # Plan everything without prompting
```

### What Planning Produces

For each milestone, the agent creates:
- `agent/milestones/milestone-{N}-{name}.md` — goal, deliverables, success criteria
- `agent/tasks/milestone-{N}-{name}/task-{M}-{name}.md` — step-by-step implementation guide
- Updated `agent/progress.yaml` with all new items tracked

### Draft Modes

Control how the agent collects requirements via preference:

| Mode | Behavior |
|------|----------|
| `structured` | Creates a draft file with 3 guided questions (default) |
| `unstructured` | Creates an empty draft file for you to fill |
| `guided` | Collects requirements via chat — no file created |
| `contextual` | Infers from current context — no file created |

Set your preferred mode:
```
/acp-preferences-set acp plan.draft.create_mode guided
```

Override for a single run:
```
/acp-plan --plan.draft.create_mode contextual
```

### Using Presets

Presets bundle multiple preferences for a specific planning style:

```
/acp-plan --preset acp.batch-planning       # Fast, no confirmations, quiet output
/acp-plan --preset acp.interactive-planning # Guided, manual confirm, verbose
/acp-plan --preset acp.rapid-prototyping   # Contextual, auto-commit, coarse tasks
```

List available presets:
```
/acp-preferences-show acp --presets
```

---

## Step 4 — Implement Tasks with `/acp-proceed`

After planning, start implementation:

```
/acp-proceed
```

The agent picks up the current or next task, reads its task document step-by-step, implements the code changes, runs the verification checklist, and stops for your review.

### Autonomous Mode (implement an entire milestone without stopping)

```
/acp-proceed --complete          # Finish all tasks in current milestone
/acp-proceed --complete --yolo   # Same, skip confirmation prompt
/acp-proceed --yolo              # If task is already clear from context, start immediately
```

**What happens in autonomous mode:**
1. Agent reads the milestone and all task documents
2. Implements each task sequentially
3. Commits after each task (`@git.commit` is implied)
4. Prints a summary after all tasks complete

### Targeting a Specific Task

```
/acp-proceed --task task-42     # Jump to a specific task
```

---

## Step 5 — Commit with `@git.commit`

After completing a task or milestone:

```
@git.commit
```

The agent:
1. Detects what changed (staged + unstaged)
2. Determines appropriate semantic version bump (major/minor/patch)
3. Updates `CHANGELOG.md`
4. Updates version identifiers across the project
5. Stages relevant files
6. Commits with a conventional commit message

**You don't need to `git add` manually** — the command stages the right files automatically.

---

## Step 6 — End Every Session with `/acp-commit`

At the end of your work session, run the session commit protocol:

```
/acp-commit
```

The agent writes a session summary to `agent/memory/sessions.md` including:
- What tasks were completed
- What was deferred
- The single most important fact learned this session

This is how the agent "remembers" across sessions. **Don't skip this step.**

---

## Common Day-to-Day Patterns

### "I want to start a new feature from scratch"

```
1. /acp-plan                          ← Describe the feature when prompted
2. Review the generated milestone/task files
3. /acp-proceed                       ← Implement first task
4. @git.commit                        ← Commit after each task
5. (repeat 3-4 for each task)
6. /acp-commit                        ← End session
```

### "I just want to finish the current milestone fast"

```
/acp-proceed --complete --yolo
```

The agent handles everything: implements each task, commits, and reports when done.

### "I need to check what's going on before starting"

```
/acp-status                           ← Quick summary
/acp-init                             ← Full context load (use at session start)
```

### "I want to validate everything is consistent"

```
/acp-validate
```

Checks that task documents, progress.yaml, and code are consistent. Reports any drift.

---

## Managing Preferences

Preferences control agent behavior across commands (draft mode, task granularity, etc.).

### See current effective preferences

```
/acp-preferences-show acp
```

Output shows each preference, its value, and which level set it (project/workspace/user/default).

### Set a preference

```
/acp-preferences-set acp plan.draft.create_mode contextual
/acp-preferences-set acp task.create.granularity 2 --user   # Set globally for all projects
```

### Create a preference file from defaults

```
/acp-preferences-create --level user           # Set your personal defaults
/acp-preferences-create --level project        # Set project-wide defaults
/acp-preferences-create --level workspace      # Set per-workspace overrides
```

### Available Preferences

| Preference | Type | Default | Description |
|---|---|---|---|
| `plan.draft.create_mode` | string | `structured` | How drafts are created (`structured`/`unstructured`/`guided`/`contextual`) |
| `plan.batch.auto_confirm` | boolean | `false` | Skip confirmation in batch planning |
| `task.create.granularity` | number | `3` | Target hours per task (1–8) |
| `task.create.auto_number` | boolean | `true` | Auto-assign task numbers |
| `validation.auto_fix.enabled` | boolean | `false` | Auto-fix validation issues |
| `validation.strict_mode.enabled` | boolean | `false` | Treat warnings as errors |
| `output.verbosity.level` | string | `normal` | Output verbosity (`quiet`/`normal`/`verbose`) |
| `git.auto_commit.enabled` | boolean | `false` | Auto-commit after each task |

---

## Managing Packages

ACP Enhanced has a package system for distributing command sets.

```
/acp-package-install https://github.com/some/acp-package.git   # Install a package
/acp-package-list                                                # List installed packages
/acp-package-update acp-enhanced                                # Update this fork
/acp-package-remove some-package                                # Remove a package
/acp-package-info acp-enhanced                                  # Show package details
```

Installed packages land in `agent/commands/`, `agent/scripts/`, and `agent/schemas/`, tracked in `agent/manifest.yaml`.

---

## ACP Enhanced vs Original ACP — The Memory Layer Explained

This section explains what ACP Enhanced adds beyond the original ACP, and specifically what happens automatically vs. what requires your input. This is the most important thing to understand before using ACP Enhanced for the first time.

### What the Original ACP Gives You

The original ACP gives you command documents (`agent/commands/*.md`) and bash scripts that the agent treats as executable directives. You get a structured planning workflow (clarifications → design → plan → proceed) and YAML-based progress tracking. That's it — there is no memory between sessions.

### What ACP Enhanced Adds

ACP Enhanced adds a **memory and context management layer** on top of everything the original ACP provides. The layer has four components:

---

#### 1. Session Memory (`agent/memory/sessions.md`)

**What it is**: A YAML list of session summaries. Each entry records what was done, what was deferred, and the most important thing learned.

**Automatic**:
- Loaded automatically at session start by `/acp-resume` (last 3 entries only — never the whole file)
- Each entry includes a `key_fact` field the agent populates itself

**Requires your action**:
- You must run **`/acp-commit` at the end of every session** for an entry to be written. If you skip this, the session is lost. No session = no memory = next session starts cold.
- The session summary content is AI-generated, but you should review it for accuracy before closing

**Without this**: Every session starts from zero. You re-explain what you've been building, what decisions were made, and what the next step is — every single time.

**With this**: After 2–3 sessions, `/acp-resume` loads a paragraph of real project history. After 2 weeks, the agent knows your last 3 work sessions without you saying a word.

---

#### 2. Correction Log (`agent/memory/lessons.md`)

**What it is**: A running list of mistakes the agent made and what the correct behaviour is. Each entry records `task_type`, `mistake`, and `correction`.

**Automatic**:
- Loaded at session start, but **filtered** — only entries matching the current `task_type` (or marked `priority: high`) are loaded. Never the full file.
- The dispatch script uses `task_type` to filter lessons before building context

**Requires your action**:
- You must correct the agent and explicitly say **"log this"** or the correction is not written. The agent does not log its own mistakes silently — you have to trigger it.
- Format: just say what went wrong. Example: *"That's wrong — we never use `set -e` without an error trap in bash. Log it."* The agent appends the lesson immediately.

**Without this**: The agent makes the same class of mistakes across sessions. You correct the same bash pattern or the same naming convention repeatedly.

**With this**: After 5–10 corrections, the agent consistently avoids those patterns for the relevant task types.

---

#### 3. Architectural Decisions (`agent/memory/decisions.md`)

**What it is**: An ADR (Architectural Decision Record) log. Each entry captures what was decided, why, what alternatives were considered, and a **"DO NOT re-open"** marker.

**Automatic**:
- The agent loads only the ADR sections relevant to the current task (by ID), not the whole file
- `/acp-commit` checks if a decision was made during the session and prompts you to create an ADR

**Requires your action**:
- You run **`/acp-decide "decision title"`** to initiate an ADR. The agent drafts it; you confirm.
- You mark which decisions are settled. Unmarked decisions can still be re-debated.

**Without this**: The agent re-debates settled architecture every few sessions. "Should we use Firebase or Supabase?" gets re-litigated when enough context has faded. Time and tokens wasted.

**With this**: Settled decisions are permanently referenced. The agent will not re-open a decision marked "DO NOT re-open" unless you explicitly override it.

---

#### 4. Pattern Library (`agent/memory/patterns.md`)

**What it is**: Reusable solutions that worked. Patterns are loaded on tasks where they're relevant.

**Automatic**:
- `/acp-commit` checks if the session produced a reusable pattern and prompts if yes
- Patterns are loaded as part of Layer 3 context for matching task types

**Requires your action**:
- Confirming whether to write a pattern during `/acp-commit`. You can decline.
- Writing the pattern description yourself if the AI's draft isn't accurate

**Without this**: A solution you found once (e.g., how to safely write BSD-compatible `sed` on macOS) has to be rediscovered the next time it's needed.

**With this**: After a few weeks, the agent's first draft already uses solutions that previously required multiple correction rounds.

---

### Automatic vs Manual — Summary

| Feature | Happens Automatically | Requires Your Action |
|---|---|---|
| Session memory loaded | Yes — on every `/acp-resume` | Running `/acp-commit` to write it |
| Lessons loaded | Yes — filtered by task type | Saying "log this" after a correction |
| ADRs loaded | Yes — by reference in tasks | Running `/acp-decide` to create them |
| Patterns loaded | Yes — for matching task types | Confirming pattern write at `/acp-commit` |
| Model routing | Yes — taxonomy classifies automatically | Running `/acp-route` to trigger classification |
| Slash commands | Yes — autocomplete on `/` | Nothing — registered on bootstrap |
| Cost ledger | Yes — dispatch appends after every call | Setting up OpenRouter key once |

### The One Rule

**Run `/acp-commit` at the end of every session.**

Everything else in the memory system compounds from that single action. If you skip it, the session evaporates. If you run it consistently, ACP Enhanced becomes measurably faster and cheaper every week.

---

## The Key File Index

The key file index lets you tell the agent which files are most important to read during `/acp-plan` and `/acp-proceed`.

```
/acp-index                          # List indexed files
/acp-index add agent/design/my-design.md   # Add a file
/acp-index explore                  # Suggest files to add based on your codebase
```

---

## Reference: Command Quick-Reference

| Command | What it does |
|---|---|
| `/acp-init` | Full context load at session start |
| `/acp-init --quick` | Fast context load (skip source review) |
| `/acp-status` | Show project status from progress.yaml |
| `/acp-plan` | Plan milestones and tasks interactively |
| `/acp-plan --batch` | Plan all undefined items without prompting |
| `/acp-proceed` | Implement the current task |
| `/acp-proceed --complete --yolo` | Autonomously finish entire milestone |
| `@git.commit` | Version-aware commit with CHANGELOG update |
| `/acp-validate` | Check docs/code consistency |
| `/acp-preferences-show acp` | Show active preferences with source |
| `/acp-preferences-set acp <key> <val>` | Set a preference value |
| `/acp-package-install <url>` | Install an ACP package |
| `/acp-index explore` | Suggest key files to index |
| `/acp-commit` | Write session summary to `agent/memory/` |
| `/acp-route "<task>"` | Create a routed task file for a new task |

---

## Reference: File Locations

| Path | Purpose |
|---|---|
| `agent/progress.yaml` | Source of truth for all milestone/task status |
| `agent/commands/*.md` | Command directive files (what `/acp-*` reads) |
| `agent/scripts/*.sh` | Shell scripts bound to commands |
| `agent/milestones/milestone-{N}-*.md` | Milestone planning documents |
| `agent/tasks/milestone-{N}-*/task-{M}-*.md` | Task implementation guides |
| `agent/preferences/acp.default.yaml` | Project-level preference overrides |
| `agent/configurables/acp.configurables.yaml` | Available preferences with defaults |
| `agent/core/identity.yml` | Project identity loaded every session |
| `agent/memory/sessions.md` | Session history (last 15 entries) |
| `agent/memory/lessons.md` | Correction log (auto-appended on mistakes) |

---

## Git Branch Protection (GitFlow-Lite)

ACP Enhanced uses `develop` as the daily working branch and `mainline` as production (`agent/core/identity.yml → git_workflow`). Branch protection must be enabled in GitHub so CI gates merges.

### Required GitHub settings

**Repository → Settings → Branches → Add branch ruleset** (or classic protection rules):

| Branch | Rules |
|--------|--------|
| `mainline` | Require PR before merge · ≥1 approval · require status checks (`validate`, `shellcheck`, `e2e-smoke`) · require branches up to date · block force pushes and deletions |
| `develop` | Require PR before merge (optional self-review) · require status checks (`validate`, `shellcheck`, `e2e-smoke`) · block force pushes |

### Verify

- Direct `git push origin mainline` from a local branch should be rejected.
- PRs cannot merge until CI jobs are green.

> **Note:** Branch protection is a repository setting — enable manually in GitHub or via `gh api` with admin permissions. Document confirmation in route-162 when enabled.

---

## Troubleshooting

**Agent ignores `/acp-plan` or doesn't follow the steps**  
→ The command file in `agent/commands/acp.plan.md` must be readable by the agent. In VS Code Copilot, type `/acp-plan` in chat — Copilot will read the matching `.md` file if it's in `agent/commands/`. In Claude Code, the agent reads `AGENT.md` which references the command system.

**Preferences don't seem to take effect**  
→ Run `/acp-preferences-show acp` to see the effective values and which level each came from. Check that your preference file is at the right path and uses the correct format.

**progress.yaml is out of sync**  
→ Run `/acp-validate` to detect inconsistencies. The agent will report what's stale and offer to fix it.

**Session context runs out mid-task**  
→ Run `/acp-report` to generate a handoff summary, then start a new session and run `/acp-resume` to pick up where you left off.
