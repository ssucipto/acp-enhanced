---
id: task-79
title: Add 7 missing scripts to package.yaml scripts section
milestone: M21
task_type: package-maintenance
complexity: low
executor: Persona A (Copilot)
files_affected:
  - package.yaml
created: 2026-05-01
completed: 2026-05-01
---

<!-- @acp.meta.task
topic: problem
description: Add 7 missing scripts to package.yaml scripts section
milestone: M21
status: draft
updated: 2026-05-01
@acp.meta.end -->


## Problem

Seven scripts exist in `agent/scripts/` but are absent from the `scripts:` section of `package.yaml`.
The commands section correctly references these scripts as dependencies, but they are not listed as
installable/distributable scripts in the scripts section.

Missing from `scripts:` section:

| Script | Used By | Notes |
|--------|---------|-------|
| `acp.project-info.sh` | `acp.project-info.md` | Added in M7 project registry extended |
| `acp.project-remove.sh` | `acp.project-remove.md` | Added in M7 |
| `acp.project-update.sh` | `acp.project-update.md` | Added in M7 |
| `acp.projects-restore.sh` | `acp.projects-restore.md` | Added in M7 |
| `acp.projects-sync.sh` | `acp.projects-sync.md` | Added in M7 |
| `acp.meta-scan.sh` | Internal meta scanning | Utility script |
| `acp.package-install-optimized.sh` | Alternative installer | Optimized version of package-install |

## Fix

Add these entries under the `# Project Registry Scripts (Experimental)` section
and a new `# Utility Scripts (Internal)` section in package.yaml.

## Acceptance Criteria

- [ ] All 7 scripts listed in package.yaml scripts section
- [ ] All scripts in `agent/scripts/` are accounted for in package.yaml
