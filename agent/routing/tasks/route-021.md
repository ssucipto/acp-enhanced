---
id: route-021
title: M40 — Add verification quality gate to task template + create milestone-40
task_type: command-doc-update
milestone: M40
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/tasks/task-1-{title}.template.md
  - agent/feedback/feedback-003-pre-implementation-audit-protocol.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
files_affected:
  - agent/tasks/task-1-{title}.template.md
  - agent/milestones/milestone-40-pre-impl-audit-protocol.md
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - package.yaml
  - AGENT.md
  - agent/wiki/architecture.md
  - agent/wiki/domain.yml
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Add a verification quality gate HTML comment block to the task template immediately before
`## Verification`. Also create milestone-40 file, update progress.yaml, bump version to 6.6.0,
and add CHANGELOG entry.

## Acceptance Criteria

- [ ] HTML comment block added to `agent/tasks/task-1-{title}.template.md` before `## Verification`
- [ ] Comment explicitly lists 5 cross-reference checks (field names, enum values, import paths, HTTP methods, response shapes)
- [ ] Comment does NOT add any new required sections — it's a prompt, not structure
- [ ] `agent/milestones/milestone-40-pre-impl-audit-protocol.md` created with standard format
- [ ] Milestone references route-018, route-019, route-020, route-021 as its tasks
- [ ] `agent/progress.yaml` updated: M40 added with status: complete
- [ ] `CHANGELOG.md` entry added for version 6.6.0
- [ ] `agent/core/identity.yml` version: `6.5.0` → `6.6.0`
- [ ] `package.yaml` version: `6.5.0` → `6.6.0`
- [ ] `AGENT.md` version reference updated

## Implementation Notes

Add immediately before the `## Verification` heading in task template:

```markdown
<!-- QUALITY GATE (required for backend and frontend tasks):
     Before writing verification checklist items, cross-reference against the actual codebase:
     1. Field names  — read the Pydantic model / DB schema; confirm every field name used here exists
     2. Enum values  — read the enum definition; confirm values are valid members (not free strings)
     3. Import paths — read the file tree; confirm all import sources exist (frontend tasks)
     4. HTTP methods — read the route decorator; confirm method + path match exactly
     5. Response shape — read the API endpoint; confirm response field names match what you verify
     Checklist items with wrong names or methods create implementation bugs that silently
     pass during review but fail at runtime.                                                 -->
```

Version bump rationale: M40 completes the pre-implementation audit enhancement — a significant
protocol addition. `6.5.0 → 6.6.0` (minor version bump for new protocol feature set).

CHANGELOG entry:
```markdown
## [6.6.0] — 2026-05-11

### Added
- **Pre-Implementation Audit Protocol** (M40): `/acp-audit --pre-impl` 4-phase protocol
  (plan correctness → code cross-reference → prior carryover validation → operational completeness)
- `agent/memory/audit-carryovers.md` — new memory layer for tracking pending audit fixes
- Step 4.4 in context-loading protocol — surfaces open audit carryovers at session start
- Verification quality gate comment block in task file template
```

- [ ] `agent/wiki/architecture.md` — add pre-impl audit mode section documenting the 4-phase protocol
- [ ] `agent/wiki/domain.yml` — add `audit_carryovers` to memory layer entries; document `--pre-impl` flag

## Dependency

Should run after route-018, route-019, route-020 are complete (M40 wrap-up task).
