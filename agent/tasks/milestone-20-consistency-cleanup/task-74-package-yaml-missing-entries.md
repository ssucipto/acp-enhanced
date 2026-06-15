# Task 74: Add Missing Commands and Scripts to package.yaml

<!-- @acp.meta.task
topic: add, missing, commands, and, scripts, to, packageyaml
description: Task 74: Add Missing Commands and Scripts to package.yaml
milestone: M20
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: [M20 - Consistency Cleanup](../milestones/milestone-20-consistency-cleanup.md)  
**Estimated Time**: 20 minutes  

---

## Objective

`package.yaml` lists what consumers get when they install `acp-enhanced`. It is missing
entries for commands and scripts added in M6 (Preferences System), M7 (Project Registry
extended commands), and M15/M16 (clarification/design commands).

---

## Missing Commands

| Command File | Category | Scripts Used |
|---|---|---|
| `acp.preferences-create.md` | Preferences | `acp.preferences.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.preferences-get.md` | Preferences | `acp.preferences.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.preferences-set.md` | Preferences | `acp.preferences.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.preferences-show.md` | Preferences | `acp.preferences.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.preferences-validate.md` | Preferences | `acp.preferences.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.clarification-capture.md` | Workflow | none |
| `acp.clarification-create.md` | Workflow | none |
| `acp.design-reference.md` | Workflow | none |
| `acp.project-info.md` | Project Registry | `acp.project-info.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.project-remove.md` | Project Registry | `acp.project-remove.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.project-update.md` | Project Registry | `acp.project-update.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.projects-restore.md` | Project Registry | `acp.projects-restore.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |
| `acp.projects-sync.md` | Project Registry | `acp.projects-sync.sh`, `acp.common.sh`, `acp.yaml-parser.sh` |

## Missing Scripts

| Script File | Category |
|---|---|
| `acp.preferences.sh` | Preferences system — used by all 5 preference commands |

---

## Steps

1. Open `package.yaml`, locate `contents.commands` section
2. Add all 13 missing command entries in the appropriate category groupings
3. Locate `contents.scripts` section, add `acp.preferences.sh`
4. Verify no duplicate entries
