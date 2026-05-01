# Task 72: Fix Body-Text Hyphen References in 5 Commands

<!-- @acp.meta.task
topic: notation, body-text, command-docs
description: Fix @acp-* hyphen references in body text of acp.init.md, acp.status.md, acp.handoff.md, acp.proceed.md, acp.spec.md
milestone: M20
status: completed
updated: 2026-05-01
@acp.meta.end -->

**Milestone**: [M20 - Consistency Cleanup](../milestones/milestone-20-consistency-cleanup.md)  
**Estimated Time**: 30 minutes  

---

## Objective

Fix all remaining `@acp-` hyphen references in the body text (examples, related sections,
invocation examples, troubleshooting) of 5 command files. These are not directive headers
but they still teach the LLM incorrect notation.

---

## Files Affected

| File | Occurrences | Notes |
|------|-------------|-------|
| `acp.init.md` | ~15 | Argument parsing examples, related commands, troubleshooting |
| `acp.status.md` | ~8 | Body description, examples, related commands |
| `acp.handoff.md` | ~2 | Related commands section |
| `acp.proceed.md` | ~1 | Prerequisites section |
| `acp.spec.md` | ~10 | Invocation examples, related commands |

---

## Steps

1. Open each file and replace all `@acp-` occurrences with `@acp.` in body text
2. Be careful NOT to change the `@{namespace}-{command-name}` template placeholder in the directive pretend-context paragraph — that is a template/example, not an actual command reference
3. Verify changes with `grep "@acp-" <file>` — only the template placeholder should remain if present
