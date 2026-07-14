---
id: task-196
milestone: M67
title: New acp.receive.md — incoming protocol (route-191)
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started:
completed:
route: route-191
---

## Objective

Create `agent/commands/acp.receive.md` — load handoff by path or `--latest`, warn on git SHA drift and session date gap, print assignment checklist.

## Context

Addresses **H2, H4** and shortcut **S3**. No receiving command exists today.

## Steps

1. Create command doc per proposal §6 (7 steps)
2. Define `--latest` resolution order: `active_handoff` → `HANDOFF-LATEST.md` → error
3. Git drift: compare frontmatter/body pin vs `git rev-parse HEAD`; list `git log pin..HEAD`
4. Session gap: handoff date vs last `sessions.md` entry
5. Output banner: `[ACP Receive] handoff loaded | git {match|DRIFT} | mode {executor|cross-repo}`
6. Create all 3 wrappers
7. Stub E2E in task-200; structural checks here

## Verification

- [ ] Command doc has Steps, Verification, Namespace
- [ ] All wrappers exist and reference canonical source
- [ ] Addresses H2, H4

## Depends on

task-195 (frontmatter field names)
