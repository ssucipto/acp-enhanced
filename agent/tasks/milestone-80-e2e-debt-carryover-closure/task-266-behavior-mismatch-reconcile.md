---
id: task-266
milestone: M80
title: "Reconcile script-vs-test behavior mismatches"
status: completed
priority: 5
complexity: medium
estimated_hours: 2.5
created: 2026-07-24
started: null
completed: null
route: route-255
audit_findings: [F-M78-01, F-100-01, F-100-02, F-100-05]
depends_on: []
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

> **Amended per audit-100** with verified root causes: post-milestone-sweep is a **missing +x bit** (not a behavior mismatch); version-check has **no documented exit convention** (free choice + duplicate ERR traps); project-update fails on a **fixture** issue (the script already emits the message).

## Objective

Resolve the four F-M78-01 failures where a script's behavior and a test's expectation disagree — deciding, per case, which side is correct (no blind greening).

## Sub-items

1. **acp.version** — `acp.version-check.sh:31` exits 1 (not 2) on missing AGENT.md; test expects 2. **No documented convention exists** (command doc is silent — F-100-02), so this is a free choice: pick 1 or 2, **document the exit-code contract in the script header**, and fix the losing side. Low regression risk — no test/script depends on its exit 1. **Bonus (F-100-02)**: the script has **duplicate ERR traps** (lines 7-8, second overrides first) — collapse to one.
2. **acp.package-info** — the "Show global package info" sub-test expects exit 0 but gets 1. Reproduce (likely a global-registry fixture under the test `$HOME`), determine correct behavior, fix test or script.
3. **acp.project-update** — "confirm tag added" / "detect duplicate" assertions get **empty output**, though `acp.project-update.sh:227` already emits "✓ Added tag" and `:212` "⊘ Tag already exists". So the script exits before its tag logic → **trace the `--add-tag` test block's fixture** (the `register_project` setup for `test-project`) BEFORE touching the script (F-100-05).
4. **acp.post-milestone-sweep** — the failing sub-test is "Script is executable": `agent/scripts/acp.post-milestone-sweep.sh` is git mode **100644 (not executable)**. Fix = `chmod +x agent/scripts/acp.post-milestone-sweep.sh` **and** `git update-index --chmod=+x …` so the tracked mode becomes 100755. Note: the test's `|| true # Windows` does NOT suppress the recorded FAIL (F-100-01).

## Steps

1. For each, reproduce and read the assertion + the script path it exercises.
2. Make an explicit code-vs-test decision; record the rationale in the task (or script header for contracts).
3. Implement the minimal fix; re-run behavioral assertions to green.
4. If any is an intentional design choice the test wrongly encodes, mark it documented-irreducible with the decision (do NOT force green).

## Verification

- [ ] acp.version exit-code contract decided + documented; test green
- [ ] acp.package-info green with correct exit expectation
- [ ] acp.project-update git-fixture assertions green
- [ ] acp.post-milestone-sweep 5/5 (or documented-irreducible)
- [ ] Every decision (test-fix vs code-fix vs irreducible) recorded with rationale

## User-Observable Acceptance

Each of these commands behaves per a stated, tested contract; the tests pass because behavior and expectation now agree, with the reasoning on record.
