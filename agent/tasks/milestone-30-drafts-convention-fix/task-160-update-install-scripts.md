---
id: task-160
milestone: M30
title: Update install scripts to create agent/drafts/
status: completed
priority: 4
complexity: low
estimated_hours: 1
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: update, install, scripts, to, create, agentdrafts
description: Update install scripts to create agent/drafts/
milestone: M30
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Update `agent/scripts/acp.install.sh` and `scripts/acp-bootstrap.sh` to create `agent/drafts/` during project installation, ensuring fresh clones have the directory available without needing to run a separate setup step.

## Context

`agent/drafts/` is a local-only directory (gitignored content, but `.gitkeep` and `draft.template.md` are tracked from task-159). When a user clones the repo and runs the install script, the directory exists because those tracked files are in the repo. However, when the install script runs on a new project (not a clone of ACP Enhanced itself), the directory may not be present if only `agent/` subdirectories are created programmatically.

Specifically, `acp.install.sh` and `acp-bootstrap.sh` create several `agent/` subdirectories during setup. This task adds `agent/drafts/` to that list.

## Implementation

1. Open `agent/scripts/acp.install.sh`
2. Find the section that creates `agent/` subdirectories (look for `mkdir -p agent/memory`, `mkdir -p agent/tasks`, or similar)
3. Add: `mkdir -p agent/drafts`
4. Open `scripts/acp-bootstrap.sh`
5. Find the same directory-creation section
6. Add: `mkdir -p agent/drafts`
7. Both scripts should also copy `draft.template.md` if it doesn't exist:
   ```bash
   if [ ! -f "agent/drafts/draft.template.md" ]; then
     cp "${ACP_SOURCE}/agent/drafts/draft.template.md" "agent/drafts/draft.template.md" 2>/dev/null || true
   fi
   ```

**macOS note**: Use `mkdir -p` (POSIX-safe, no-op if directory exists). Do NOT use `install -d` (GNU-only behavior differences on macOS).

## Expected Output

### Files Updated
- `agent/scripts/acp.install.sh`
- `scripts/acp-bootstrap.sh`

## Verification
- [ ] `grep "agent/drafts" agent/scripts/acp.install.sh` returns a `mkdir` line
- [ ] `grep "agent/drafts" scripts/acp-bootstrap.sh` returns a `mkdir` line
- [ ] Running `bash agent/scripts/acp.install.sh` on a fresh clone creates `agent/drafts/`
- [ ] Idempotent: running install twice does not error (`mkdir -p` is safe)

## User-Observable Acceptance
`agent/drafts/` exists after any fresh install. `/acp-plan` can create draft files immediately without errors.
