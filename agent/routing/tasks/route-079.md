---
id: route-079
title: "/acp-version-update guard — don't overwrite project-specific core files"
task_type: bug-fix
milestone: M47
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.version-update.md
  - agent/core/identity.yml
files_affected:
  - agent/commands/acp.version-update.md
tokens_est: 350
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason: "Reopened audit-080 (2026-07-15) — M47 shipped doc-only; script never implemented. M68 route-199 completes for real."
---

# Route 079: Version Update Guard

## Objective

Add a guard to `/acp-version-update` that warns before overwriting project-specific files
in `agent/core/` (identity.yml, domain.yml, taxonomy.yml). These files contain project-specific
configuration that should not be silently replaced during framework version bumps.

## Context

FIFOZ feedback-002 (F-03) reported that `/acp-version-update` overwrote project-specific
`identity.yml`, `domain.yml`, and `taxonomy.yml` during a 6.8.2 bump. This required
`git restore` to recover project configuration.

The version update command should:
1. Detect which core files have been modified from the framework defaults
2. Warn and confirm before overwriting any modified files
3. Provide a `--diff` flag to show what would change
4. Provide a `--preserve-project-core` flag to skip project-modified files

## Steps

### Update `/acp-version-update` Command Doc

1. **Add `--diff` flag**: Show diff between current files and what the update would write.
   No files are changed. Useful for pre-update review.

2. **Add `--preserve-project-core` flag**: Skip overwriting of project-specific core files
   (identity.yml, domain.yml, taxonomy.yml, constraints.yml). Only update framework files.

3. **Default behavior**: Before overwriting any `agent/core/*.yml` file:
   - Check if file content differs from framework template
   - If modified → warn: `⚠️ {file} has been modified from framework defaults. Overwrite? (y/N)`
   - If unmodified → overwrite silently (current behavior)

4. **Add `--force` flag**: Skip confirmation prompts, overwrite all files.

### Files to Guard

| File | Rationale |
|------|-----------|
| `agent/core/identity.yml` | Contains project name, stack, repo URL, version — project-specific |
| `agent/core/routing.yml` | Contains session config, context_modes, command_suggestions — may be customized |
| `agent/core/constraints.yml` | Contains project rules — may be customized |

## Verification

- [ ] `--diff` shows changes without modifying files
- [ ] Default behavior warns before overwriting modified core files
- [ ] `--preserve-project-core` skips all project-modified core files
- [ ] `--force` overwrites everything without prompts
- [ ] Unmodified core files are updated silently (backward compatible)

## Dependencies

None.
