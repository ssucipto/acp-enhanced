---
id: task-271
milestone: M81
title: ".coderabbit.yaml starter template + documentation"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-24
started: 2026-08-14
completed: 2026-08-14
route: route-260
depends_on: [task-269]
design_reference: [agent/wiki/coderabbit-integration.md](../../wiki/coderabbit-integration.md)
audit_findings: [F-101-08]
gate: "ADR-22 accepted (task-269)"
files_affected:
  - agent/templates/coderabbit.yaml.template
  - agent/wiki/coderabbit-integration.md
  - agent/scripts/acp.coderabbit.sh
---

## Objective

Ship a **starter** `.coderabbit.yaml` template and bootstrap docs. Not the patterns/lessons generator.

## Steps

1. Add `agent/templates/coderabbit.yaml.template` (valid YAML; commented ACP path hints; no Aikido).
2. Wiki “Bootstrap CodeRabbit”: copy template → `.coderabbit.yaml`, install GitHub app, `integrations.coderabbit.enabled true`.
3. Explicit: manual copy today; auto-generate deferred (no `generate_on_commit` key).
4. Optional: `coderabbit_hint_if_missing` mentions template path.

## Verification

- [ ] Template parseable YAML
- [ ] Wiki bootstrap complete; roadmap already points to M81 (from task-269)
- [ ] No `generate_on_commit` preference
- [ ] No Aikido references

## User-Observable Acceptance

CodeRabbit consumer can copy template, enable preference, and pass `coderabbit_active`.
