---
id: task-257
milestone: M78
title: "Codify the optional-external-tool pattern (3-gate contract)"
status: planned
priority: 4
complexity: low
estimated_hours: 1.5
created: 2026-07-23
started: null
completed: null
route: route-246
audit_findings: [F-097-01]
depends_on: [task-255, task-256]
design_reference: [ADR-21](../../memory/decisions.md)
---

## Objective

Write `agent/patterns/local.optional-external-tool.md` capturing the reusable three-gate contract (preference opt-in → feature detection → silent graceful degradation) so CodeRabbit, Aikido, and future optional tools all integrate the same way.

## Context

audit-097 defined the contract but it lives only in a report. Promoting it to a pattern makes it enforceable and discoverable at `/acp-plan` Step 1.5. Generalizes task-255 (toggle) + task-256 (detection).

## Steps

1. Create the pattern file following `agent/patterns/pattern.template.md`.
2. Document the three gates as a table with the ACP mechanism for each:
   - Gate 1 opt-in → `integrations.<tool>.enabled` preference, default false
   - Gate 2 detection → `<tool>_available()` helper, `command -v` / config-file style
   - Gate 3 degradation → silent no-op when absent/disabled; optional one-line hint when enabled-but-absent
3. State the binding rule: **the tool augments, never gates** an ACP code path; absence is normal, not an error (contrast `gh` in branch-protection, which is required).
4. Give the `coderabbit_available` / `coderabbit_active` pair (in `agent/scripts/acp.coderabbit.sh` — a dedicated script sourcing preferences.sh, per audit-098 F-098-01) as the reference implementation. Note the layering rule: an optional-tool script sources `acp.preferences.sh`, never the reverse (common.sh must stay dependency-free of preferences).
5. Cross-reference audit-097, audit-098, ADR-21, and `acp.branch-protection-setup.sh:27`.

## Verification

- [ ] Pattern file conforms to `pattern.template.md` structure
- [ ] Three gates documented with concrete ACP mechanisms
- [ ] "augments never gates" + "absence is normal" rules stated explicitly
- [ ] task-256 helpers link back to this pattern
- [ ] `/acp-validate` recognizes the new pattern file (no structure errors)

## User-Observable Acceptance

A future integration (e.g. Aikido) can be planned by pointing at this one pattern instead of re-deriving the optionality design.
