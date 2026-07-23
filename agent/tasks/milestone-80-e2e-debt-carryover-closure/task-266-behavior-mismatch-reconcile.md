---
id: task-266
milestone: M80
title: "Reconcile script-vs-test behavior mismatches"
status: planned
priority: 5
complexity: medium
estimated_hours: 2.5
created: 2026-07-24
started: null
completed: null
route: route-255
audit_findings: [F-M78-01]
depends_on: []
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

## Objective

Resolve the four F-M78-01 failures where a script's behavior and a test's expectation disagree — deciding, per case, which side is correct (no blind greening).

## Sub-items

1. **acp.version** — `acp.version-check.sh` exits 1 (not 2) on missing AGENT.md; test expects 2. Decide the intended contract: is a missing AGENT.md a usage error (2) or a generic failure (1)? Fix the losing side and document the exit-code contract in the script header.
2. **acp.package-info** — one sub-test expects exit 0 but gets 1. Reproduce, determine correct behavior, fix test or script.
3. **acp.project-update** — "confirm tag added" / "detect duplicate" assertions fail (git-tag operations in a fixture). Determine whether the fixture needs git setup (tags/commits) or the script logic regressed; fix accordingly.
4. **acp.post-milestone-sweep** — 4/5; diagnose the single failing sub-test and fix the correct side.

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
