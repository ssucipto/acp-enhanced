---
handoff_version: 1
handoff_mode: executor
from_executor: claude
to_executor: cursor
date: 2026-07-13
status: active
supersedes: null
git_branch: develop
git_commit: 621ea59f8b661dc45284002f6bbe3122d7895f62
git_remote: github.com/ssucipto/acp-enhanced
app_version: 6.21.1
---

# Handoff: M51 implementation wave → cursor

## Model / executor requirements
Composer 2.5 (non-fast). Follow AGENTS.md context loading protocol.

## Start here (receiving agent)
1. Run project context protocol (CLAUDE.md / AGENTS.md Steps 1–6)
2. Run `/acp-receive @this-file` OR verify git_commit matches `git rev-parse HEAD`
3. Read locked decisions — do not re-litigate

## Problem / context
Planner completed M51 design and routing. Implementation wave is ready for Cursor executor with locked ADRs and explicit task sequence.

## Locked decisions (do not re-litigate)
- ADR-042: Executor handoffs require disk delivery with git pin
- ADR-043: Cross-repo mode remains chat-primary default

## Assignment
Implement

## Plan reference
- Milestone: agent/milestones/milestone-51-example.md
- Tasks: task-730, task-731, task-732
- Sequence: task-730 → task-731 → task-732

## What NOT to do
- Do not modify acp.handoff.md v1 cross-repo sections
- Do not re-open ADR-042 scope
- Do not skip E2E fixtures for receive protocol

## State to update as you work
- `agent/progress.yaml` — M51 milestone progress
- `agent/memory/audit-carryovers.md` — CO-051 if applicable
- `agent/memory/sessions.md` — via `/acp-commit`

## Adjacent context (out of scope for this handoff)
- `agent/reports/audit-245-example.md` — read for context only

## Return handoff (when you finish or block)
Generate: `/acp-handoff --mode executor --to claude` with:
- Tasks completed / in progress / blocked
- Commits (SHA list)
- HUMAN gates hit
- Questions for planning agent

## Reference chain
| Artifact | Path |
|----------|------|
| Milestone | agent/milestones/milestone-51-example.md |
| Proposal | agent/proposals/acp-enhanced-cross-agent-handoff-v1.md |
