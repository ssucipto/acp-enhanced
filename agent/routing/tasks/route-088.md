---
id: route-088
title: "Registry schema lint — require date:/name:, warn unquoted colons"
task_type: command-doc-update
milestone: M48
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.validate.md
  - agent/memory/patterns.md
  - agent/memory/sessions.md
files_affected:
  - agent/commands/acp.validate.md
tokens_est: 250
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 088: Registry Schema Lint

## Objective

Extend `/acp-validate --memory` with schema-level linting beyond YAML syntax:
require `date:` and `name:` fields on every pattern entry, require `date:` or
`type:` on every session entry, and warn on unquoted colons in scalar values.

## Context

Feedback-001 F-05 recommended registry schema lint as a distinct concern from
YAML syntax validation. Route-078 added YAML syntax parsing. This route adds
field-level schema enforcement as non-blocking warnings.

## Changes

### acp.validate.md — Step 2b Enhancement

Add schema checks (Step 2b, substep 4 — currently marked "optional, non-blocking"):

```markdown
4. **Schema checks** (warnings — do not affect exit code):
   - **Patterns**: Each entry MUST have `date:` and `name:` fields.
     Warn if missing. Warn on unquoted colons in `description:` values.
   - **Sessions**: Each entry MUST have `date:` or `type:` field.
     Warn if neither present. Warn on unquoted colons in `key_fact:` values.
   - **Progress**: Warn on unquoted colons in `notes:` values.
   
   Output format:
   ```
   ⚠️ agent/memory/patterns.md: entry 5 missing required field 'name:'
   ⚠️ agent/memory/patterns.md: line 120 unquoted colon in 'description:'
   ⚠️ agent/memory/sessions.md: entry 3 has neither 'date:' nor 'type:'
   ```
```

## Verification

- [ ] Missing `date:` on pattern entry produces warning
- [ ] Missing `name:` on pattern entry produces warning
- [ ] Missing `date:` and `type:` on session entry produces warning
- [ ] Unquoted colon in scalar value produces warning
- [ ] Warnings do NOT affect exit code (non-blocking)
- [ ] Valid entries produce no warnings

## Dependencies

- route-078 (--memory flag must exist)
