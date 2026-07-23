---
id: task-256
milestone: M78
title: "Feature-detection helpers coderabbit_available / coderabbit_active in acp.common.sh"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-23
started: null
completed: null
route: route-245
audit_findings: [F-097-01]
depends_on: [task-255]
design_reference: [ADR-21](../../memory/decisions.md)
---

## Objective

Add two shared bash helpers to `agent/scripts/acp.common.sh` that answer "is CodeRabbit usable here?" — detection only, no findings parsing — modeled on the `command -v gh` idiom at `acp.branch-protection-setup.sh:27`.

## Context

audit-097 gates 2+3 (feature detection + graceful degradation). Detection must be pure: presence of the config file (and, later, the CLI) — never reading CodeRabbit output (that is GATED, ADR-19/ADR-21). Two helpers keep the "enabled" and "available" concerns separate so callers can degrade correctly.

## Steps

1. Add `coderabbit_available()` to `acp.common.sh`:
   - Resolve `integrations.coderabbit.config_path` (default `.coderabbit.yaml`) via the preferences helper.
   - Return 0 if that file exists at project root **OR** `command -v coderabbit` succeeds; return 1 otherwise.
   - No output, no findings parsing.
2. Add `coderabbit_active()`:
   - Return 0 only if `integrations.coderabbit.enabled` resolves truthy **AND** `coderabbit_available()` returns 0.
   - This is the gate callers check before any CodeRabbit-specific branch.
3. Follow bash_rules (constraints.yml): `local` vars, quote all vars, no `set -e` without trap.
4. Add a header comment on each helper referencing `local.optional-external-tool.md` (task-257) and ADR-21.

## Verification

- [ ] `coderabbit_available` returns 1 in a repo with no `.coderabbit.yaml` and no CLI
- [ ] `coderabbit_available` returns 0 when a `.coderabbit.yaml` is present
- [ ] `coderabbit_active` returns 1 when key disabled even if file present (opt-in wins)
- [ ] `coderabbit_active` returns 0 (usable) only when enabled AND available
- [ ] `shellcheck agent/scripts/acp.common.sh` clean; macOS + Linux safe (no `command -v` portability issue)

## User-Observable Acceptance

Any ACP script can guard a CodeRabbit branch with `if coderabbit_active; then …` and be guaranteed a clean no-op on a machine without CodeRabbit.
