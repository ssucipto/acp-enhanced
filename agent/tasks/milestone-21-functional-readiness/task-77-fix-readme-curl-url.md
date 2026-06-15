---
id: task-77
title: Fix README.md curl bootstrap URL (main → mainline)
milestone: M21
task_type: docs
complexity: low
executor: Persona A (Copilot)
files_affected:
  - README.md
created: 2026-05-01
completed: 2026-05-01
---

<!-- @acp.meta.task
topic: problem
description: Fix README.md curl bootstrap URL (main → mainline)
milestone: M21
status: draft
updated: 2026-05-01
@acp.meta.end -->


## Problem

README.md line 38 instructs new users to bootstrap ACP Enhanced via:
```bash
curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/main/scripts/acp-bootstrap.sh | bash
```

The repo uses the `mainline` branch, not `main`. GitHub's `main` branch does not exist for this repository. This command will return a 404 error for every new user who follows the README installation instructions.

This is the first thing a new user does — it completely blocks onboarding.

## Fix

Replace `main` with `mainline` in the bootstrap curl URL.

## Acceptance Criteria

- [ ] README.md line 38 curl URL uses `mainline` branch
- [ ] No other stale `main` branch references in README.md (check all raw.githubusercontent.com URLs)
