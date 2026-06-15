---
id: task-168
milestone: M32
title: Add Specs section to AGENT.md
status: completed
priority: 3
complexity: low
estimated_hours: 1.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: add, specs, section, to, agentmd
description: Add Specs section to AGENT.md
milestone: M32
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Add a concise "Specs" section to `AGENT.md` documenting the `agent/specs/` directory, `@acp.spec` command, FR-IDs (`R<N>`), Behavior Tables, and spec-to-task traceability via `covers:`.

## Context

`agent/specs/` exists with `spec.template.md`. `acp.spec.md` (v1.1.0) is a full implementation. FR-IDs (`R1`, `R2`, ...) are referenced in specs, tasks, and code via `covers:` and `implements:` fields. Behavior Tables are a key spec section format. None of this is documented in AGENT.md.

## Implementation

Add after the "Metadata Markers" section (task-167):

```markdown
## Specs

Specifications live in `agent/specs/` and are created via `/acp-spec`. They define requirements with numbered IDs:

```markdown
## Requirements

- **R1** — The system must authenticate users before accessing protected routes.
- **R2** — Session tokens must expire after 24 hours.
```

**FR-IDs** (`R<N>`): Every requirement gets a unique ID. Tasks reference them via `covers:` in their marker. Code references them via `implements:`.

**Behavior Table** (required in specs):
```markdown
| Scenario | Input | Expected Output |
|---|---|---|
| Valid login | correct credentials | 200 + session token |
| Invalid login | wrong password | 401 |
```

**Traceability chain**: Spec R-IDs → `covers: R1, R2` in task marker → `implements: R1` in code marker → `/acp-sync` validates all R-IDs are covered.

**Create a spec**: `/acp-spec --from-clarification <file>` or `/acp-spec --interactive`

See `agent/specs/spec.template.md` for the full template.
```

Keep section under 25 lines.

## Expected Output

### Files Updated
- `AGENT.md`

## Verification
- [ ] AGENT.md has a "Specs" section
- [ ] Section references `agent/specs/`
- [ ] Section explains FR-IDs with example (`R1`, `R2`)
- [ ] Section explains Behavior Table format
- [ ] Section references `/acp-spec` command
- [ ] Section is ≤25 lines

## User-Observable Acceptance
A developer reading AGENT.md understands: (a) where specs live, (b) how FR-IDs work, (c) how to create a spec, (d) how the traceability chain connects spec → task → code.
