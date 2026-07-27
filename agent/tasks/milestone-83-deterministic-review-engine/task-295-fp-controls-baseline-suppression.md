---
id: task-295
milestone: M83
title: "False-positive controls — baseline mode, inline suppression, per-rule thresholds"
status: planned
priority: 4
complexity: medium
estimated_hours: 4
created: 2026-07-27
started: null
completed: null
phase: 5
depends_on: [task-284]
audit_findings: [F-103-09]
files_affected:
  - agent/scripts/acp.integrity-output.sh
  - agent/scripts/acp.review-scan.sh
  - agent/commands/acp.review.md
---

## Objective

Give the shared finding emitter the three false-positive controls every mature scanner ships: baseline suppression, inline suppression comments, and per-rule thresholds.

## Context

**F-103-09 (MEDIUM):** gitleaks and TruffleHog both provide baseline files, inline allowlist comments, and per-rule tuning. ACP has none. Without them, a single unavoidable false positive has **no resolution path except disabling the rule entirely** — which is how scanners get switched off.

Industry framing from audit-103: *"False positives above 30% destroy credibility… once engineers learn to ignore alerts, you're running security theater."* These controls are what keep a scanner alive after its first bad finding.

Implementing in `acp.integrity-output.sh` means `/acp-integrity` scanners inherit the same controls.

## Steps

1. **Baseline mode** — `--baseline <file>`: suppress findings whose `{rule, file, normalized-snippet-hash}` appears in the baseline. Add `--write-baseline` to generate it. Hash the snippet rather than the line number so unrelated edits don't invalidate entries.
2. **Inline suppression** — recognise `// acp-review-ignore: <RULE-ID> — <reason>` (and `#` form for shell) on the same or preceding line. **Require a reason**; suppressions without one are themselves reported as LOW.
3. **Per-rule thresholds** — optional config mapping rule → severity override or enable/disable, so a team can downgrade rather than delete a rule.
4. Emit a suppression summary line: `N findings suppressed (M baseline, K inline)` — suppression must never be invisible.
5. Document all three in `acp.review.md`, including the reason requirement.
6. Add corpus entries verifying suppression works and that suppressed findings are still counted in the summary.

## Verification

- [ ] Baseline suppresses a known finding; a new finding in the same file still reports
- [ ] Baseline entries survive unrelated line-number shifts
- [ ] Inline suppression works for TS/JS and shell comment forms
- [ ] Suppression without a reason is reported LOW
- [ ] Suppression counts appear in the summary and in `--json`
- [ ] `--ci` exit codes account for suppressions correctly
- [ ] `/acp-integrity` scanners inherit the controls without change

## User-Observable Acceptance

A team can adopt `/acp-review` on a legacy codebase by baselining existing findings and gating only on new ones.
