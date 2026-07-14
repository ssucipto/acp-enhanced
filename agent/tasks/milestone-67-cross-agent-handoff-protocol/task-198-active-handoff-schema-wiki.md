---
id: task-198
milestone: M67
title: active_handoff schema + wiki + validate (route-193)
status: planned
priority: 4
complexity: medium
estimated_hours: 4
created: 2026-07-15
started:
completed:
route: route-193
---

## Objective

Add `active_handoff` to `progress.schema.yaml`, validate in `acp-validate.ts`, finalize wiki, link from `architecture.md`.

## Context

Addresses **H9, H8, U3**. Remediates shortcut **SC-02** (wiki draft → shipped).

## Steps

1. Schema block per proposal §8 (path, date, executors, git_commit, status)
2. validate: if `active_handoff.path` set → file must exist
3. Handoff v2 step: update progress.yaml on executor save (document in acp.handoff.md)
4. Finalize `agent/wiki/cross-agent-handoff.md` — remove DRAFT banner
5. Add architecture.md cross-link section
6. Mermaid ritual diagram from proposal §11

## Verification

- [ ] Schema validates sample progress.yaml with active_handoff
- [ ] Wiki linked from architecture
- [ ] Addresses H8, H9, U3

## Depends on

task-195, task-196
