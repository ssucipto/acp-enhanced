# Milestone 22: Documentation Accuracy Audit

**Status**: Completed  
**Priority**: 5  
**Milestone**: M22  
**Started**: 2026-05-01  
**Completed**: 2026-05-01  

## Overview

Fourth comprehensive audit of ACP Enhanced documentation. Focused on documentation accuracy:
`AGENT.md` directory tree correctness, stale command/script references, and the bootstrap
template (`scripts/AGENTS.md`) completeness.

## Tasks

| ID | Title | Status |
|----|-------|--------|
| task-126 | Fix AGENT.md Directory Tree | ✅ Completed |
| task-127 | Fix AGENT.md Stale References | ✅ Completed |
| task-128 | Update scripts/AGENTS.md Bootstrap Template | ✅ Completed |

## Success Criteria

- [x] AGENT.md directory tree matches actual disk contents (no ghosts, no omissions)
- [x] All command/script references in AGENT.md point to real, correctly-named items
- [x] `scripts/AGENTS.md` bootstrap template includes bash-safety anti-patterns shipped in ACP scripts

## Changes Made

### FIX-A: AGENT.md Directory Tree (task-126)

**Removed** ghost entry:
- `agent/files/` (with `config/` and `src/`) — this directory does not exist on disk

**Added** 7 missing directories:
- `agent/artifacts/` — glossary.template.md, reference.template.md, research.template.md
- `agent/benchmarks/` — runner/ and suite/ subdirs
- `agent/clarifications/` — clarification-{N}-{title}.md template
- `agent/feedback/` — placeholder directory
- `agent/schemas/` — package.schema.yaml, progress.schema.yaml, projects.schema.yaml
- `agent/scripts/` — all 28 shell scripts (acp.*.sh)
- Template files at `agent/` root level: manifest.yaml, manifest.template.yaml, package.template.yaml,
  progress.template.yaml, projects.template.yaml, sessions.template.yaml

**Restructured** tree for logical grouping: scripts/ and schemas/ placed after design/, AGENTS.md
added at root level.

### FIX-B: AGENT.md Stale References (task-127)

- `@acp.install` → `@acp.package-install` in "Installing Third-Party Commands" section
  (the stale "(available in future release)" qualifier was also removed — it is shipped)
- `unacp.install.sh` → `acp.uninstall.sh` in "Uninstall Prompt" section (x2 occurrences)

### FIX-C: scripts/AGENTS.md Bootstrap Template (task-128)

Added 2 bash-safety anti-patterns to the "Anti-Patterns (Never Do These)" section:
- `Never use set -e without trapping errors in bash scripts`
- `Never write bash that breaks on macOS (BSD sed, date +%N differences)`

These rules were already present in `.github/copilot-instructions.md` (this project's own
AGENTS.md instance) but were absent from the bootstrap template new projects receive.
