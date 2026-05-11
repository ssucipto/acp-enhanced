---
id: route-028
title: M41a — Update domain.yml command count (BUG-004)
task_type: documentation-sync
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/wiki/domain.yml
  - agent/reports/audit-014-external-feedback-quality-and-improvement-plan.md
files_affected:
  - agent/wiki/domain.yml
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Fix the command count discrepancy in `agent/wiki/domain.yml`. The file currently shows `count: 58` but the actual verified command count is 59 (57 acp.* + 2 git.* + command.template.md excluded). After routes 024–027 create 4 new command docs, the count will be 63. Update count now and add annotation.

## Acceptance Criteria

- [ ] `agent/wiki/domain.yml` `commands.count` updated from `58` to `59`
- [ ] Comment or annotation added noting "Will be 63 after route-024/025/026/027 (acp.feedback, acp.task, acp.install, acp.dispatch) are implemented"
- [ ] Count verified by running: `ls agent/commands/acp.*.md agent/commands/git.*.md | wc -l`
- [ ] No other fields in `domain.yml` modified

## Implementation Notes

Run the count verification command first:
```bash
ls agent/commands/*.md | grep -v template | wc -l
```
Use the actual count from the command, not a manually assumed number. Document the count verification method in a comment.
