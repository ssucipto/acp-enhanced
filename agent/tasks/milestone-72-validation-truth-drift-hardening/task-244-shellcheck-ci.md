---
id: task-244
milestone: M72
title: "ShellCheck CI gate (error-severity, SHA-pinned)"
status: planned
priority: 4
complexity: medium
estimated_hours: 3
created: 2026-07-15
started: null
completed_date: null
route: route-233
audit_findings: [F-091-10]
depends_on: []
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Add the industry-standard lint gate audit-091 found missing: ShellCheck over the repo's ~47+ shell scripts, wired into CI.

## Context (inlined from audit-091 + design D7)

- No shellcheck in any workflow; ci.yaml already follows SHA-pinning best practice (checkout, setup-node, trufflehog all pinned) — the new job must match.
- Ratchet strategy: land at `--severity=error` so the gate goes green immediately; warning-level cleanup is an accepted deferral.
- The 4 sourced libraries get `# shellcheck` directives where needed rather than blanket excludes (rationale documented by task-243).

## Steps

1. Add `shellcheck` job to `.github/workflows/ci.yaml`: SHA-pinned action (e.g., ludeeus/action-shellcheck pinned to full commit SHA) or `apt-get shellcheck` + find/xargs; scope `agent/scripts/*.sh scripts/*.sh e2e/*.sh tests/*.sh`; `--severity=error`
2. Run locally first; fix every error-level finding (behavior-preserving fixes only; anything risky gets a `# shellcheck disable=SCnnnn` + one-line reason)
3. Confirm macOS/Linux compatibility unaffected (`bash -n` all touched scripts; run e2e suite)
4. Note the warning-level ratchet as an explicit deferral in the milestone doc (already listed)

## Verification

- [ ] CI workflow contains shellcheck job with SHA-pinned action
- [ ] Local `shellcheck --severity=error` over the scoped globs → exit 0
- [ ] Every `disable=` directive has an inline reason
- [ ] Full e2e suite still passes
- [ ] Carryover F-091-10 stamped `fixed`

## User-Observable Acceptance

A PR introducing `if [ $foo = bar ]` with an unquoted variable that shellcheck rates error-level fails CI with a readable annotation.
