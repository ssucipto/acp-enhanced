---
id: route-049
title: R4 — Make Prompt Wrappers Optional
task_type: bash-scripting
milestone: M44
complexity: low
executor: deepseek-v4-flash
context_required: [scripts/acp-bootstrap.sh, agent/manifest.yaml]
files_affected: [scripts/acp-bootstrap.sh, agent/manifest.yaml, docs/USAGE.md]
tokens_est: 2000
created: 2026-06-03
completed:
---

# R4: Optional Prompt Wrappers

**Source**: audit-022, ChoreHive feedback R4 (P2)
**Status**: ⚠️ Config done (manifest.yaml), bash implementation pending (route-059)

## Problem

57 `.github/prompts/` wrapper files generated unconditionally. Each is a thin redirect to the actual command file. Agents in all 14 sessions read command docs directly — wrappers were never consulted. Wrappers should be opt-in.

## Solution

Make prompt wrapper generation controlled by a flag:
```yaml
# agent/manifest.yaml
prompts:
  generate_wrappers: false   # default
```

## Acceptance Criteria

- [ ] `acp-bootstrap.sh` checks manifest `prompts.generate_wrappers` flag
- [ ] Default: no `.github/prompts/` directory generated
- [ ] When flag is true: generate prompt wrappers as before
- [ ] `docs/USAGE.md` updated with opt-in instructions
