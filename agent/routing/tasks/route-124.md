---
id: route-124
title: "Port acp.cursor-commands-sync.sh from feedback to agent/scripts/"
task_type: bash-script-create
milestone: M53
complexity: low
executor: copilot
context_required:
  - agent/feedback/acp.cursor-commands-sync.sh
  - agent/feedback/feedback-001-cursor-slash-commands-bootstrap.md
  - agent/patterns/local.e2e-testing.md
files_affected:
  - agent/scripts/acp.cursor-commands-sync.sh
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 124: Port acp.cursor-commands-sync.sh

## Objective

Copy `agent/feedback/acp.cursor-commands-sync.sh` → `agent/scripts/acp.cursor-commands-sync.sh` with adaptations for ACP Enhanced distribution.

## Context

The reference script from SmartDojo generates `.cursor/commands/<slash-name>.md` wrappers from every `agent/commands/acp.*.md` and `git.*.md` source. Wrappers are thin stubs — they reference the canonical `agent/commands/` source, never duplicate command bodies.

**Naming rule**: `acp.init` → `/acp-init` (dots become hyphens in slash names).

## Changes

### 1. Port the script

Copy `agent/feedback/acp.cursor-commands-sync.sh` → `agent/scripts/acp.cursor-commands-sync.sh`

### 2. Verify adaptations

- **Shebang**: `#!/bin/bash` with `set -euo pipefail` (ACP convention)
- **ROOT detection**: Uses `$(cd "$(dirname "$0")/../.." && pwd)` — verify works from install context
- **`to_slash_name()`**: `sed 's/\./-/g'` on basename — verify handles `acp.design-spec` → `acp-design-spec`
- **`extract_purpose()`**: Greps `**Purpose**:` from command doc — verify fallback to "ACP Enhanced command"
- **YAML frontmatter**: `description` double-quoted, escapes embedded quotes
- **Wrapper content**: References canonical source + equivalent invocations
- **Output message**: "Generated N Cursor slash commands in .cursor/commands/"

### 3. macOS compatibility

- `sed` operations use basic regex (BSD sed compatible)
- No GNU-specific flags
- `printf` used instead of `echo -e` for portability where needed

## Verification

- [ ] `agent/scripts/acp.cursor-commands-sync.sh` exists
- [ ] Executable: `chmod +x` applied
- [ ] `bash agent/scripts/acp.cursor-commands-sync.sh` runs without error
- [ ] Generates `.cursor/commands/` with one file per `acp.*.md` + `git.*.md`
- [ ] Naming: `acp.init` → `acp-init.md`, `git.commit` → `git-commit.md`
- [ ] Each wrapper has YAML frontmatter with `description`
- [ ] Each wrapper references `agent/commands/<source>` as canonical
- [ ] macOS bash compatible (no GNU extensions)
