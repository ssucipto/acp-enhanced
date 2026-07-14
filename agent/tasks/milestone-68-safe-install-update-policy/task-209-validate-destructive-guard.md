---
id: task-209
milestone: M68
title: Validate destructive-pattern guard (route-204)
status: planned
priority: 3
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-204
---

## Objective

Prevent regression of blind overwrite patterns via `acp-validate.ts`.

## Steps

1. Add `validateInstallUpdateSafety()` scanning version-update.sh + install.sh
2. Fail on `cp "$TEMP_DIR/agent/core/"*.yml` or `cat > "$TARGET_DIR/agent/manifest.yaml"`
3. Require `acp_copy_framework_file` or documented exception comment
4. Vitest cases for pass/fail fixture strings

## Verification

- [ ] validate passes on M68 scripts
- [ ] validate fails if blind cp reintroduced (test proves)

## User-Observable Acceptance

`npx tsx scripts/acp-validate.ts` errors if someone re-adds destructive glob copy.
