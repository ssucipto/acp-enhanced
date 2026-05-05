# Milestone 31: E2E Test Coverage — Marker & Spec System

<!-- @acp.meta.milestone
topic: e2e, testing, meta-scan, spec, sync, markers, coverage
description: Add E2E test coverage for the marker/spec/sync system and identify 8 script-bound commands currently untested.
tasks: task-162..task-166
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Add automated E2E tests for `acp.meta-scan.sh`, `@acp.spec`, `@acp.sync` (marker stream), `agent/drafts/`, and the 8 script-bound commands that currently have zero test coverage.  
**Duration**: 1–1.5 weeks  

---

## Overview

ACP Enhanced has full implementations of:
- `agent/scripts/acp.meta-scan.sh` — the POSIX-portable marker scanner
- `agent/commands/acp.spec.md` — spec creation with FR-IDs and Behavior Tables
- `agent/commands/acp.sync.md` — marker-stream traceability (Steps 1.3–1.6)
- `agent/drafts/` — planning draft convention (after M30)

None of these have any E2E tests. Additionally, `agent/memory/lessons.md` documents a known gap: 8 script-bound commands have zero E2E coverage.

This milestone closes those gaps with concrete test suites.

---

## Deliverables

### 1. acp.meta-scan.sh Tests (15+ assertions)
- `e2e/acp.meta-scan.test.sh` — scan operations, all 8 marker kinds, `--kind` filter, cross-language markers, empty output path

### 2. acp.spec Command Tests
- `e2e/acp.spec.test.sh` — command doc format smoke test (file structure, required sections, FR-ID format)

### 3. acp.sync Command Tests
- `e2e/acp.sync.test.sh` — sync command doc format + meta-scan integration path (verify Steps 1.3–1.6 references)

### 4. agent/drafts Tests
- `e2e/acp.drafts.test.sh` — verify directory exists, .gitkeep committed, template accessible (created in M30 task-161, expanded here)

### 5. Script-bound Command Coverage
- E2E tests for 8 currently untested script-bound commands (package-create, package-publish, preferences-create, preferences-set, preferences-show, preferences-validate, package-validate, acp.install.sh bootstrap test)

---

## Success Criteria

- [ ] `e2e/acp.meta-scan.test.sh` exists with ≥15 assertions, all pass
- [ ] `e2e/acp.spec.test.sh` exists with ≥5 assertions, all pass
- [ ] `e2e/acp.sync.test.sh` exists with ≥5 assertions, all pass
- [ ] 8 script-bound command tests added to appropriate e2e files (or new files)
- [ ] `run-e2e-tests.sh` picks up all new test files
- [ ] All new tests pass in CI (`bash run-e2e-tests.sh`)

---

## Key Files to Create/Update

```
e2e/
├── acp.meta-scan.test.sh           (new)
├── acp.spec.test.sh                (new)
├── acp.sync.test.sh                (new)
└── acp.drafts.test.sh              (new — also covers M30 task-161)
tests/
└── acp.script-commands.test.sh    (new or expand existing)
```

---

## Tasks

1. [task-162-meta-scan-e2e-tests.md](../tasks/milestone-31-e2e-test-coverage-marker-spec/task-162-meta-scan-e2e-tests.md) — Write e2e/acp.meta-scan.test.sh (15+ assertions)
2. [task-163-spec-command-e2e-tests.md](../tasks/milestone-31-e2e-test-coverage-marker-spec/task-163-spec-command-e2e-tests.md) — Write e2e/acp.spec.test.sh (command doc format smoke test)
3. [task-164-sync-command-e2e-tests.md](../tasks/milestone-31-e2e-test-coverage-marker-spec/task-164-sync-command-e2e-tests.md) — Write e2e/acp.sync.test.sh
4. [task-165-script-bound-command-e2e.md](../tasks/milestone-31-e2e-test-coverage-marker-spec/task-165-script-bound-command-e2e.md) — Write E2E tests for 8 untested script-bound commands
5. [task-166-drafts-e2e-test.md](../tasks/milestone-31-e2e-test-coverage-marker-spec/task-166-drafts-e2e-test.md) — Write e2e/acp.drafts.test.sh and wire into run-e2e-tests.sh

---

## Risks and Mitigation

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| meta-scan tests require fixture files | Low | High | Create minimal fixture files in tests/yaml-parser-fixtures/ or new e2e/fixtures/ dir |
| Script-bound commands need live install to test | Medium | Medium | Use existing acp-bootstrap.sh install pattern from acp.template-files.test.sh as reference |

---

**Next Milestone**: [milestone-32-agent-md-protocol-documentation.md](milestone-32-agent-md-protocol-documentation.md)  
**Blockers**: M30 must complete first (task-161 creates e2e/acp.drafts.test.sh stub)  
**Notes**: Known gap documented in lessons.md (E2E coverage). This milestone directly addresses that lesson.
