---
id: task-308
milestone: M86
title: "CI configurables schema + step plugin interface"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-08-14
started: null
completed:
phase: 1
depends_on: [task-307]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-02']
files_affected:
  - agent/configurables/ci.yml
  - agent/schemas/ci.config.schema.yaml
---

<!-- @acp.meta.task
topic: m86, fifoz, ci, schema, plugin, interface
description: Define the portable CI config schema and step-plugin interface without implementing gate bodies.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D1
depends_on: task-307
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Define the portable CI config schema and step-plugin interface without implementing gate bodies.

## Context

ADR-24: orchestrator must not know Expo. Schema must support tiers static/fast/full, step ids, cost_rank, ci_rank, command, output_assert (optional regex/line), skip_if_missing tool, hard_fail_if_missing.

## Steps

1. Read inbox `ci.yml` for shape; **strip FIFOZ-specific budgets/env**.
2. Design AE `agent/configurables/ci.yml` with:
   - `tiers.static|fast|full: [step_id, ...]`
   - `steps.<id>: { description, command, ci_job, cost_rank, ci_rank, tools[], output_contains[]?, allow_skip? }`
   - drift assertion hooks where a numeric budget must match CI prose (pattern: config-with-assert, not parse-CI-prose)
3. Add schema file under `agent/schemas/` validating the structure.
4. **BINDING (audit-115 F3-02 / P-CI-1)**: `agent/configurables/ci.yml` is a **runtime CI step matrix**, NOT a preference registered in `acp.configurables.yaml`. Do **not** add preference keys for M86. Document this ownership in `ci.yml` header comments.
5. Schema comments may mention a *future* optional preference mirror (`integrations.ci.tiers.*`) as out-of-scope for M86.
6. Do not implement `acp.ci.sh` beyond a stub comment pointing here.
7. Every step id in tier lists MUST be defined under `steps:` — no dangling references.

## Verification

- [ ] ci.yml has no Expo/Firebase/payslip/m50 keys
- [ ] Every AE PR-blocking job from task-305 maps to ≥1 step id OR out-of-scope note in comments
- [ ] Schema validates sample ci.yml
- [ ] Tier lists reference only defined step ids
- [ ] Header comment states ci.yml is runtime config, not acp.configurables preference registry
- [ ] `acp.configurables.yaml` was **not** modified

## User-Observable Acceptance

`cat agent/configurables/ci.yml` shows AE-oriented step ids a reader can match to GitHub Actions job names.

## Expected Output

### Files Created / Modified
- `agent/configurables/ci.yml`
- `agent/schemas/ci.config.schema.yaml`
- `agent/configurables/acp.configurables.yaml`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
