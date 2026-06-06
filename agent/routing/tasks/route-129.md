---
id: route-129
title: "Fix pre-existing @acp. occurrences in acp.visualize.md (CARRY-047-01)"
task_type: command-doc-update
milestone: M53
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.visualize.md
  - agent/patterns/local.command-naming-convention.md
files_affected:
  - agent/commands/acp.visualize.md
tokens_est: 50
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 129: Fix @acp. in acp.visualize.md

## Objective

Replace 3 pre-existing `@acp.` occurrences in `acp.visualize.md` with `/acp-` prefix per ACP naming convention.

## Context

CARRY-047-01 identified 3 `@acp.` occurrences in `acp.visualize.md` at lines 110-119. These pre-date M50 and are inconsistent with the `/acp-` naming convention documented in `local.command-naming-convention.md`.

## Changes

### `agent/commands/acp.visualize.md`

**Before (line 110-111):**
```markdown
- [`@acp.status`](acp.status.md) — Text-based status (no browser required)
- [`@acp.report`](acp.report.md) — Generate a text report
```

**After:**
```markdown
- [`/acp-status`](acp.status.md) — Text-based status (no browser required)
- [`/acp-report`](acp.report.md) — Generate a text report
```

**Before (line 119):**
```markdown
- To use with a different project: `@acp.visualize --path /path/to/other/agent/progress.yaml`
```

**After:**
```markdown
- To use with a different project: `/acp-visualize --path /path/to/other/agent/progress.yaml`
```

## Verification

- [ ] Zero `@acp.` occurrences in `acp.visualize.md` after fix
- [ ] `e2e/acp.command-docs.test.sh` `@acp.` check now passes (was 465/466, now 466/466)
- [ ] All links still resolve correctly
