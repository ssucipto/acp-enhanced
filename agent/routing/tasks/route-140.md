---
id: route-140
title: ACP self-review appendix + mobile detection rules
task_type: command-doc-update
milestone: M55
complexity: low
executor: copilot
context_required: [audit-050.md §F3, milestones/milestone-55-acp-review-command.md]
files_affected: [agent/commands/acp.review.md, agent/skills/code-review.md]
tokens_est: 2000
created: 2026-06-07
completed:
---

# Route 140: Self-review appendix + mobile detection

Add Appendix A to acp.review.md with 10 ACP self-review rules (SH-01 to AP-03)
that auto-activate when agent/commands/ directory is detected.

Add mobile detection logic: activates MASVS rules when package.json
contains react-native, expo, or @capacitor/core.

Add SC-21 qualifier: cert pinning applies to bare workflow / custom dev
client only.
