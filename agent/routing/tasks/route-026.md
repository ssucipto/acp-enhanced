---
id: route-026
title: M41a — Create acp.install.md command doc (BUG-003c)
task_type: command-doc-write
milestone: M41
complexity: medium
executor: deepseek-v4-pro
context_required:
  - wiki/domain.yml#commands
  - memory/patterns.md
  - agent/scripts/acp.install.sh
  - scripts/acp-bootstrap.sh
files_affected:
  - agent/commands/acp.install.md
  - .github/prompts/acp-install.prompt.md
  - .opencode/commands/acp-install.md
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Create `agent/commands/acp.install.md` — the missing command doc for the install system. `acp.install.sh` (18,576 bytes) handles local/global ACP package installation but has no agent-invocable companion. Currently, install can only be done via `acp-bootstrap.sh` with no IDE-side command. Closes BUG-003c from audit-014.

All three companion files must be created atomically.

## Acceptance Criteria

- [ ] `agent/commands/acp.install.md` created with standard ACP command directive header
- [ ] Version 1.0.0, Created 2026-05-11, Status: Active
- [ ] **Purpose**: Install, upgrade, or remove ACP packages and verify installation health
- [ ] **Arguments**:
  - `--global` — install to `~/.acp/` (global packages available to all projects)
  - `--local` — install to current project's `agent/` directory
  - `--upgrade` — upgrade installed ACP commands and scripts to latest version
  - `--check` — verify install health without making changes
- [ ] **Steps**:
  - Step 0: Display header
  - Step 1: Parse flags and determine install mode
  - Step 2: Check prerequisites (bash version, git, acp-bootstrap.sh present)
  - Step 3: Invoke `bash agent/scripts/acp.install.sh` with appropriate flags
  - Step 4: Verify install (check key files exist, run /acp-validate)
  - Step 5: Report outcome
- [ ] `.github/prompts/acp-install.prompt.md` created
- [ ] `.opencode/commands/acp-install.md` created
- [ ] All 3 files created atomically

## Implementation Notes

Read `agent/scripts/acp.install.sh` carefully before writing Steps — match the actual flags and install modes implemented in the script. The command doc must accurately reflect what the script does, not what we wish it did.
