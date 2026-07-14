---
id: task-212
milestone: M63
title: "Tier3 dynamic E2E loop — all 58 command docs (F-083-01)"
status: completed
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15
completed: 2026-07-15
route: route-207
audit_findings: [F-083-01, SC-M63-01]
depends_on: [task-211]
---

## Objective

Replace static 26-command tier3 subset with dynamic loop over all non-tier-2 `acp.*.md` docs.

## Steps

1. Add `is_tier2_slug()` helper matching `command-e2e-coverage.yaml` tier 2 slugs
2. Loop `${COMMANDS_DIR}/acp.*.md` excluding template + tier 2
3. Per-doc assertions: Steps, Verification, Agent Directive (`grep -qi`), optional path hints
4. Meta-assertion: `assert_equals "58" "${TIER3_COUNT}"`
5. Run `bash e2e/acp.tier3-memory-knowledge.test.sh` — 100% pass

## Verification

- [x] 58 tier-3 commands exercised
- [x] 259 assertions, 0 failures
- [x] Hints for handoff, receive, commit, audit, route, init

## Anti-shortcuts

Registry mapping alone does NOT satisfy behavioral coverage — loop count must match registry tier count.
