---
id: task-162
milestone: M31
title: Write e2e/acp.meta-scan.test.sh (15+ assertions)
status: completed
priority: 3
complexity: medium
estimated_hours: 3
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: write, e2eacpmeta-scantestsh, 15, assertions
description: Write e2e/acp.meta-scan.test.sh (15+ assertions)
milestone: M31
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Create `e2e/acp.meta-scan.test.sh` with ≥15 assertions testing `agent/scripts/acp.meta-scan.sh` — covering: basic scan, all 8 marker kinds, `--kind` filtering, cross-language comment stripping, empty output path, and field parsing.

## Context

`agent/scripts/acp.meta-scan.sh` is a full POSIX-portable awk implementation that parses `@acp.meta.<kind>` ... `@acp.meta.end` blocks across any file type. It strips comment prefixes (`<!-- //  # -- ;; * (*`), parses key: value fields, and outputs a flat stream separated by `---`. 

This script has zero automated tests. Given it's a core traceability tool used by `acp.sync.md` and `acp.task-create.md`, test coverage is required.

## Implementation

Create fixture files in `e2e/fixtures/meta-scan/` (or `tests/yaml-parser-fixtures/` if that's the fixture convention):

**Fixture 1** (`spec-markers.md`): Markdown file with a `@acp.meta.spec` block
**Fixture 2** (`task-markers.md`): Markdown file with a `@acp.meta.task` block
**Fixture 3** (`code-markers.ts`): TypeScript file with `// @acp.meta.code` block
**Fixture 4** (`multi-markers.md`): Markdown with 3 different marker kinds
**Fixture 5** (`no-markers.md`): Markdown with no markers (empty output test)

Test cases:
1. Basic scan returns output for spec-markers.md
2. Output contains `kind: spec`
3. Output contains `file:` field with correct path
4. `--kind spec` returns only spec markers
5. `--kind task` returns no output when only spec markers present
6. `--kind spec,task` returns both
7. TypeScript code markers stripped of `//` prefix correctly
8. `topic:` field parsed correctly
9. `requirements:` field parsed correctly
10. `covers:` field parsed correctly
11. Multi-marker file produces 3 `---` separated blocks
12. No-markers file produces empty output (exit 0)
13. Non-existent `--kind` returns empty output (exit 0)
14. Scan of specific file path (not directory)
15. Scan of entire `agent/` tree returns at least 1 result (spec.template.md has a marker)

**Shell compatibility**: Use `bash` or `sh` — no bash4-only features. Use `grep -c` not `grep --count`. Use `wc -l` for counting.

## Expected Output

### Files Created
- `e2e/acp.meta-scan.test.sh`
- `e2e/fixtures/meta-scan/spec-markers.md` (or equivalent fixture dir)
- `e2e/fixtures/meta-scan/task-markers.md`
- `e2e/fixtures/meta-scan/code-markers.ts`
- `e2e/fixtures/meta-scan/multi-markers.md`
- `e2e/fixtures/meta-scan/no-markers.md`

## Verification
- [ ] `bash e2e/acp.meta-scan.test.sh` passes all ≥15 assertions
- [ ] Tests run in <5 seconds
- [ ] No hardcoded absolute paths — use `$( cd "$(dirname "$0")/.." && pwd )` for root
- [ ] Tests clean up any temp files they create

## User-Observable Acceptance
`bash run-e2e-tests.sh` shows `acp.meta-scan.test.sh` PASS with 15+ assertions. The meta-scan script is now covered and regressions will be caught.
