---
id: task-197
milestone: M67
title: Resume handoff path integration (route-192)
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-192
---

## Objective

Extend `agent/commands/acp.resume.md` with optional handoff path — run receive protocol steps 1–6 before standard init+proceed.

## Context

Addresses **U1**. Proposal §6 related command update.

## Steps

1. Add Arguments: optional `@path` or path to handoff file
2. Step 0: if handoff arg → delegate to receive checklist (inline or cross-link acp.receive.md)
3. No arg → unchanged behaviour
4. Sync resume wrappers
5. E2E assertion in task-200

## Verification

- [ ] Documented `@agent/reports/handoff-*.md` pattern
- [ ] Without arg, resume unchanged
- [ ] Addresses U1

## Depends on

task-196
