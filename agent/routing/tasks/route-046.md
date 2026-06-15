---
id: route-046
title: R3 — Add --team-size Scaffold Flag
task_type: bash-scripting
milestone: M44
complexity: medium
executor: deepseek-v4-pro
context_required: [scripts/acp-bootstrap.sh, docs/USAGE.md]
files_affected: [scripts/acp-bootstrap.sh, docs/USAGE.md]
tokens_est: 6000
created: 2026-06-03
completed:
---

# R3: Add --team-size Flag to ACP Bootstrap

**Source**: audit-022, ChoreHive feedback R3 (P1)
**Status**: ⚠️ Config done (manifest.yaml), bash implementation pending (route-059)

## Problem

`acp-bootstrap.sh` generates ~310 files regardless of project scale. For a solo developer, ~30 files cover all active use cases. This is the root cause behind the "only 10% surface area used" feedback.

## Acceptance Criteria

- [ ] `acp-bootstrap.sh --team-size solo` generates ~30 files (core + essential commands)
- [ ] `acp-bootstrap.sh --team-size small` generates ~80 files (current default for 2–5 devs)
- [ ] `acp-bootstrap.sh --team-size team` generates full ~310 files (5+ devs)
- [ ] Solo preset excludes: skills/, taxonomy.yml, 40 unused commands, 49 unused prompts, package/project/artifact/clarification/version/design subsystems
- [ ] Default (no flag) = small
- [ ] USAGE.md updated with team-size documentation
