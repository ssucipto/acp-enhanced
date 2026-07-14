# Milestone 48 — Carryover Resolution & Workflow Hardening (v6.9.1)

**Status**: completed  
**Priority**: P0–P2  
**Started**: 2026-06-04  
**Target**: 2026-06-11  
**Estimated**: 1 week  
**Progress**: 0% (0/8 tasks)

---

## Goal

Resolve all carryover items from M47 (audit-041/042) and address deferred B-066
workflow findings from FIFOZ feedback-002. This milestone hardens the v6.9.0
Memory Integrity Release with tests, atomicity guarantees, and workflow tooling.

---

## Deliverables

### P0 — Testing & Reliability

| Route | Description | Source |
|-------|-------------|--------|
| 085 | E2E tests for commit auto-sync (verify documents created after commit) | GAP-041-07 |
| 086 | E2E tests for repair tools (--dry-run, --all) and --memory validation | GAP-041-07 |
| 087 | Atomicity in sync operations (temp-file + atomic rename pattern) | GAP-041-08 |

### P1 — Schema & Validation

| Route | Description | Source |
|-------|-------------|--------|
| 088 | Registry schema lint: require date:/name: fields, warn unquoted colons | GAP-041-04 (F-05) |

### P2 — Workflow Tooling

| Route | Description | Source |
|-------|-------------|--------|
| 089 | Audit-first workflow documentation in wiki | B-066-01 |
| 090 | /acp-status --health: YAML lint + progress.yaml git drift check | B-066-02 |
| 091 | /acp-index init: bootstrap index from project patterns/commands | B-066-07 |
| 092 | Carryover query: CLI search for audit-carryovers.md (5000+ lines) | B-066-08 |
| 093 | Version bump 6.9.0 → 6.9.1 + CHANGELOG update | GAP-043-01 |

---

## Success Criteria

1. **E2E tests pass**: Commit auto-sync produces correct documents; repair tools
   work with --dry-run and --all; --memory validation catches bad YAML.
   New tests registered in `run-e2e-tests.sh`.
2. **Atomic sync**: Temp-file + atomic rename prevents partial state on failure.
3. **Schema lint**: Registry entries validated for required fields and unquoted colons.
4. **Workflow docs**: Audit-first pattern documented; health check available;
   index bootstrappable; carryovers queryable.

---

## Dependencies

- M47 (completed — v6.9.0)
- audit-041/042 carryovers
- feedback-002 (B-066 findings)
