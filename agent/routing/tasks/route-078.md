---
id: route-078
title: "/acp-validate --memory — YAML lint for memory registries"
task_type: command-doc-write
milestone: M47
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.validate.md
  - agent/memory/patterns.md
  - agent/memory/sessions.md
  - agent/progress.yaml
files_affected:
  - agent/commands/acp.validate.md
  - agent/memory/patterns.md (validated by this command)
  - agent/memory/sessions.md (validated by this command)
  - agent/progress.yaml (validated by this command)
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 078: Memory YAML Validation

## Objective

Extend `/acp-validate` with a `--memory` flag that YAML-parses `agent/memory/patterns.md`,
`agent/memory/sessions.md`, and `agent/progress.yaml`, failing with line numbers on syntax
errors.

## Context

Currently `/acp-validate`:
- Step 2: Checks `progress.yaml` structure (fields present) but does NOT validate YAML syntax
- Step 6: Validates `agent/patterns/*.md` document structure, NOT the `agent/memory/patterns.md` registry
- Step 11.6: Validates `agent/memory/sessions.md` STRUCTURE (required keys: `date`, `executor`,
  `tasks`, `done`; date format: YYYY-MM-DD). Does NOT validate raw YAML syntax.

This means malformed registry YAML (duplicate keys, bad indentation, unquoted colons) is only
caught at visualizer runtime or manual inspection. The existing structural validation confirms
fields are present but a file with broken YAML syntax would still be accepted.

## Steps

### New Step: Validate Memory YAML (after existing Step 2 or as Step 2b)

When `--memory` flag is provided:

1. **Validate `agent/memory/patterns.md`**:
   - Parse as YAML
   - Check for: duplicate mapping keys, bad indentation, unquoted colons in scalar values
   - If parse fails → report `FAIL: agent/memory/patterns.md: line N: {error message}`
   - If parse succeeds → report `PASS: agent/memory/patterns.md: N entries`

2. **Validate `agent/memory/sessions.md`**:
   - Parse as YAML
   - Handle both regular entries and `type: weekly-summary` blocks
   - Same error reporting as patterns.md

3. **Validate `agent/progress.yaml`** (enhanced — currently structural only):
   - Parse as YAML (full syntax validation, not just field checking)
   - Check for unquoted colons in `notes:` and `key_fact:` values
   - Report line numbers for syntax errors

4. **Schema checks** (optional, non-blocking):
   - Verify each pattern entry has required fields: `date:`, `name:`
   - Verify each session entry has `date:` or `type:` field
   - Warn on unquoted colons in scalar values

### Without `--memory` Flag

Existing behavior is unchanged. `--memory` is additive.

## Verification

- [ ] `acp-validate --memory` detects malformed YAML with line numbers
- [ ] `acp-validate --memory` passes on clean memory files
- [ ] `acp-validate` without `--memory` behaves identically to v6.8.2
- [ ] Duplicate mapping keys detected
- [ ] Unquoted colons in scalar values produce warnings
- [ ] Weekly-summary blocks in sessions.md are handled

## Dependencies

- route-074/075 (validation should run before sync attempts)
