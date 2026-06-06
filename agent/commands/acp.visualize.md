# Command: visualize

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-visualize` has been invoked.
> Follow the steps below to launch the ACP Progress Visualizer.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-06  
**Last Updated**: 2026-06-03  
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

- [`/acp-status`](acp.status.md) — Text-based status (no browser required)
- [`/acp-report`](acp.report.md) — Generate a text report

---

## Notes

- The visualizer auto-refreshes when `progress.yaml` changes — no manual reload needed
- P1 features (GitHub remote, kanban, multi-project) are in a future milestone
- To use with a different project: `/acp-visualize --path /path/to/other/agent/progress.yaml`
