---
id: task-170
milestone: M32
title: Update AGENT.md with DR-IDs and stacked/yolo proceed modes
status: completed
priority: 3
complexity: low
estimated_hours: 1.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: update, agentmd, with, dr-ids, and, stackedyolo, proceed, modes
description: Update AGENT.md with DR-IDs and stacked/yolo proceed modes
milestone: M32
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Update the existing "Designs" section of AGENT.md to document DR-IDs (`D<N>`) and the `incorporates:` task field, and add a brief "Proceed Modes" section or update the existing proceed reference to include `--stacked`, `--yolo`, and Step 3.5 audit.

## Context

`acp.design-create.md` uses DR-IDs (`D1`, `D2`, ...) to label atomic design units. Tasks reference them via `incorporates:` in their marker. This is part of the design-to-task traceability chain and is undocumented in AGENT.md.

`acp.proceed.md` has advanced execution modes (`--stacked` for milestone chains, `--yolo` for autonomous) and a mandatory Step 3.5 post-completion audit. These are powerful but invisible to developers who don't read the full 1,305-line proceed command doc.

## Implementation

### Part 1: Update Designs section

Find the existing "Designs" or "Design Documents" section in AGENT.md. Add:

```markdown
**Design Atomic Units (DR-IDs)**:
As you write a design, label key decisions and implementation units with `D<N>` IDs:
```
**D1: Authentication Strategy** — Use JWT with RS256 ...
```
Tasks inline these via `/acp-task-create` and declare `incorporates: D1, D3` in their marker.
`/acp-validate` Probe 2 verifies the inlining happened.
```

### Part 2: Add Proceed Modes

Find the existing `/acp-proceed` reference in AGENT.md. Add a brief "Key modes" list:

```markdown
**Key `/acp-proceed` modes**:
- `/acp-proceed` — single task, interactive (default)
- `/acp-proceed --turbo` / `--yolo` — autonomous, no confirmation prompt
- `/acp-proceed --stacked` — full milestone as sequential stacked worktrees
- `/acp-proceed --worktrees` — parallel sub-agents, one per task
- Step 3.5 (automatic): post-completion 7-part audit; spawns remediation sub-agent if drift found

See `acp.proceed.md` for full argument reference (A1–A11).
```

## Expected Output

### Files Updated
- `AGENT.md`

## Verification
- [ ] AGENT.md Designs section mentions DR-IDs (`D<N>`)
- [ ] AGENT.md mentions `incorporates:` field
- [ ] AGENT.md proceed reference includes `--stacked`, `--yolo`
- [ ] AGENT.md proceed reference mentions Step 3.5 audit
- [ ] Total new content added is ≤20 lines

## User-Observable Acceptance
Developers reading AGENT.md know: (a) DR-IDs exist and how to use them, (b) `--stacked` enables full milestone automation, (c) Step 3.5 audit runs automatically after each task. They can then read the full command docs for details.
