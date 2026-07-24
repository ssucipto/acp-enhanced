---
id: task-278
milestone: M82
title: "Triage CLI + ACP findings into carryovers"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-24
started: null
completed: 2026-07-24
depends_on: [task-275, task-277]
files_affected:
  - agent/memory/audit-carryovers.md
---

## Objective

Triage combined ACP review + CodeRabbit CLI findings into the live carryover ledger, deduplicated and severity-filtered.

## Steps

1. Collect ACP review findings (task-275) and CLI chunk findings (task-277).
2. Dedupe by file+rule/message similarity; prefer keeping ACP `finding_id` when overlap.
3. For accepted new items, append **live** carryover shape only:
   - `audit_id`, `finding_id`, `severity`, `file`, `finding`, `description`, `fix_target`, `status`, `planned_in`, timestamps/nulls as used today
   - Do **not** invent `source: coderabbit` fields (F-101-03 lesson)
   - Use `audit_id: coderabbit-local-YYYY-MM-DD` or `acp-review-YYYY-MM-DD` as appropriate
4. Skip noise (style-only / already-fixed / out-of-scope docs fluff) with a short reject log in the campaign MANIFEST.
5. Run `npx tsx scripts/acp-validate.ts` (carryover schema must pass).

## Verification

- [ ] Schema-valid carryovers
- [ ] Dedupe noted in MANIFEST
- [ ] Phase 1 ACP issues not marked “deferred to CodeRabbit”

## User-Observable Acceptance

Actionable backlog exists in `audit-carryovers.md` from the local campaign without inventing ledger fields.
