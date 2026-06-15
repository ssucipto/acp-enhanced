# Task 71: Fix Directive Headers in 9 Command Files

<!-- @acp.meta.task
topic: fix, directive, headers, in, 9, command, files
description: Task 71: Fix Directive Headers in 9 Command Files
milestone: M20
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: [M20 - Consistency Cleanup](../milestones/milestone-20-consistency-cleanup.md)  
**Estimated Time**: 30 minutes  

---

## Objective

Fix `@acp-` hyphen notation to `@acp.` dot notation in the directive header blockquotes
of 9 command files that were missed in the prior audit session.

---

## Files Affected

| File | Line | Old | New |
|------|------|-----|-----|
| `acp.audit.md` | 3-4 | `@acp-audit` | `@acp.audit` |
| `acp.clarification-address.md` | 3-4 | `@acp-clarification-address` | `@acp.clarification-address` |
| `acp.clarification-create.md` | 3-4 | `@acp-clarification-create` | `@acp.clarification-create` |
| `acp.handoff.md` | 3-4 | `@acp-handoff` | `@acp.handoff` |
| `acp.sessions.md` | 4 | `@acp-sessions` (line 3 already correct) | `@acp.sessions` |
| `acp.spec.md` | 3-4 | `@acp-spec` | `@acp.spec` |
| `acp.version-check.md` | 3 | `@acp-version-check` | `@acp.version-check` |
| `acp.version-check-for-updates.md` | 3 | `@acp-version-check-for-updates` | `@acp.version-check-for-updates` |
| `acp.version-update.md` | 3 | `@acp-version-update` | `@acp.version-update` |

---

## Steps

1. For each file listed: open file, locate directive header blockquote (first 5 lines), replace hyphen with dot in command name references
2. Verify no other directive header lines remain with hyphen notation
3. Run: `grep -r "command \`@acp-" agent/commands/` — should return empty
