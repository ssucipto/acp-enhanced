# Milestone 20: Consistency Cleanup & Notation Standardization

<!-- @acp.meta.milestone
topic: bug-fix, consistency, notation, documentation
status: in_progress
updated: 2026-05-01
@acp.meta.end -->

**Version Target**: 6.2.2  
**Priority**: High  
**Estimated Time**: 1–2 hours  

---

## Goal

Eliminate all remaining `@acp-` hyphen notation from command directive headers and
body text across the entire codebase. Fix `package.yaml` to list all commands and
scripts that exist. Add the missing CHANGELOG entry for the afcf61d audit fixes.

This milestone arose from the second comprehensive audit (2026-05-01) which found
that the previous audit session only fixed the directive header in 3 files but
left 9 other commands with hyphen-style directive headers, and left widespread
hyphen-style references throughout body text.

---

## Why This Matters

When an LLM invokes `@acp.audit`, it reads `acp.audit.md`. The directive header
says "the command `@acp-audit` has been invoked" — teaching the LLM that the
hyphen form is canonical. This contradicts the dot-notation convention used by
every other command call in the ecosystem. A consistent agent learning from its own
command files will be confused about which notation to use when invoking commands.

---

## Deliverables

1. All 9 remaining command files with hyphen-style directive headers fixed to dot notation
2. All body-text hyphen references in 5 commands fixed to dot notation
3. `AGENT.md` directory tree comments updated to dot notation
4. `package.yaml` updated with all missing commands and scripts (preferences system, project commands)
5. `CHANGELOG.md` updated with entry for v6.2.1 post-M19 audit fixes

---

## Success Criteria

- [ ] `grep -r "@acp-" agent/commands/` returns zero results in directive headers
- [ ] `package.yaml` lists every `.md` file in `agent/commands/` (excluding templates)
- [ ] `CHANGELOG.md` has an entry for the afcf61d commit
- [ ] No regressions in existing tests
