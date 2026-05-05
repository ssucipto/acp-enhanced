# Milestone 35: acp-validate.ts Enhancement

<!-- @acp.meta.milestone
topic: typescript, validation, tooling, placeholder, header-format
description: Extend acp-validate.ts to catch command file template placeholder bugs and header format violations automatically.
tasks: task-178..task-180
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Extend `scripts/acp-validate.ts` to automatically catch the two high-priority bugs documented in `agent/memory/lessons.md` — template placeholder leakage in command files (both directive line and pretend-context line) and invalid command file header format.  
**Duration**: 1 week  

---

## Overview

Two high-priority lessons in `lessons.md` describe bugs that have occurred in command files:

1. **Template placeholder bug** — Command files sometimes ship with `{command-name}` or similar placeholders unreplaced, on line 3 (main directive) OR line 4 (pretend-context). The current E2E test (`acp.command-docs.test.sh`) may not catch both lines.

2. **Header format violation** — Command files must have `Namespace`, `Version`, `Status`, `Scripts` frontmatter fields. If a file is created from a template but fields are left as `{placeholder}`, it silently ships broken.

`acp-validate.ts` currently validates `package.yaml` structure. This milestone extends it to validate command file format so these bugs are caught at CI time, not at agent-execution time.

---

## Deliverables

### 1. Placeholder Detection
- `acp-validate.ts` — scan all `agent/commands/*.md` for `{placeholder}` patterns in lines 3 and 4 (directive and pretend-context lines)
- Report any hits as validation errors with file path and line number

### 2. Header Format Validation
- `acp-validate.ts` — verify every `agent/commands/*.md` has the required frontmatter fields: `Namespace`, `Version`, `Status`, `Scripts`
- Report missing fields as validation errors

### 3. Command Count Parity Check
- `acp-validate.ts` — verify `agent/commands/*.md` count equals `.github/prompts/*.prompt.md` count equals `.opencode/commands/*.md` count
- Report mismatch as validation error with counts

### 4. E2E / Unit Tests
- `tests/acp.validate-ts.test.sh` — test the new checks against fixture files that contain known violations

---

## Success Criteria

- [ ] `npx ts-node scripts/acp-validate.ts` catches `{placeholder}` in command file lines 3–4
- [ ] `npx ts-node scripts/acp-validate.ts` catches missing Namespace/Version/Status/Scripts fields
- [ ] `npx ts-node scripts/acp-validate.ts` catches command/prompt/opencode count mismatch
- [ ] `tests/acp.validate-ts.test.sh` passes with ≥10 assertions
- [ ] No false positives on the current 58 clean command files

---

## Key Files to Create/Update

```
scripts/
└── acp-validate.ts        (update — 3 new validation checks)
tests/
└── acp.validate-ts.test.sh  (new — unit tests for validator)
```

---

## Tasks

1. [task-178-placeholder-detection.md](../tasks/milestone-35-acp-validate-ts-enhancement/task-178-placeholder-detection.md) — Add placeholder detection to acp-validate.ts (lines 3–4 of command files)
2. [task-179-header-format-validation.md](../tasks/milestone-35-acp-validate-ts-enhancement/task-179-header-format-validation.md) — Add command file header format validation + command/prompt/opencode count parity
3. [task-180-validate-ts-e2e-tests.md](../tasks/milestone-35-acp-validate-ts-enhancement/task-180-validate-ts-e2e-tests.md) — Write tests/acp.validate-ts.test.sh with fixture files

---

## Risks and Mitigation

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| False positives on legitimate `{...}` in code examples | Medium | Medium | Scope check to lines 3–4 only; exclude fenced code blocks |
| acp-validate.ts TypeScript version compatibility | Low | Low | Check existing `scripts/package.json` TS version before adding APIs |

---

**Next Milestone**: [milestone-36-saas-platform-benchmark.md](milestone-36-saas-platform-benchmark.md)  
**Blockers**: None  
**Notes**: Directly addresses 2 high-priority lessons.md entries. Prevents regression on command file quality as new commands are added.
