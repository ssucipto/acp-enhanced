---
id: task-155
milestone: M29
title: Create upstream v7.2.0 feature parity matrix
status: not_started
priority: 3
complexity: medium
estimated_hours: 4
created: 2026-05-05
started:
completed:
---

## Objective

Create `agent/design/local.upstream-parity-matrix.md` — a complete feature parity matrix covering every upstream `prmichaelsen/agent-context-protocol` v7.2.0 feature, with a HAVE / PARTIAL / PORT / DEFER decision and one-line rationale for each.

## Context

ACP Enhanced forked from upstream at v1.0.3 (2026-02-13). Upstream released v7.2.0 (2026-05-04). A code-level audit on 2026-05-05 (see ADR-7, ADR-8) revealed that ACP Enhanced independently implemented most upstream features through parallel development. The parity matrix makes this permanent and discoverable for future sync cycles.

**Feature decision codes:**
- `HAVE` — ACP Enhanced has a full equivalent implementation
- `PARTIAL` — ACP Enhanced has part of the feature; gaps documented
- `PORT` — Feature is genuinely missing; should be ported (with compat check)
- `DEFER` — Feature exists upstream but does not apply to ACP Enhanced (e.g., driver system if not needed)

**Confirmed HAVE (from 2026-05-05 code audit):**
- `acp.meta-scan.sh` (full POSIX awk implementation)
- `agent/specs/` + `spec.template.md` + FR-IDs + Behavior Tables
- `@acp.spec` command (v1.1.0)
- DR-IDs (`D<N>`) in designs + `incorporates:` in tasks
- `@acp.validate` Probes 1, 2, 3 (self-containment)
- `@acp.proceed --stacked`, `--yolo`, Step 3.5 audit, drift remediation
- Sessions system, clarification workflow, key-file index
- Triple-file command architecture (command doc + .github/prompts/ + .opencode/commands/)

**Confirmed gaps (PORT or need investigation):**
- `agent/drafts/` directory doesn't exist (referenced in acp.plan.md)
- Pluggable driver system (driver.yaml, acp.driver-yaml.sh) — DEFER unless MCP needed
- E2E tests for meta-scan, spec, sync, drafts system
- AGENT.md documentation for markers, specs, DR-IDs, stacked mode, naming convention
- `saas-platform` benchmark scenario

## Implementation

1. Read `prmichaelsen/agent-context-protocol` CHANGELOG from v1.0.3 to v7.2.0 to enumerate all features
2. For each feature, check ACP Enhanced codebase for equivalent implementation
3. Assign HAVE / PARTIAL / PORT / DEFER with one-line rationale
4. Create `agent/design/local.upstream-parity-matrix.md` with:
   - Header table: Feature | Upstream Version | ACP Enhanced Status | Decision | Rationale
   - Grouped by category (Traceability, Workflow, Testing, Benchmarks, Infrastructure)
   - Summary section: counts by decision code
   - "Confirmed Gaps" section: PORT items with estimated effort

## Expected Output

### Files Created
- `agent/design/local.upstream-parity-matrix.md`

## Verification
- [ ] Matrix covers all upstream features mentioned in CHANGELOG v1.0.3→v7.2.0
- [ ] Every row has a HAVE/PARTIAL/PORT/DEFER decision
- [ ] Every PORT decision has an effort estimate
- [ ] Summary section shows total counts
- [ ] `agent/design/local.upstream-parity-matrix.md` passes `grep "HAVE\|PORT\|DEFER\|PARTIAL"` with ≥10 matches

## User-Observable Acceptance
Running `/acp-sync` after this task produces an up-to-date picture of ACP Enhanced vs upstream feature parity. Future upstream integration work references this matrix instead of re-reading the full CHANGELOG.
