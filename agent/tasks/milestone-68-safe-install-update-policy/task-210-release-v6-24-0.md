---
id: task-210
milestone: M68
title: Release v6.24.0 + audit carryover closure (route-205)
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed: 2026-07-15
route: route-205
audit_findings: [F-080-01..12, P-081-01..03, SC-080-02]
---

## Objective

Ship M68; close audit-080 + audit-081 carryovers; unblock FIFOZ.

## Steps

1. Verify route-204 validate guard passes (SC-080-03) — **gate before tag**
2. CHANGELOG v6.24.0 — safe install/update policy; note v6.9.0 doc-only gap (SC-080-02)
3. Bump identity.yml → 6.24.0; triple-sync AGENTS/CLAUDE/copilot
4. Mark M68 milestone gates ✅; progress.yaml M68 completed
5. audit-carryovers: F-080-01..12 → fixed; P-081-01..03 → fixed; `verified_in_audit: 081`
6. Git tag v6.24.0
7. Confirm route-079 `completed:` stamped (route-203 or here)

## Verification

- [ ] All M68 gates checked
- [ ] `npx tsx scripts/acp-validate.ts` — 0 errors
- [ ] E2E preserve suites green
- [ ] 15 carryovers closed (12 F-080 + 3 P-081)

## User-Observable Acceptance

FIFOZ can run `/acp-version-update` on v6.24.0 without losing identity.yml.

## Anti-shortcuts

- SC-080-02: CHANGELOG must reflect actual script behavior, not aspirational guards
