# Milestone 47 — Memory Integrity & Feedback-Driven Improvements (v6.9.0)

**Status**: completed  
**Priority**: P0 — Critical  
**Started**: 2026-06-04  
**Target**: 2026-06-11  
**Estimated**: 1–2 weeks  
**Progress**: 0% (0/11 tasks)

---

## Goal

Address all P0/P1/P2 gaps identified in feedback-001 and feedback-002 from the FIFOZ
production usage review. The core deliverable is **commit-integrated document auto-sync**:
`/acp-commit` must generate/update `agent/sessions/*.md` and `agent/patterns/*.md` from
registries on every successful commit, making the dual-store model transparent to agents
and the visualizer.

Secondary deliverables: memory-layer YAML validation, YAML quoting integrity, schema
alignment, and documentation of the dual-store architecture.

---

## Deliverables

### P0 — Commit Auto-Sync (Critical)

| Route | Description |
|-------|-------------|
| 074 | `/acp-commit` step 2b: auto-sync `agent/sessions/{date}-{slug}.md` from registry |
| 075 | `/acp-commit` step 3b: auto-sync `agent/patterns/{name}.md` from registry |
| 076 | `/acp-commit` step 6b: re-sync session documents after weekly compaction |
| 077 | `/acp-pattern-sync` and `/acp-session-sync` — manual repair tools (same engine) |
| 078 | `/acp-validate --memory` — YAML lint for patterns.md, sessions.md, progress.yaml |

### P1 — Data Integrity (High)

| Route | Description |
|-------|-------------|
| 079 | `/acp-version-update` guard: warn before overwriting project-specific core files |
| 080 | YAML quoting directives: commit and update commands must quote scalars containing `:` |
| 081 | Schema alignment: commit output (`tasks`) vs visualizer expectations (`tasks_completed`) |

### P2 — Documentation & UX (Medium)

| Route | Description |
|-------|-------------|
| 082 | Dual-store wiki: document registry vs document directories for patterns + sessions |
| 083 | Pattern promotion enforcement: commit step 3 prompts when key_fact is a reusable pattern |
| 084 | Command onboarding: `/acp-init` shows "commands for your current phase" |

---

## Success Criteria

1. **Default `/acp-commit` syncs documents** — after every commit without `--no-sync`,
   every registry entry has a corresponding markdown file in `agent/sessions/` and
   `agent/patterns/`.
2. **Sync is idempotent** — re-running commit without registry changes does not
   rewrite files unnecessarily.
3. **Confirmation output reports sync counts** — files created/updated shown in commit
   confirmation.
4. **`/acp-validate --memory` catches bad YAML** — fails with line numbers on malformed
   patterns.md, sessions.md, or progress.yaml.
5. **No more silent parse failures** — agents and visualizer get consistent data.
6. **Version updates don't silently overwrite** — `/acp-version-update` confirms before
   overwriting identity.yml, domain.yml, taxonomy.yml.

---

## Dependencies

- feedback-001 (incident detail)
- feedback-002 (release recommendations + audit-066 addendum)
- M44 (completed — some feedback items were partially addressed there)
- Visualizer repo (separate — V-01 through V-05 not in this milestone)

---

## Related

- Feedback source: `agent/feedback/feedback-001-pattern-memory-visualizer-gaps.md`
- Feedback source: `agent/feedback/feedback-002-acp-enhanced-next-release-review.md`
- Audit companions: audit-065, audit-066 (FIFOZ repo)
- Visualizer issues: separate repo `agent-context-protocol-visualizer`
