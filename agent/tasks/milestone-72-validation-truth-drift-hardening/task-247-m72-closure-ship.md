---
id: task-247
milestone: M72
title: "M72 closure audit (audit-093) + ship v6.27.0"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-15
started: 2026-07-15T03:00:00Z
completed: 2026-07-15
completed_date: 2026-07-15T03:30:00Z
route: route-236
audit_findings: [F-091-01, F-091-02, F-091-03, F-091-04, F-091-05, F-091-06, F-091-07, F-091-08, F-091-09, F-091-10, F-091-13, F-091-14, F-092-01, F-092-02, F-092-03, F-092-04]
depends_on: [task-240, task-241, task-242, task-243, task-244, task-245, task-246]
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Honest closure gate: independently re-verify every F-091 carryover, run all quality gates, ship v6.27.0. Mirrors the M71/audit-090 closure protocol (guardrail #3 — no self-certification by the implementing tasks).

## Context

audit-089/090 established the pattern: a closure audit re-verifies each finding against the repo state (not against task claims), amends verdicts, and only then stamps carryovers. audit-088's premature PASS is the cautionary precedent.

## Steps

1. **audit-093**: for each F-091-01..14 + F-092-01..04 + CRIT-065-002, re-verify from live repo state (re-run the exact probe from audit-091/092 that found it — e.g., seeded-drift negative tests for task-241, `md5` triple-hash, dot-stray grep, gh api protection call, `git check-ignore` probes per D9)
2. Quality gates: `npx tsx scripts/acp-validate.ts` (root) 0 errors; wrong-cwd run fails loudly; vitest ≥ 34; full e2e suite; post-milestone sweep (`agent/scripts/acp.post-milestone-sweep.sh`)
2b. **Manifest gate (F-092-01 / D10)**: regenerate `agent/integrity-manifest.yaml` (`acp.manifest-hash.sh` with `--output`) covering all M72-changed files incl. new `.claude/commands/` wrappers; `/acp-integrity --diff` must be clean — closure is REFUSED while diffs remain
3. Stamp all verified carryovers `fixed` with `verified_in_audit: audit-093`; anything unverified stays `pending` with reason
4. Release v6.27.0: version bump chain (identity.yml, AGENTS.md header → hook syncs CLAUDE.md + copilot-instructions, package.yaml — now validator-enforced), CHANGELOG entry, task frontmatter `status: completed` for 240-247, `git tag v6.27.0`
5. Update progress.yaml: M72 completed, next_steps refreshed; write closure session entry
6. Report audit-093 verdict in `agent/reports/audit-093-m72-closure.md`

## Verification

- [ ] audit-093 PASS (or PASS WITH DEFERRALS listing only admin/external-blocked items)
- [ ] All quality gates green (validator, vitest, e2e, sweep, manifest `/acp-integrity --diff` clean)
- [ ] All F-091 + F-092 carryovers `fixed` w/ audit-093 pointer (or documented pending)
- [ ] `git tag v6.27.0`; CHANGELOG `## [6.27.0]`; version consistent across all enforced files
- [ ] M72 milestone doc Status: completed matches progress.yaml

## User-Observable Acceptance

`/acp-status` shows M72 complete at v6.27.0 with zero pending carryovers except explicitly ops-blocked items.
