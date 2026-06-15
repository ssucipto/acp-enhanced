---
id: route-138
title: Address post-audit gaps G-001 through G-006
task_type: bug-fix-simple
milestone: M55
complexity: low
executor: copilot
context_required: [milestones/milestone-55-acp-review-command.md §3, agent/reports/audit-050-*.md]
files_affected: [agent/commands/acp.review.md, agent/skills/code-review.md]
tokens_est: 2500
created: 2026-06-07
completed:
---

# Route 138: Resolve 6 post-audit gaps + feedback loop

G-001: Add SC-15 qualifier for gitignored lockfiles
G-002: Add "Language Scope" section noting TypeScript-first design
G-003: Verify all cross-links complete (7 targets)
G-004: Confirm behavioral E2E test is created (route-136)
G-005: Document chunking strategy for >20 files in skill file
G-006: Compact OWASP mapping to fit 500-token budget

Also create `agent/feedback/feedback-006-response.md` documenting
how audit-050 and audit-051 modified the original proposal:
- Full ruleset ships (not scoped down)
- Self-review appendix added
- Flash executor disqualified in skill file
- --diff flag added
