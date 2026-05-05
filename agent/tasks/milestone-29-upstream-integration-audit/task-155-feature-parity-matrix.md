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

**Source Priority Order** — read ALL sources before assigning HAVE/PARTIAL/PORT/DEFER:

1. **Upstream `AGENT.md`** (canonical feature documentation, 2100+ lines):
   `https://raw.githubusercontent.com/prmichaelsen/agent-context-protocol/mainline/AGENT.md`
   Read in full — this is the definitive description of every feature, command, and subsystem.

2. **Upstream `agent/commands/*.md`** (actual command implementations):
   Directory listing: `https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/commands`
   Read every `.md` file to understand each command's steps, arguments, flags, and integration points.
   Do NOT rely on CHANGELOG descriptions alone — command files are the source of truth for behaviour.

3. **Upstream `agent/scripts/*.sh`** (actual shell implementations):
   Directory listing: `https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/scripts`
   Read every `.sh` file to understand what helpers, subcommands, and logic are present.

4. **Upstream `agent/milestones/*.md`** (planned and completed feature phases):
   Directory listing: `https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/milestones`
   Read all milestone files to understand feature scope, deliverables, and rationale per phase.

5. **Upstream `agent/tasks/`** (granular feature breakdowns):
   Directory listing: `https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/tasks`
   Sample representative tasks — read at minimum 2–3 tasks per active milestone to understand
   implementation detail that does not appear in the milestone file or CHANGELOG.

6. **Upstream `agent/design/*.md`** (architectural decisions and design rationale):
   Directory listing: `https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/design`
   Read designs for: pluggable driver system, key-file index, benchmark suite, metadata markers,
   spec system, and any feature marked PORT or needing deeper understanding.

7. **Upstream `CHANGELOG.md`** (version timeline and cross-reference only):
   `https://raw.githubusercontent.com/prmichaelsen/agent-context-protocol/mainline/CHANGELOG.md`
   Use this to pin version numbers, find when a feature first appeared, and cross-check that
   nothing in the CHANGELOG is missing from the sources above. Not a substitute for reading code.

**Analysis steps (after reading all sources above):**

8. For each feature discovered across all sources, search the ACP Enhanced codebase for equivalent
   implementation: read actual ACP Enhanced command files, script files, and templates — do not
   infer HAVE from directory names or task titles alone.

9. Assign HAVE / PARTIAL / PORT / DEFER with a one-line rationale grounded in actual code observed
   (quote the file and key evidence where helpful).

10. Create `agent/design/local.upstream-parity-matrix.md` with:
    - Header table: Feature | Upstream Source File | Upstream Version Introduced | ACP Enhanced Status | Decision | Rationale
    - Grouped by category (Commands, Scripts, Traceability, Workflow, Testing, Benchmarks, Schemas, Infrastructure)
    - Summary section: counts by decision code
    - "Confirmed Gaps" section: PORT items with estimated effort

## Expected Output

### Files Created
- `agent/design/local.upstream-parity-matrix.md`

## Verification
- [ ] Upstream `AGENT.md` was read in full (2100+ lines) before any assignments
- [ ] All upstream `agent/commands/*.md` files were listed and each read individually (not inferred from CHANGELOG titles)
- [ ] All upstream `agent/scripts/*.sh` files were listed and each read individually
- [ ] All upstream `agent/milestones/*.md` files were read
- [ ] At least 2–3 upstream task files per active milestone were sampled and read
- [ ] Upstream `agent/design/` was listed and key design docs were read
- [ ] CHANGELOG was used for version cross-reference only (not as sole source)
- [ ] Matrix covers features from ALL sources above (AGENT.md + commands + scripts + milestones + tasks + designs)
- [ ] Every row has a HAVE/PARTIAL/PORT/DEFER decision backed by actual code evidence
- [ ] Every PORT decision has an effort estimate
- [ ] Summary section shows total counts
- [ ] `agent/design/local.upstream-parity-matrix.md` passes `grep "HAVE\|PORT\|DEFER\|PARTIAL"` with ≥10 matches

## User-Observable Acceptance
Running `/acp-sync` after this task produces an up-to-date picture of ACP Enhanced vs upstream feature parity. Future upstream integration work references this matrix instead of re-reading the full CHANGELOG.
