---
id: task-280
milestone: M83
title: "Scanner scope fixes — multi-path, --self, .mjs/.cjs"
status: planned
priority: 5
complexity: low
estimated_hours: 3
created: 2026-07-27
started: null
completed: null
phase: 1
depends_on: []
audit_findings: [F-102-01, F-102-02, F-102-03]
files_affected:
  - agent/scripts/acp.review-scan.sh
---

## Objective

Make `acp.review-scan.sh` scan every path it is given, support the documented `--self` flag, and traverse `.mjs`/`.cjs` in directory mode.

## Context

**F-102-01 (HIGH):** the arg loop assigns `TARGET="$1"` per path (`:24`), so the recipe printed in `acp.review.md:71` — `acp.review-scan.sh --ci scripts/ agent/scripts/` — scans only `agent/scripts/`. Verified: two dirs each seeding one secret produced one finding. Unmasking `scripts/` surfaced 2 genuine HIGH findings.

**F-102-02 (HIGH):** `--self` is documented at `acp.review.md:81` and `:347` (paths: `scripts/`, `agent/scripts/`, `agent/commands/`, `e2e/`) but the scanner treats it as a path and exits 2.

**F-102-03 (MEDIUM):** `scan_path` accepts `*.mjs|*.cjs` at `:133`, but the `find` at `:141` omits them, so they are never reached via directory traversal.

## Steps

1. Replace the scalar `TARGET` with a `TARGETS=()` array; append each positional arg; default to `.` when empty.
2. Loop `scan_path` over every element of `TARGETS`.
3. Implement `--self`: expand to `scripts/ agent/scripts/ agent/commands/ e2e/`, skipping missing directories silently (per `acp.review.md:347`).
4. Add `-o -name '*.mjs' -o -name '*.cjs'` to the `find` predicate.
5. Preserve existing behaviour: `--ci` / `--json` parsing via `ig_parse_common_args`, exit 2 on a genuinely missing path.
6. **(F-104-06)** `ig_parse_common_args` (`acp.integrity-output.sh:18-28`) `break`s at the first non-flag argument, so anything after a positional lands in `IG_REMAINING_ARGS`. The new array loop must **reject or re-handle** flags encountered after positionals — otherwise `acp.review-scan.sh scripts/ --ci` appends `--ci` as a scan path.

## Verification

- [ ] Two directories each seeding one finding produce **2** findings
- [ ] `--self` runs without error and scans all four paths
- [ ] `--self` skips missing directories silently
- [ ] A `.mjs` file under a scanned directory is detected
- [ ] Missing path still exits 2; `--ci` still exits 1 on CRITICAL/HIGH
- [ ] `scripts/ --ci` (flag **after** path) does not treat `--ci` as a scan target (F-104-06)
- [ ] macOS + Linux clean

## User-Observable Acceptance

`bash agent/scripts/acp.review-scan.sh --ci scripts/ agent/scripts/` reports findings from **both** directories, and `--self` works exactly as the command doc describes.
