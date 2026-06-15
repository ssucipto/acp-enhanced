# Milestone 66: Marker Backfill & Metadata Traceability

**Target version**: 6.21.0  
**Status**: completed
**Completed**: 2026-06-15
**Estimated effort**: ~2h (1 route)  
**Source**: `/acp-sync` Finding 1 (2026-06-15) — 250+ files missing `@acp.meta.*` markers

## Goal

Achieve **100% marker coverage** across all `agent/{design,tasks,patterns}/` files so that `@acp.meta.*` blocks exist on every file, enabling the full marker-driven traceability chain:

```
Spec R-IDs → task covers: → design incorporates: → code implements:
```

Without this, `/acp-validate` self-containment probes, `/acp-sync` traceability maps, and `/acp-audit` gap analysis are blind on 90%+ of project files.

## Current State (before M66)

| Area | Files | With Markers | Coverage |
|------|-------|-------------|----------|
| `agent/design/` | ~30 | 2 | 6.7% |
| `agent/tasks/` | ~216 | 8 | 3.7% |
| `agent/patterns/` | ~12 | 0 | 0% |
| **Total** | **~258** | **10** | **3.9%** |

## Deliverables

1. **`agent/scripts/acp.backfill-markers.sh`** — Script that parses existing prose frontmatter and generates appropriate `@acp.meta.*` blocks for each file type
2. **Marker backfill applied** to all design, task, and pattern files
3. **Superseded prose frontmatter stripped** — `**Status**:`, `**Last Updated**:`, `**Created**:` fields that are now duplicated by marker fields
4. **Verification**: `acp.meta-scan.sh` shows 100% coverage on design/tasks/patterns

## Schema for Generated Markers

### Design files → `@acp.meta.design`
```
<!-- @acp.meta.design
topic: <from filename + first heading, kebab-case>
description: <from first paragraph or heading, <=150 chars>
status: <from **Status**: prose, or "active" if missing>
updated: <from **Last Updated**: prose, or today>
@acp.meta.end -->
```

### Task files → `@acp.meta.task`
```
<!-- @acp.meta.task
topic: <from filename + first heading, kebab-case>
description: <from first paragraph or heading, <=150 chars>
milestone: <from directory name milestone-N>
status: <completed if in completed-milestone dir, from metadata, or draft>
updated: <from file mtime or existing date>
@acp.meta.end -->
```

### Pattern files → `@acp.meta.pattern`
```
<!-- @acp.meta.pattern
topic: <from filename + first heading, kebab-case>
description: <from overview or first paragraph, <=150 chars>
applies_to: <from existing **Category**: or inferred>
status: active
updated: <today>
@acp.meta.end -->
```

## Target State (after M66)

| Area | Files | With Markers | Coverage |
|------|-------|-------------|----------|
| `agent/design/` | ~30 | ~30 | **100%** |
| `agent/tasks/` | ~216 | ~216 | **100%** |
| `agent/patterns/` | ~12 | ~12 | **100%** |
| **Total** | **~258** | **~258** | **100%** |

## Success Criteria

- [ ] 100% of `agent/design/*.md` have `@acp.meta.design` markers
- [ ] 100% of `agent/tasks/**/*.md` have `@acp.meta.task` markers
- [ ] 100% of `agent/patterns/*.md` have `@ap.meta.pattern` markers
- [ ] `./agent/scripts/acp.meta-scan.sh agent/` shows coverage for all three areas
- [ ] `/acp-validate` runs clean with no new errors
- [ ] Superseded prose frontmatter fields stripped where markers exist
