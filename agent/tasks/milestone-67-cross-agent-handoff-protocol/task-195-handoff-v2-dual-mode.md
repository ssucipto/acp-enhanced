---
id: task-195
milestone: M67
title: Handoff v2 — dual mode executor + cross-repo (route-190)
status: completed
priority: 5
complexity: medium
estimated_hours: 5
created: 2026-07-15
started:
completed: 2026-07-15
route: route-190
---

## Objective

Rewrite `agent/commands/acp.handoff.md` to v2.0.0 with `--mode executor|cross-repo` and `--to <executor>`. Executor mode emits proposal §4 template to disk with mandatory git pin.

## Context

Addresses audit-077 **H1, H3, H5, H7** and shortcuts **S1, S2, S5, S6**. Current command forbids implementation steps at L125/L247.

## Steps

1. Bump command version to 2.0.0; add Arguments for `--mode`, `--to`
2. Branch Steps on mode; executor path uses §4 template verbatim
3. Add outgoing ritual preamble (commit → git pin → disk → active_handoff pointer text)
4. Cross-repo path: preserve v1.0.0 behaviour; add clarification vs `/acp-report`
5. Verification section: fail if executor handoff missing git_commit or any §4 header
6. Sync wrappers: `.cursor/commands/`, `.opencode/commands/`, `.github/prompts/`
7. Update `agent/core/routing.yml` handoff chain text (reference receive — full parity in route-196)

## Verification

- [ ] Executor mode lists all 12 mandatory sections
- [ ] Cross-repo mode unchanged from v1 intent
- [ ] Wrappers synced
- [ ] Addresses H1, H3, H5, H7

## User-Observable Acceptance

`/acp-handoff --mode executor --to cursor` produces M51-quality structure on disk.
