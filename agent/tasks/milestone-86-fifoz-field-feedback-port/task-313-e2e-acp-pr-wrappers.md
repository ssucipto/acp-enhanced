---
id: task-313
milestone: M86
title: "E2E /acp-pr + wrappers on all surfaces"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: null
completed:
phase: 1b
depends_on: [task-312]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-03']
files_affected:
  - e2e/acp.pr.test.sh
  - .cursor/commands/acp-pr.md
  - .claude/commands/acp-pr.md
  - .opencode/commands/acp-pr.md
  - .github/prompts/acp-pr.prompt.md
  - .cursor/commands/acp-ci.md
  - .claude/commands/acp-ci.md
  - .opencode/commands/acp-ci.md
  - .github/prompts/acp-ci.prompt.md
---

<!-- @acp.meta.task
topic: m86, fifoz, e2e, acp, pr, wrappers
description: E2E for PR delegation behaviors and complete wrapper parity for ci+pr.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D2
depends_on: task-312
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

E2E for PR delegation behaviors and complete wrapper parity for ci+pr.

## Context

FIFOZ validator caught missing .github/prompts wrapper. AE must ship all four surfaces for both new commands.

## Steps

1. Adapt inbox e2e/acp.pr.test.sh — assert delegation strings, dry-run, branch safety messaging.
2. **REQUIRED**: create wrappers for acp-ci and acp-pr on all four surfaces, mirroring `.cursor/commands/acp-status.md` style:
   - `.cursor/commands/acp-{ci,pr}.md`
   - `.claude/commands/acp-{ci,pr}.md`
   - `.opencode/commands/acp-{ci,pr}.md` (directory is `commands`, plural)
   - `.github/prompts/acp-{ci,pr}.prompt.md`
3. package.yaml / coverage finalized in 319 — wrappers MUST exist after this task.
4. Run e2e.

## Verification

- [ ] All eight wrapper files exist
- [ ] e2e/acp.pr.test.sh passes
- [ ] Wrappers point at agent/commands sources

## User-Observable Acceptance

Cursor slash picker shows `/acp-ci` and `/acp-pr`; `bash e2e/acp.pr.test.sh` passes.

## Expected Output

### Files Created / Modified
- `e2e/acp.pr.test.sh`
- `.cursor/commands/acp-pr.md`
- `.claude/commands/acp-pr.md`
- `.opencode/commands/acp-pr.md`
- `.github/prompts/acp-pr.prompt.md`
- `.cursor/commands/acp-ci.md`
- `.claude/commands/acp-ci.md`
- `.opencode/commands/acp-ci.md`
- `.github/prompts/acp-ci.prompt.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
