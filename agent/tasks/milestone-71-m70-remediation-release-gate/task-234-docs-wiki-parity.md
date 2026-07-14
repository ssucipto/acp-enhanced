---
id: task-234
milestone: M71
title: "Docs/wiki parity — domain.yml, package.yaml, validate.md, review table"
status: completed
priority: 4
complexity: medium
estimated_hours: 3
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-223
audit_findings: [F-089-06, F-089-09, F-089-10, F-089-11, F-089-12]
depends_on: [task-231]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Align all published docs with M70 shipped reality (8 review rules, new validators, new scripts).

## Steps

1. `domain.yml` — update `acp.review-scan.sh` to 8 rules (EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01)
2. `package.yaml` — add `acp.atomic-write.sh`, `acp.branch-protection-setup.sh` to scripts list
3. `acp.validate.md` — document M70 validators: branch protection warn, carryover freshness, memory field lint, `--memory`
4. `task-225.md` — fix title/steps: AP-01, NC-01 (not API-01, CQ-01)
5. `acp.review.md` — add `Phase 1` column to rules table (Y/N per rule)

## Verification

- [ ] domain.yml grep shows 8 rules
- [ ] package.yaml lists new scripts
- [ ] F-089-06, F-089-09, F-089-10 carryovers fixed

## User-Observable Acceptance

`/acp-status` and wiki loaders show consistent 8-rule Phase 1 scanner description.
