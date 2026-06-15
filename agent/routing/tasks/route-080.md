---
id: route-080
title: "YAML quoting directives — prevent unquoted colon parse failures"
task_type: command-doc-update
milestone: M47
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/commands/acp.update.md
  - agent/progress.yaml
files_affected:
  - agent/commands/acp.commit.md
  - agent/commands/acp.update.md
  - agent/commands/acp.plan.md
tokens_est: 350
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 080: YAML Quoting Directives

## Objective

Add agent directives to `/acp-commit`, `/acp-update`, and `/acp-plan` command docs that
require quoting YAML scalar values containing `:` (colons) to prevent js-yaml/ruby-yaml
parse failures.

## Context

FIFOZ feedback-001 documented 7 YAML defects caused by unquoted colons:
- `progress.yaml:795` — `notes:` unquoted colon (`CO-124 resolved: ...`)
- `progress.yaml:1380` — `notes:` unquoted colon (`^:^ ALLOWED_ORIGINS`)
- `sessions.md:277-291` — 5 instances of `key_facts:` with unquoted colons
  (e.g., `M_KDF: react-native-quick-crypto...`, `Hermes: @noble/...`)

These cause js-yaml (visualizer's parser) to reject the entire file. Ruby/libyaml parses
leniently but silently merges entries — data loss without error.

The fix has two parts:
1. **Prevention**: Agent directives to quote scalars containing `:`
2. **Detection**: route-078 (`/acp-validate --memory`) catches existing instances

## Changes

### acp.commit.md — Session Entry Writing (Step 2)

Add directive:
```
> **YAML quoting rule**: When writing `key_fact` or `key_facts` values, if the value
> contains a colon (`:`), wrap the entire scalar in double quotes or use a literal
> block scalar (`|`). Examples: `key_fact: "M_KDF: react-native-quick-crypto..."`
> or use `key_fact: |` with indented content.
```

### acp.commit.md — Weekly Compaction (Step 6)

Add directive:
```
> **YAML quoting**: Each item in `key_facts` list must be quoted if it contains `:`.
> Bad:  `- M_KDF: react-native-quick-crypto...`
> Good: `- "M_KDF: react-native-quick-crypto..."`
```

### acp.update.md — Progress Notes Writing

Add directive:
```
> **YAML quoting rule**: When writing `notes:` values in progress.yaml, if the value
> contains a colon (`:`), wrap the entire scalar in double quotes.
> Bad:  `notes: CO-124 resolved: fixed the thing`
> Good: `notes: "CO-124 resolved: fixed the thing"`
```

### acp.plan.md — Task/Milestone Creation

Add directive in step 8 (Update progress.yaml):
```
> **YAML quoting**: When writing `notes:` values, quote scalars containing `:`.
```

## Verification

- [ ] acp.commit.md has quoting directive in Step 2
- [ ] acp.commit.md has quoting directive in Step 6
- [ ] acp.update.md has quoting directive for notes
- [ ] acp.plan.md has quoting directive for notes
- [ ] route-078 (`--memory`) catches unquoted colon instances

## Dependencies

- route-078 (validation catches existing instances)
