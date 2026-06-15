---
id: route-136
title: Create E2E smoke + behavioral test for acp-review
task_type: e2e-test-write
milestone: M55
complexity: medium
executor: deepseek-v4-pro
context_required: [e2e/acp.design-spec.test.sh, e2e/acp.stakeholder-report.test.sh, milestones/milestone-55-acp-review-command.md]
files_affected: [e2e/acp.review.test.sh]
tokens_est: 6000
created: 2026-06-07
completed:
---

# Route 136: Create acp-review E2E test (14 assertions)

Create `e2e/acp.review.test.sh` with 14 assertions (revised per audit-051 F-004, F-011, F-012):

Structural (7):
1. acp.review.md exists
2. code-review.md exists
3. code-quality.standards.md exists
4. Agent Directive in acp.review.md
5. 4 task types + skill catalog entry in taxonomy.yml
6. Cursor/OpenCode wrappers exist
7. Flash/Flash-Max disqualified in code-review.md (F-012)

Behavioral (7):
8. Fixture with EH-02 violation (empty catch) → detected
9. Fixture with SC-01 violation (hardcoded secret) → detected
10. Finding format includes rule ID, severity, file:line
11. --ci mode exits 1 on HIGH+ findings
12. --ci mode exits 0 on clean fixture
13. --ci output format matches `[SEVERITY] file:line ruleID — message` (F-011)
14. --carryover flag creates entries in audit-carryovers.md (F-004)
