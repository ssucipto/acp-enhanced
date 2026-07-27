---
id: task-290
milestone: M83
title: "Secrets strategy — gitleaks delegation + entropy reuse (SC-01)"
status: planned
priority: 5
complexity: high
estimated_hours: 5
created: 2026-07-27
started: null
completed: null
phase: 3b
depends_on: [task-284]
audit_findings: [F-103-03, F-103-10]
files_affected:
  - agent/scripts/acp.gitleaks.sh
  - agent/scripts/acp.review-scan.sh
  - agent/scripts/acp.entropy-scan.sh
  - agent/configurables/acp.configurables.yaml
  - agent/commands/acp.review.md
  - package.yaml
---

## Objective

Replace the hand-rolled SC-01 regex set with a layered strategy: delegate to `gitleaks` when available, reuse ACP's existing entropy scanner, and keep a small always-on prefix-pattern fallback.

## Context

**F-103-03 (HIGH):** SC-01 scored **0/4 recall** — it missed `ghp_…` (GitHub PAT), `AKIA…` (AWS), `xoxb-…` (Slack), and bare `const secret = "…"`. Pattern 1 lacks `secret` with `=`; pattern 2 requires a colon.

**F-103-10 (MEDIUM):** `acp.entropy-scan.sh` already implements entropy detection (IG-17) for `/acp-integrity`, but `/acp-review` never calls it — and its `DEFAULT_THRESHOLD=4.5` also returned nothing on the same fixtures, because structured tokens are **low**-entropy and need prefix patterns instead.

Industry baseline: gitleaks ships ~200 rules plus tuned entropy; TruffleHog 800+ plus live verification. audit-103 shortcut #2 is binding: **do not grow the hand-rolled regex set.**

Industry guidance also ranks secrets as the highest-impact, lowest-FP rule class — it should be our strongest, and today it is our weakest.

## Steps

1. Create `agent/scripts/acp.gitleaks.sh` per `local.optional-external-tool.md`:
   - `gitleaks_available()` → `command -v gitleaks`
   - `gitleaks_active()` → follows the task-292 three-valued preference convention (`auto` default)
   - absent → silent no-op
2. When active: run `gitleaks detect --no-git --report-format json`, map results to SC-01 via `ig_emit_finding` (CRITICAL).
3. **Always-on fallback** (no tool required): add known-prefix patterns for common structured tokens — `ghp_`, `gho_`, `ghs_`, `AKIA`, `ASIA`, `xoxb-`, `xoxp-`, `sk-`, `-----BEGIN … PRIVATE KEY-----` — plus bare `secret`/`token`/`credential` assignment forms missed today.
4. Share the entropy helper: expose the `acp.entropy-scan.sh` calculation for reuse and document that entropy complements, and does not replace, prefix patterns.
5. Honour task-283's test-fixture exclusion so corpus placeholders don't emit CRITICAL.
6. Add corpus entries for all four audit-103 misses plus negative cases (hashes, UUIDs, base64 config blocks).

## Verification

- [ ] All 4 audit-103 SC-01 misses are detected by the always-on fallback (no gitleaks required)
- [ ] With gitleaks present, additional formats are detected; with it absent, exit 0 and no error
- [ ] UUIDs, git SHAs, and base64 config blocks produce no findings (entropy FP classes)
- [ ] SC-01 corpus recall ≥ 90%, precision ≥ 90%
- [ ] No expansion of ad-hoc regexes beyond the documented prefix table

## User-Observable Acceptance

`const token = "ghp_…"` is flagged CRITICAL with or without gitleaks installed.
