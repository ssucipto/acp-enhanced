---
id: task-272
milestone: M81
title: "Wire /acp-review + weekly-code-review for coderabbit_active"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-24
started: null
completed: null
route: route-261
depends_on: [task-269, task-270, task-271]
design_reference: [agent/commands/acp.review.md](../../commands/acp.review.md), [ADR-21](../../memory/decisions.md)
audit_findings: [F-101-02, F-101-06, F-101-07]
gate: "tasks 269-271 complete; fixture import working"
files_affected:
  - agent/commands/acp.review.md
  - agent/scripts/acp.coderabbit-weekly.sh
  - agent/progress.yaml
  - package.yaml
  - agent/wiki/coderabbit-integration.md
---

## Objective

Augment `/acp-review` (and optionally the weekly recurring entry) with CodeRabbit-aware behavior when `coderabbit_active` — **identical** behavior when inactive.

## Context

**F-101-02:** `weekly-code-review` in `progress.yaml` is a **single `command:` string** (`/acp-review --report --carryover`), not a step list. Do not invent steps.

**F-101-06:** Reference `bash agent/scripts/acp.findings-import.sh` — never `/acp-findings-import`.

**F-101-07:** Phase 1 rules never deferred.

## Steps

1. Update `agent/commands/acp.review.md`:
   - Subsection “CodeRabbit augmentation (when `coderabbit_active`)”
   - **Phase 1:** always run all 8 deterministic rules — never skip for CodeRabbit (F-101-07)
   - **Phase 2:** for policy-map `owner: coderabbit|both`, annotate “also covered by CodeRabbit — verify via PR review or `bash agent/scripts/acp.findings-import.sh --input …`”
   - ACP-owned Phase 2 rules always run; review remains valid standalone when inactive
2. Weekly recurring (**pick one**, document choice in task notes):
   - **Preferred:** Keep `command: /acp-review --report --carryover` unchanged; put all CR behavior inside the review command doc (agent follows it when active). Inactive path = zero code change.
   - **Alternative:** Change `command:` to a thin wrapper `bash agent/scripts/acp.coderabbit-weekly.sh` that: runs the same review invocation; if `coderabbit_active`, optionally reminds to run findings-import on latest fixture/export. Wrapper must no-op CR branch when inactive so behavior matches pre-M81.
3. Do **not** modify `acp.review-scan.sh` to call CodeRabbit APIs.
4. Do **not** add slash command wrappers for findings-import (F-101-06).

## Verification

- [ ] Review doc has no CodeRabbit requirement when inactive
- [ ] Phase 1 never listed as deferrable
- [ ] All docs say `bash agent/scripts/acp.findings-import.sh` (no `/acp-findings-import`)
- [ ] Inactive path on acp-enhanced (`enabled=false`) matches pre-M81
- [ ] If wrapper used: registered in package.yaml; inactive = same exit/output as direct review

## User-Observable Acceptance

CodeRabbit repos get review annotations + import pointer; everyone else sees no change.
