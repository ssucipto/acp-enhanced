---
id: task-201
milestone: M67
title: Ecosystem parity — package, domain, index, README (route-196)
status: planned
priority: 4
complexity: medium
estimated_hours: 3
created: 2026-07-15
started:
completed:
route: route-196
---

## Objective

Ship `/acp-receive` as a first-class framework command — not an orphan doc. Full ecosystem registration.

## Context

Addresses **U2**, shortcut **SC-01/SC-07**, carryover **HIGH-067-001** (for acp.receive). Remediates premature routing.yml by verifying all entries reference **shipped** commands.

## Steps

1. Add `acp.receive` to `package.yaml` commands list
2. Add `acp-receive` / handoff v2 to `agent/wiki/domain.yml` (command count +1 → 70)
3. Add index entries in `agent/index/acp.core.yaml` for handoff/receive/resume (`applies:`)
4. README: mention cross-agent handoff in workflow section
5. CONTRIBUTING: document `agent/proposals/` + `agent/feedback/` intake path
6. Run `acp.sync-cursor-commands.sh`; verify 70×3 parity
7. Audit routing.yml: remove or gate any reference to unshipped commands until task-196 completes

## Verification

- [ ] package.yaml includes acp.receive
- [ ] domain.yml command count accurate
- [ ] Parity check passes
- [ ] routing.yml only references existing commands post-ship

## Depends on

task-196
