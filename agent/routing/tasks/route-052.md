---
id: route-052
title: R7 — Document manifest.yaml vs progress.yaml Split
task_type: docs-update
milestone: M44
complexity: low
executor: deepseek-v4-flash
context_required: [AGENT.md, agent/manifest.yaml, agent/progress.yaml]
files_affected: [AGENT.md]
tokens_est: 1000
created: 2026-06-03
completed: 2026-06-03
---

# R7: Document Manifest vs Progress Split

**Source**: audit-022, ChoreHive feedback R7 (P3)

## Problem

The split is already correct in implementation but undocumented. Users may wonder which file to update.

## Solution

Add a table to AGENT.md:

| File | Purpose | Update Frequency |
|------|---------|-----------------|
| `agent/manifest.yaml` | Static project identity, stack, constraints | Rarely |
| `agent/progress.yaml` | Live tracking: milestones, tasks, recent work | Daily |

## Acceptance Criteria

- [ ] Table added to AGENT.md under a "Project Files" section
- [ ] Clarifies that manifest is "set once", progress is "update daily"
