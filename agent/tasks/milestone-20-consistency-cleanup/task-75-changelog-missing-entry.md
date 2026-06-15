# Task 75: Add CHANGELOG Entry for Post-M19 Audit Fixes

<!-- @acp.meta.task
topic: add, changelog, entry, for, post-m19, audit, fixes
description: Task 75: Add CHANGELOG Entry for Post-M19 Audit Fixes
milestone: M20
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: [M20 - Consistency Cleanup](../milestones/milestone-20-consistency-cleanup.md)  
**Estimated Time**: 10 minutes  

---

## Objective

Commit `afcf61d` (2026-05-01) introduced significant fixes and a new doc file but has no
CHANGELOG entry. Per the crosscut skill rule: every release must have a traceable CHANGELOG entry.

---

## What Was in afcf61d

- **CRITICAL**: Added `_flat_dot_get()` fallback to `acp.preferences.sh` (8 insertion points)
  so production preference files (flat-dot format) work correctly after M19's `yaml_get` migration
- **BUG**: Removed stale duplicate footer block from `acp.plan.md`  
- **BUG**: Fixed `identity.yml` stale version 6.2.0 → 6.2.1
- **BUG**: Fixed `@acp-init` → `@acp.init` in `acp.init.md` directive header
- **BUG**: Fixed `@acp-status` → `@acp.status` in `acp.status.md` directive header
- **BUG**: Fixed `@acp-index` → `@acp.index` in `acp.index.md` directive header
- **DOCS**: Created `docs/USAGE.md` — step-by-step day-to-day usage guide

---

## Steps

1. Open `CHANGELOG.md`
2. Insert a new `## [6.2.1-post] - 2026-05-01` section after the existing `[6.2.1]` block,
   OR add a supplementary `### Fixed` and `### Added` block to the existing `[6.2.1]` entry
3. Document the 6 bugs and 1 doc addition from afcf61d
