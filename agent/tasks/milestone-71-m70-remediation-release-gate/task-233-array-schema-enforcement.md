---
id: task-233
milestone: M71
title: "Memory array schema enforcement (lessons/decisions/carryovers)"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-222
audit_findings: [F-089-05]
depends_on: [task-231]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Extend `runSchemaEnforcement()` to validate YAML **list** documents (lessons.md, decisions.md, audit-carryovers.md) per entry schema fields.

## Steps

1. Add `validateSchemaListEntries()` — split on entry marker, check required_fields per schema
2. Wire lessons.schema.yaml, decisions.schema.yaml, audit-carryovers.schema.yaml in enforcement loop
3. Log `✅ Schema lessons.schema.yaml: N entries valid` on success
4. Add vitest fixture with invalid lessons entry (missing date)

## Verification

- [ ] validate logs all 5 memory schemas (session, patterns, lessons, decisions, carryovers)
- [ ] MED-066-007 carryover fixed with audit-090 pointer

## User-Observable Acceptance

`npx ts-node scripts/acp-validate.ts` reports lessons/decisions/carryovers schema validation.
