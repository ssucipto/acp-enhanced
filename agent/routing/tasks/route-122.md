---
id: route-122
title: "Resolve 4 audit-044 carryovers: index, domain.yml, README, P3 deferred"
task_type: memory-write
milestone: M52
complexity: low
executor: copilot
context_required:
  - agent/memory/audit-carryovers.md
  - agent/index/acp.core.yaml
  - agent/wiki/domain.yml
  - README.md
  - agent/milestones/milestone-50-design-spec-command.md
files_affected:
  - agent/index/acp.core.yaml
  - agent/wiki/domain.yml
  - README.md
  - agent/memory/audit-carryovers.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-07
override_reason:
---

# Route 122: Resolve Audit-044 Carryovers

## Objective

Close all 4 pending audit-044 carryovers that have been deferred since M50.

## Context

These 4 items were filed as non-blocking post-implementation enhancements in audit-044:
- G-044-03: No `agent/index/` entry for design-spec (reduces contextual discoverability)
- G-044-06: No `domain.yml` entry for design-spec command taxonomy
- G-044-07: No README mention of `/acp-design-spec`
- DEFER-044-01: P3 deferred items (Visualizer preset, exemplar) without follow-up tracking

## Changes

### 1. G-044-03: Add `agent/index/acp.core.yaml` entry for design-spec

```yaml
    - path: agent/commands/acp.design-spec.md
      weight: 0.7
      kind: command
      description: |
        Generate Application Interface & Data-Flow Design Specifications.
        19-section template based on arc42, C4 Model, IEEE 1016, ISO 42010.
      rationale: |
        Required context when generating interface specs, documenting
        data flows, or preparing QA verification matrices.
      applies: acp.design-spec, acp.proceed, acp.plan
```

### 2. G-044-06: Add `domain.yml` entry for design-spec

Add command taxonomy entry in `agent/wiki/domain.yml` under the commands section.

### 3. G-044-07: Add README mention of design-spec

The five-tier reporting model (route-121) will naturally include design-spec. Ensure the command is also listed in any command listing section.

### 4. DEFER-044-01: Create deferred tracking

Add a `deferred:` entry in the M52 session commit noting the P3 items:
- Visualizer design-spec document type preset
- Abbreviated exemplar in `agent/examples/`

### 5. Update `audit-carryovers.md`

Set status to `fixed` for all 4 entries with `fix_applied_date: 2026-06-06` and `verified_in_audit: "052"`.

## Verification

- [ ] G-044-03: `agent/index/acp.core.yaml` has design-spec entry
- [ ] G-044-06: `agent/wiki/domain.yml` has design-spec taxonomy entry
- [ ] G-044-07: README mentions `/acp-design-spec` (via five-tier model)
- [ ] DEFER-044-01: Deferred items tracked in M52 session commit
- [ ] All 4 carryovers marked `status: fixed` in audit-carryovers.md
