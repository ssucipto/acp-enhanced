---
id: task-285
milestone: M83
title: "shellcheck delegation for SH-03"
status: planned
priority: 4
complexity: low
estimated_hours: 3
created: 2026-07-27
started: null
completed: null
phase: 2
depends_on: [task-281]
audit_findings: [F-102-05]
files_affected:
  - agent/scripts/acp.review-scan.sh
  - agent/commands/acp.review.md
  - package.yaml
---

## Objective

Delegate SH-03 (no unquoted variables) to `shellcheck` when present, behind the 3-gate optional-tool contract.

## Context

**F-102-05 (MEDIUM):** SH-03 is an Appendix A rule with no implementation, while `shellcheck` is installed on the maintainer's machine and reports **221 findings** on `agent/scripts/` alone — the highest coverage-per-hour item in the milestone. It also covers classes beyond SH-03 (SC2155, SC2034).

Per audit-103 shortcut #2 (don't reinvent what a mature tool does), delegation beats hand-rolling.

## Steps

1. Add `shellcheck_available()` (`command -v shellcheck`) following `local.optional-external-tool.md`. No preference gate needed — shellcheck is read-only, offline, and a pure linter; document this reasoning.
2. When available, run `shellcheck -f gcc -S warning` per shell file and map results to SH-03 via `ig_emit_finding`.
3. Apply an allowlist for accepted classes on sourced libraries (SC1090 non-constant source, SC2034 unused-by-design exports) to avoid known-benign noise.
4. When absent: silent no-op, SH-03 stays Phase 2 agent-reviewed. Exit code unchanged.
5. Document the dependency as optional in `acp.review.md`; register nothing new in `package.yaml` beyond scanner changes.
6. Add corpus entries (task-284) for SH-03 positive/negative.

## Verification

- [ ] With shellcheck present: SH-03 findings emitted with correct file:line
- [ ] With shellcheck absent (`PATH` stripped in test): exit 0, no output, no error
- [ ] Allowlisted classes produce no findings on sourced libraries
- [ ] Corpus recall/precision for SH-03 ≥ 90%
- [ ] Existing scanner exit-code semantics unchanged

## User-Observable Acceptance

Repos with shellcheck installed get SH-03 coverage automatically; repos without it see no change at all.
