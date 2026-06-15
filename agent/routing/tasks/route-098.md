---
id: route-098
title: "Document .gitignore design rationale + framework dev mode"
task_type: docs-update
milestone: M49
complexity: low
executor: copilot
context_required:
  - agent/wiki/architecture.md
  - agent/.gitignore
  - agent/commands/acp.init.md
files_affected:
  - agent/wiki/architecture.md
  - agent/commands/acp.init.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 098: .gitignore Documentation + Framework Dev Mode

## Objective

Document the `agent/.gitignore` design rationale in the wiki and add a
`--track-instance-data` concept for framework development.

## Context

`agent/.gitignore` ignores milestones, routing tasks, reports, and memory files.
This is by design (instance data stays local to each project). But for ACP
Enhanced's own development, it means the project's own process isn't visible
in git. Framework developers need a way to track this.

## Changes

### agent/wiki/architecture.md

Add section:
```markdown
## Instance Data vs Framework Data

ACP Enhanced separates files into two categories:

### Framework Data (committed)
- agent/commands/, agent/scripts/, agent/schemas/ — distributable
- agent/core/, agent/wiki/, agent/skills/ — protocol definitions

### Instance Data (local only, per .gitignore)
- agent/milestones/, agent/routing/tasks/ — project work items
- agent/memory/, agent/reports/ — session and audit records
- agent/feedback/, agent/clarifications/ — project communication

### Framework Development Mode
When developing ACP Enhanced itself, run:
/acp-init --track-instance-data

This flag acknowledges that you're working on the framework, not using it
as an end-user project. Instance data files should be force-added to git
for traceability of the framework's own development process.
```

### agent/commands/acp.init.md

Add `--track-instance-data` flag documentation:
```
| `--track-instance-data` | Framework dev mode: instance data is commit-worthy |
```

## Verification

- [ ] Wiki section explains instance vs framework data
- [ ] Framework dev mode documented
- [ ] Clear about when to use which mode
