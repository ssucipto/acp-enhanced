---
id: task-294
milestone: M83
title: "OWASP Top 10:2025 mapping correction + A06/A07/A08 position"
status: planned
priority: 4
complexity: low
estimated_hours: 3
created: 2026-07-27
started: null
completed: null
phase: 5
depends_on: []
audit_findings: [F-103-08]
files_affected:
  - agent/commands/acp.review.md
  - agent/wiki/coderabbit-policy-map-lite.md
---

## Objective

Correct the one wrong OWASP mapping and take an explicit documented position on the three unmapped 2025 categories.

## Context

**F-103-08 (MEDIUM):** audit-103 verified OWASP Top 10:2025 is the current edition and checked all seven claimed mappings. Six are correct. One is wrong:

| ACP section | Claims | Actual A**:2025 |
|---|---|---|
| 6a Secrets & Input | A05:2025 | **Injection** — secrets are not injection |

Unmapped 2025 categories with **no rules at all**: **A06 Insecure Design**, **A07 Authentication Failures**, **A08 Software or Data Integrity Failures**.

A08 is arguably already covered by `/acp-integrity`, which is exactly the cross-command ownership ambiguity F-102-06 raises — resolve both consistently.

## Steps

1. Split section 6a: keep input-validation rules (SC-02) under **A05:2025 Injection**; move hardcoded-secret rules (SC-01) to the correct category and cite it accurately.
2. Add an explicit **Standards Coverage** table to `acp.review.md` listing all ten 2025 categories with: covered / partially covered / **deliberately not covered**, plus a one-line rationale each.
3. For A06 Insecure Design — document as **not covered by deterministic rules** (it is a design-review concern, not a scanner concern) and route it to Phase 2 agent review.
4. For A07 Authentication Failures — note partial coverage (SC-23, SC-24) and record whether new rules are planned or deliberately deferred.
5. For A08 Integrity Failures — document `/acp-integrity` as the owning command; cross-link both directions (closes part of F-102-06).
6. Update the policy map with any changed rule→category assignments.

## Verification

- [ ] No rule cites a category that does not match the published 2025 list
- [ ] All ten 2025 categories appear in the coverage table with an explicit status
- [ ] "Deliberately not covered" entries carry a rationale, not a blank
- [ ] A08 cross-links `/acp-integrity` in both command docs
- [ ] E2E doc assertions updated for the new section

## User-Observable Acceptance

A reader can see at a glance which OWASP 2025 categories `/acp-review` covers, which it doesn't, and why.
