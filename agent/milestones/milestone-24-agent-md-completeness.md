# Milestone 24: AGENT.md Completeness

**Goal**: Close all gaps found in the M23 post-rebrand audit — missing commands, missing Three-Persona section, stale Conclusion, legacy Sample Prompts, missing M17 doc, and deferred M23 session memory.  
**Duration**: ~1 week (6–7 total agent-hours across 4 tasks)  
**Dependencies**: M23 (ACP Enhanced Identity) — completed ✅  
**Status**: completed

---

## Overview

M23 successfully rebranded AGENT.md from original-ACP style to ACP Enhanced. A thorough audit of the resulting document revealed six gaps — none blocking but all degrading the document's value as both a consumer-facing onboarding guide and an accurate reflection of ACP Enhanced capabilities:

1. **Missing commands** — 6 of 51 shipped commands absent from the Core Commands section
2. **Missing section** — the Three-Persona Deployment Model is central to ACP Enhanced but not in AGENT.md
3. **Stale Conclusion** — still says "Agent Directory Pattern" not "ACP Enhanced"
4. **Legacy Sample Prompts** — trigger strings reference old AGENT.md format; no `@acp.*` equivalents shown
5. **Missing M17 doc** — milestone-17-artifact-commands-system.md was never created; M17 is marked complete
6. **Deferred M23 session memory** — `agent/memory/sessions.md` M23 entry was not written at end of M23

## Deliverables

- `AGENT.md` — Core Commands complete, Three-Persona section added, Conclusion updated, Sample Prompts modernized
- `agent/milestones/milestone-17-artifact-commands-system.md` — retroactive milestone doc
- `agent/memory/sessions.md` — M23 entry prepended
- `CHANGELOG.md` — `[6.2.5]` block
- `agent/progress.yaml`, `package.yaml`, `agent/core/identity.yml` — version bumped to 6.2.5

## Success Criteria

- [ ] All 51 command files have a corresponding entry in AGENT.md Core Commands (or are explicitly noted as implementation details)
- [ ] AGENT.md contains a "Three-Persona Deployment Model" section (or prominent cross-reference to QUICKSTART.md with description)
- [ ] AGENT.md Conclusion section says "ACP Enhanced" not "Agent Directory Pattern"
- [ ] Sample Prompts section shows both legacy trigger strings AND their modern `@acp.*` equivalents
- [ ] `milestone-17-artifact-commands-system.md` exists in `agent/milestones/`
- [ ] `agent/memory/sessions.md` has M23 session entry
- [ ] Version 6.2.5 in AGENT.md, package.yaml, identity.yml, progress.yaml
- [ ] `[6.2.5]` block in CHANGELOG.md

## Key Files to Create / Modify

- `AGENT.md` — multiple section edits
- `agent/milestones/milestone-17-artifact-commands-system.md` — new file
- `agent/memory/sessions.md` — prepend M23 entry
- `CHANGELOG.md` — prepend [6.2.5] block
- `agent/progress.yaml` — version + M24 milestone + tasks 133-136
- `package.yaml` — version bump
- `agent/core/identity.yml` — version bump

## Tasks

| Task | Name | Est. Hours |
|------|------|-----------|
| task-133 | Add missing commands to AGENT.md Core Commands | 1–2 h |
| task-134 | Add Three-Persona Deployment Model section to AGENT.md | 2–3 h |
| task-135 | Update AGENT.md Conclusion and Sample Prompts | 1–2 h |
| task-136 | Session memory, M17 doc, version bump, CHANGELOG | 1–2 h |

---

**Next Milestone**: TBD — ACP Progress Visualizer (design doc exists: `agent/design/visualizer.requirements.md`)  
**Blockers**: None
