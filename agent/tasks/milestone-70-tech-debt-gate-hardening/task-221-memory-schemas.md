---
id: task-221
milestone: M70
title: "Memory-layer entity schemas (MED-066-007)"
status: planned
priority: 5
complexity: high
estimated_hours: 8
created: 2026-07-15
started: null
completed_date: null
route: route-210
audit_findings: [MED-066-007]
depends_on: []
---

## Objective

Add JSON Schema / YAML schemas for memory entities and wire `acp-validate.ts`.

## Steps

1. Create `carryovers.schema.yaml`, `lessons.schema.yaml`, `decisions.schema.yaml`
2. Extend `session.schema.yaml` if gaps found
3. Add `validateMemorySchemas()` to `acp-validate.ts`
4. Vitest unit tests with valid/invalid fixtures

## Verification

- [ ] All memory files validate against schemas
- [ ] MED-066-007 carryover fixed
- [ ] vitest 45+ tests pass
