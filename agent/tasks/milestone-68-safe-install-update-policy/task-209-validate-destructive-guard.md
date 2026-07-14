---
id: task-209
milestone: M68
title: Validate destructive-pattern guard (route-204)
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-204
audit_findings: [SC-080-03]
---

## Objective

Prevent regression of blind overwrite patterns via `acp-validate.ts`. **Required before v6.24.0 tag.**

## Steps

1. Add `validateInstallUpdateSafety()` scanning version-update.sh + install.sh
2. Fail on `cp "$TEMP_DIR/agent/core/"*.yml` or `cat > "$TARGET_DIR/agent/manifest.yaml"`
3. Fail on `find ... *.*.md -exec cp` without namespace filter (P-081-01 regression)
4. Require `acp_copy_framework_file` or documented exception comment
5. Vitest cases for pass/fail fixture strings

## Verification

- [ ] validate passes on M68 scripts
- [ ] validate fails if blind cp reintroduced (test proves)
- [ ] Blocks v6.24.0 tag if guard removed (SC-080-03)

## User-Observable Acceptance

`npx tsx scripts/acp-validate.ts` errors if someone re-adds destructive glob copy.

## Anti-shortcuts

- SC-080-03: automated guard prevents repeat of M47 doc-only shortcut
