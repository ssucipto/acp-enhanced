---
id: task-263
milestone: M79
title: "Harden coderabbit_available for repo-root detection"
status: planned
priority: 4
complexity: low
estimated_hours: 1
created: 2026-07-23
started: null
completed: null
route: route-252
audit_findings: [F-099-05]
depends_on: []
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

## Objective

Make `coderabbit_available` detect a CodeRabbit-configured repo regardless of the current working directory (currently CWD-relative → mis-detects from subdirectories).

## Context

audit-099 F-099-05: `[[ -f "$config_path" ]]` resolves against CWD; a caller in a subdirectory reports a configured repo as unavailable. Detection should anchor to the repo root.

## Steps

1. In `agent/scripts/acp.coderabbit.sh` `coderabbit_available()`: resolve the search base to the git repo root when available:
   - `local root; root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"`
   - Test `[[ -f "$root/$config_path" ]]` (config_path stays repo-relative). If `config_path` is absolute, use it as-is.
   - Keep a CWD fallback when not in a git repo (`root=.`).
2. No `set -e` (sourced library). Quote all vars; `local` everything.
3. Update the E2E `e2e/coderabbit-optionality.test.sh` with a **subdirectory** case: from `$FIX/sub`, `coderabbit_available` still returns 0 when `$FIX/.coderabbit.yaml` exists (make `$FIX` a git repo, or assert the git-root resolution path).

## Verification

- [ ] From a subdirectory of a configured repo, `coderabbit_available` returns 0
- [ ] From an unconfigured repo, still returns 1 (no false positive)
- [ ] Non-git directory: falls back to CWD behavior without error
- [ ] `shellcheck agent/scripts/acp.coderabbit.sh` clean; integrity manifest regenerated
- [ ] `e2e/coderabbit-optionality.test.sh` still green incl. the new subdir case

## User-Observable Acceptance

A developer running an ACP command from any subdirectory of a CodeRabbit-configured repo gets correct detection, not a false "unavailable".
