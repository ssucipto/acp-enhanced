# Task 144: @acp.visualize Command + ACP Integration

<!-- @acp.meta.task
topic: acpvisualize, command, acp, integration
description: Task 144: @acp.visualize Command + ACP Integration
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-144  
**Priority**: P0  
**Estimated Hours**: 1–2h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-143 (Dashboard Shell)

---

## Objective

Create the `@acp.visualize` command file in ACP core that documents how to launch the visualizer and opens the dashboard against the current project's `progress.yaml`.

---

## Context

The visualizer lives in a separate repository and must be explicitly launched. The `@acp.visualize` command makes this discoverable and consistent with ACP's command-driven workflow. It also serves as the integration point that links ACP core to the visualizer project.

---

## Steps

### 1. Create `agent/commands/acp.visualize.md` (in ACP core repo)

```markdown
# Command: visualize

> **🤖 Agent Directive**: If you are reading this file, `@acp.visualize` has been invoked.
> Follow the steps below to launch the ACP Progress Visualizer.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Status**: Active  
**Requires**: agent-context-protocol-visualizer repository cloned locally

---

**Purpose**: Launch the ACP Progress Visualizer dashboard for the current project  
**Category**: Workflow  
**Frequency**: As Needed  

---

## What This Command Does

Launches the TanStack Start development server for `agent-context-protocol-visualizer`
and opens the browser dashboard pointed at the current project's `progress.yaml`.

---

## Prerequisites

- [ ] `agent-context-protocol-visualizer` cloned locally
- [ ] Node.js 18+ installed
- [ ] Dependencies installed (`npm install` in visualizer directory)

---

## Steps

### 1. Locate the visualizer repository

Check for the visualizer in these locations (in order):
1. `VISUALIZER_PATH` environment variable (if set)
2. `~/.acp/visualizer/` (default global install path)
3. Sibling directory: `../agent-context-protocol-visualizer/`
4. Current user's `~/code/agent-context-protocol-visualizer/`

If not found, display:
```
⚠️  Visualizer not found. Install it:
  git clone https://github.com/ssucipto/agent-context-protocol-visualizer ~/.acp/visualizer
  cd ~/.acp/visualizer && npm install
```

### 2. Resolve progress.yaml path

Use the current project's `progress.yaml`:
```
PROGRESS_YAML_PATH = <cwd>/agent/progress.yaml
```

Verify the file exists before launching.

### 3. Launch the dev server

```bash
cd <visualizer-path>
PROGRESS_YAML_PATH=<cwd>/agent/progress.yaml npm run dev
```

If the server is already running on port 3000, skip launch and go to step 4.

### 4. Open the browser

```bash
# macOS
open http://localhost:3000

# Linux
xdg-open http://localhost:3000

# Windows
start http://localhost:3000
```

### 5. Report

Display:
```
✅ ACP Progress Visualizer launched
   Dashboard: http://localhost:3000
   Data: <resolved progress.yaml path>
   Auto-refresh: enabled (file watcher active)

   Press Ctrl+C in the visualizer terminal to stop.
```

---

## Arguments

| Argument | Description |
|----------|-------------|
| `--path <file>` | Use a specific progress.yaml path instead of current project |
| `--port <N>` | Run dev server on a different port (default: 3000) |
| `--no-open` | Start server but don't open browser |

---

## Related Commands

- [`@acp.status`](acp.status.md) — Text-based status (no browser required)
- [`@acp.report`](acp.report.md) — Generate a text report

---

## Notes

- The visualizer auto-refreshes when `progress.yaml` changes — no manual reload needed
- P1 features (GitHub remote, kanban, multi-project) are in M26
- To use with a different project: `@acp.visualize --path /path/to/other/agent/progress.yaml`
```

### 2. Update `AGENT.md` Core Commands — add `@acp.visualize`

In the ACP core `AGENT.md`, under the **Workflow** category in Core Commands, add:

```markdown
| `@acp.visualize` | Launch the browser-based ACP Progress Visualizer dashboard | (ACP Enhanced) |
```

Place after `@acp.status`.

### 3. Update `agent/progress.yaml` notes

Add a note that M25 adds the visualizer command:
```yaml
- "@acp.visualize command added (M25) — launches TanStack Start dashboard for progress.yaml"
```

### 4. Commit both repos

**In `agent-context-protocol-visualizer`** (visualizer repo):
```bash
git add .
git commit -m "feat: M25 P0 complete — TanStack Start dashboard with table/tree/search/filter"
git push origin main
```

**In `agent-context-protocol`** (ACP core repo):
```bash
git add agent/commands/acp.visualize.md AGENT.md agent/progress.yaml
git commit -m "feat(commands): add @acp.visualize command — M25 ACP Progress Visualizer"
```

---

## Expected Output

### Files Created
- `agent/commands/acp.visualize.md` (in ACP core repo)

### Files Modified
- `AGENT.md` — `@acp.visualize` added to Workflow category in Core Commands

---

## Verification

- [ ] `agent/commands/acp.visualize.md` exists with all required sections (Purpose, Prerequisites, Steps, Arguments)
- [ ] `@acp.visualize` appears in `AGENT.md` Core Commands table under Workflow
- [ ] Command correctly resolves visualizer path from environment variable or default locations
- [ ] Command fails gracefully if visualizer repo not found (displays install instructions)
- [ ] `--path`, `--port`, `--no-open` flags are documented

---

## User-Observable Acceptance

- Invoking `@acp.visualize` in a Copilot session causes the agent to launch the dev server and open `http://localhost:3000` in the browser
- `AGENT.md` Core Commands → Workflow section shows `@acp.visualize` with description "Launch the browser-based ACP Progress Visualizer dashboard"
