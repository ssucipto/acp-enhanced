---
id: task-167
milestone: M32
title: Add Metadata Markers section to AGENT.md
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: add, metadata, markers, section, to, agentmd
description: Add Metadata Markers section to AGENT.md
milestone: M32
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Add a concise "Metadata Markers" section to `AGENT.md` documenting the `@acp.meta.*` sentinel syntax, all 8 marker kinds, required/optional fields, and how to use `acp.meta-scan.sh`.

## Context

`@acp.meta.*` markers are used throughout the codebase in specs, tasks, milestones, designs, patterns, clarifications, and code files. The scanner (`acp.meta-scan.sh`) is fully implemented. `agent/specs/spec.template.md` demonstrates the syntax. But AGENT.md has no section explaining this — a developer or agent in a fresh session cannot discover it.

The section should be concise (≤25 lines) with cross-references to the command docs for detail.

## Implementation

Find the appropriate location in AGENT.md (after "Specs" section if it exists, or after "Tasks" section). Add:

```markdown
## Metadata Markers

ACP uses language-agnostic metadata blocks for traceability. Any file can have markers:

```
```

**8 marker kinds**: `spec`, `task`, `milestone`, `design`, `pattern`, `clarification`, `code`, `artifact`

**Common fields** (all optional unless noted):
- `topic:` — comma-separated keywords
- `description:` — one-line summary ≤150 chars
- `status:` — draft | active | deprecated
- `updated:` — YYYY-MM-DD

**Kind-specific fields**: `requirements:` (spec), `covers:` (task — R-IDs from spec), `incorporates:` (task — D-IDs from design), `implements:` (code — R-IDs)

**Scanner**: `./agent/scripts/acp.meta-scan.sh [--kind <kind>] [root]`  
Outputs flat stream of parsed markers, `---` between blocks.

See `/acp-sync` (Step 1.3–1.6) for how markers feed the traceability system.
```

**Note**: Keep the section under 25 lines. Link to `acp.spec.md`, `acp.sync.md`, and `acp.meta-scan.sh` for full detail.

## Expected Output

### Files Updated
- `AGENT.md`

## Verification
- [ ] AGENT.md has a "Metadata Markers" section
- [ ] Section lists all 8 marker kinds
- [ ] Section shows the sentinel syntax example
- [ ] Section references `acp.meta-scan.sh`
- [ ] Section is ≤25 lines

## User-Observable Acceptance
An agent loading AGENT.md at session start can discover: (a) that markers exist, (b) the 8 kinds, (c) how to run the scanner. Full detail is in the command docs, not in AGENT.md.
