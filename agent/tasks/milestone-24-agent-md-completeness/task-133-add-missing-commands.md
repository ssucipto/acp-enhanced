# Task 133: Add Missing Commands to AGENT.md Core Commands

<!-- @acp.meta.task
topic: add, missing, commands, to, agentmd, core, commands
description: Task 133: Add Missing Commands to AGENT.md Core Commands
milestone: M24
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M24 — AGENT.md Completeness  
**Estimated Time**: 1–2 hours  

---

## Objective

Add the 6 commands present in `agent/commands/` but missing from the AGENT.md Core Commands section. Ensure every shipped command has a visible entry in the categorized Core Commands list.

## Missing Commands (confirmed by file diff — 51 files, 45 documented)

| Command | Category | File |
|---------|----------|------|
| `@acp.resume` | Workflow | `agent/commands/acp.resume.md` |
| `@acp.update` | Version & Sync | `agent/commands/acp.update.md` |
| `@acp.preferences-get` | Preferences | `agent/commands/acp.preferences-get.md` |
| `@acp.projects-restore` | Project Registry | `agent/commands/acp.projects-restore.md` |
| `@git.commit` | Git (separate namespace) | `agent/commands/git.commit.md` |
| `@git.init` | Git (separate namespace) | `agent/commands/git.init.md` |

## Steps

1. **Read AGENT.md Core Commands section** to confirm exact current content and surrounding context
2. **Add `@acp.resume`** to the Workflow category (after `@acp.handoff`, before `@acp.audit`)
   - Description: "Resume a project — init + review recent progress + proceed in one step"
3. **Add `@acp.update`** to the Version & Sync category (after `@acp.version-update`)
   - Description: "Update ACP Enhanced to latest version via script"
4. **Add `@acp.preferences-get`** to the Preferences category (after `@acp.preferences-show`)
   - Description: "Read effective preference value for a given key (for scripting/command use)"
5. **Add `@acp.projects-restore`** to the Project Registry category (after `@acp.projects-sync`)
   - Description: "Restore project registry from backup after corruption or accidental deletion"
6. **Add Git Commands sub-section** at the end of Core Commands (or as a note)
   - `@git.commit` — Version-aware commit with CHANGELOG validation
   - `@git.init` — Initialize git repository with ACP conventions
   - Note: These use the `git` namespace, not `acp`
7. **Read `acp.preferences-get.md` and `acp.projects-restore.md`** to verify descriptions are accurate
8. **Verify count** — the list should reflect all 51 command files minus `command.template.md` = 50 commands

## Verification

- [ ] AGENT.md Core Commands section lists `@acp.resume` under Workflow
- [ ] AGENT.md Core Commands section lists `@acp.update` under Version & Sync
- [ ] AGENT.md Core Commands section lists `@acp.preferences-get` under Preferences
- [ ] AGENT.md Core Commands section lists `@acp.projects-restore` under Project Registry
- [ ] AGENT.md Core Commands section has Git category with `@git.commit` and `@git.init`
- [ ] Descriptions match the actual command file purpose
- [ ] No command file in `agent/commands/` (excluding template) is unaccounted for

---

**Next Task**: [task-134](task-134-three-persona-deployment-model.md)
