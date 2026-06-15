---
id: task-78
title: Bump version to 6.2.2 in metadata files
milestone: M21
task_type: docs
complexity: low
executor: Persona A (Copilot)
files_affected:
  - package.yaml
  - AGENT.md
  - agent/core/identity.yml
created: 2026-05-01
completed: 2026-05-01
---

<!-- @acp.meta.task
topic: problem
description: Bump version to 6.2.2 in metadata files
milestone: M21
status: draft
updated: 2026-05-01
@acp.meta.end -->


## Problem

M20 introduced a version bump from 6.2.1 → 6.2.2 (in progress.yaml and git.commit message), but three metadata files were not updated:

| File | Current | Expected |
|------|---------|----------|
| `package.yaml` line 5 | `version: 6.2.1` | `version: 6.2.2` |
| `AGENT.md` line 4 | `**Version**: 6.2.1` | `**Version**: 6.2.2` |
| `agent/core/identity.yml` line 31 | `version: 6.2.1` | `version: 6.2.2` |

## Acceptance Criteria

- [ ] All three files show `6.2.2`
- [ ] No other metadata files left on 6.2.1 (search for stale references)
