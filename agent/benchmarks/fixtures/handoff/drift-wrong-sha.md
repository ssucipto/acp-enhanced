---
handoff_version: 1
handoff_mode: executor
from_executor: claude
to_executor: cursor
date: 2026-07-15
status: active
supersedes: null
git_branch: develop
git_commit: deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
git_remote: github.com/ssucipto/acp-enhanced
app_version: 6.21.1
---

# Handoff: Drift fixture → cursor

## Model / executor requirements
Any executor capable of running receive drift checks.

## Start here (receiving agent)
1. Run `/acp-receive @this-file`
2. Expect git DRIFT — pin does not match HEAD

## Problem / context
E2E fixture for receive protocol git drift warning. Pin is intentionally wrong.

## Locked decisions (do not re-litigate)
- ADR-TEST-001: Fixture pins must not match HEAD

## Assignment
Audit only

## Plan reference
- Milestone: agent/milestones/milestone-67-cross-agent-handoff-protocol.md
- Tasks: task-200
- Sequence: task-200

## What NOT to do
- Do not treat DRIFT as a hard stop in tests

## State to update as you work
- `agent/memory/sessions.md` — via `/acp-commit`

## Adjacent context (out of scope for this handoff)
- None

## Return handoff (when you finish or block)
Generate: `/acp-handoff --mode executor --to claude`

## Reference chain
| Artifact | Path |
|----------|------|
| Fixture | agent/benchmarks/fixtures/handoff/drift-wrong-sha.md |
