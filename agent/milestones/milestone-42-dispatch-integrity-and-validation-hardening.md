<!-- @acp.meta.milestone
id: M42
title: Dispatch Integrity + Validation Hardening
status: not-started
tasks: route-036, route-037, route-038, route-039, route-040, route-041, route-042
completed:
version_introduced: 6.8.0
feedback_source: agent/feedback/acp-enhanced-final-audit-report.md
audit_source: agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
@acp.meta.end -->

# Milestone 42: Dispatch Integrity + Validation Hardening

**Status**: Completed  
**Target Version**: 6.7.0 → 6.8.0  
**Feedback Source**: [acp-enhanced-final-audit-report.md](../feedback/acp-enhanced-final-audit-report.md) (Perplexity AI external final audit)  
**Audit**: [audit-015](../reports/audit-015-m41-verification-and-final-audit-assessment.md)  
**Estimated Duration**: 1–2 weeks  

---

## Overview

Resolves all 9 pending findings from audit-015 across four subsystems:

1. **Dispatch integrity** (BUG-003): `updateRoutingYml()` is called before the API stream — stale state if the call fails or SIGINT received. Critical correctness bug.
2. **Validation hardening** (MEMORY-002, VALIDATE-001, VALIDATE-002): `acp-validate.ts` is missing three checks — sessions.md structure, AGENTS.md byte-size guard, and parity filename diff.
3. **Routing completeness** (ROUTING-001, ROUTING-002, ROUTING-003): 9 common task types are missing from `taxonomy.yml`, causing silent executor fallback. `getSkillFile()` has no explicit mapping for these types. No staleness check on taxonomy data.
4. **Memory hygiene** (MEMORY-001, STRUCT-003): lessons.md accumulates superseded entries forever. FINAL-REVIEW.md is outside the `agent/` tree and invisible to context protocol.

This milestone has no new command docs — all work is TypeScript, YAML config, and one file move. No version-bump is required until route-042 (wrap-up).

---

## Route Plan

| Route | Finding(s) | Severity | Type | Est. Hours |
|-------|-----------|---------|------|-----------|
| route-036 | BUG-003 | HIGH | typescript-feature | 1–2h |
| route-037 | MEMORY-002 | HIGH | typescript-feature | 1–2h |
| route-038 | VALIDATE-001 + VALIDATE-002 | HIGH + LOW | typescript-feature | 1–2h |
| route-039 | ROUTING-001 + ROUTING-002 | HIGH + MED | yaml-schema + typescript | 2–3h |
| route-040 | MEMORY-001 | MEDIUM | typescript-feature | 1–2h |
| route-041 | ROUTING-003 | LOW | typescript-feature | 1h |
| route-042 | STRUCT-003 + wrap-up | LOW | documentation-sync | 1h |

**Total estimate**: 8–13 hours across 7 routes

---

## Route-036 — Fix dispatch.ts updateRoutingYml() execution order + SIGINT handler (BUG-003)

**Finding**: `updateRoutingYml()` is called at line 208 in `scripts/acp-dispatch.ts`, BEFORE the API stream begins. If the API call fails, network drops, or SIGINT received, `routing.yml` permanently shows the intended executor/model even though no work was done. Additionally, SIGINT during streaming loses the ledger row — tokens billed but not recorded.

- [ ] Locate `updateRoutingYml(executor, modelConfig.model)` call at line ~208
- [ ] Move it to AFTER `appendLedger()` call (currently at line ~269)
- [ ] The correct order: `streamToConsole()` → `appendLedger()` → `updateRoutingYml()`
- [ ] Add SIGINT handler (before the API call begins) that:
  - Catches `SIGINT` (Ctrl+C)
  - Flushes a partial ledger row with `tokens: 0, cost: 0, note: "interrupted"` before exit
  - Does NOT call `updateRoutingYml()` (routing.yml stays at previous state)
  - Exits cleanly with code 130 (standard SIGINT exit code)
- [ ] Verify: no regression on normal (successful) dispatch flow
- [ ] Verify: on simulated failure, routing.yml retains previous executor value

---

## Route-037 — Add validateSessionsMemory() to acp-validate.ts (MEMORY-002)

**Finding**: `acp-validate.ts` has no check for `sessions.md` YAML structure. BUG-001 (malformed entry) was undetected for an entire milestone (M40). If `/acp-validate` had caught it, it would have been fixed 14 routes earlier.

- [ ] Add `validateSessionsMemory()` function to `scripts/acp-validate.ts`
- [ ] Read `agent/memory/sessions.md` (handle file-not-found gracefully)
- [ ] Split on `\n- date:` pattern (same as `getLastNSessions()` in `acp-dispatch.ts`)
- [ ] For each parsed entry, verify presence of required YAML keys:
  - `date:` — must be ISO date string (YYYY-MM-DD)
  - `executor:` — must not be empty
  - `tasks:` — must be present (array or string)
  - `done:` — must be present
- [ ] On validation failure: print line number and key name, mark overall validation as FAIL
- [ ] On success: print `✅ sessions.md: [N] entries, all valid`
- [ ] Call `validateSessionsMemory()` from the no-args (full validate) path
- [ ] Do NOT call it from `--parity-only` path (keep that flag fast)

---

## Route-038 — AGENTS.md byte-size check + parity diff filenames (VALIDATE-001 + VALIDATE-002)

**Finding VALIDATE-001**: No guard on AGENTS.md size. Current size: 11,043 bytes (safe). If content from AGENT.md (90,368 bytes) is accidentally merged, it silently exceeds tool auto-load limits. CLAUDE.md/copilot-instructions.md are copies that would also balloon.  
**Finding VALIDATE-002**: `runParityCheck()` reports count mismatch but not which specific files are missing. At 63 commands, manual diff is required.

### VALIDATE-001 — AGENTS.md byte-size check
- [ ] Add `agents_md_rules:` block to `agent/core/constraints.yml`:
  ```yaml
  agents_md_rules:
    max_bytes: 15000        # ~15KB hard limit — tool auto-load threshold
    warn_at_bytes: 12000   # ~12KB soft warning
    rationale: "AGENTS.md is auto-loaded by some tools; must stay compact"
  ```
- [ ] Add `validateAgentsMdSize()` function to `scripts/acp-validate.ts`
- [ ] Read `agents_md_rules` from `constraints.yml`
- [ ] `fs.statSync('AGENTS.md').size` — get byte count
- [ ] If `> warn_at_bytes`: print `⚠️ AGENTS.md: [N] bytes (warn threshold: [W])`
- [ ] If `> max_bytes`: print `❌ AGENTS.md: [N] bytes exceeds [M] byte limit` and mark FAIL
- [ ] Also check `CLAUDE.md` and `.github/copilot-instructions.md` against same limit
- [ ] Call from no-args validate path

### VALIDATE-002 — Parity diff filenames
- [ ] Update `runParityCheck()` in `scripts/acp-validate.ts`
- [ ] Build three sets: `commandsSet` (agent/commands/acp.*.md), `promptsSet` (.github/prompts/acp-*.prompt.md), `opencodeSet` (.opencode/commands/acp-*.md)
- [ ] Normalize each set to command name (strip path prefix and suffix)
- [ ] Compute symmetric difference: files in commands but not in prompts/opencode, and vice versa
- [ ] On mismatch: print each missing filename explicitly, not just counts:
  ```
  ❌ Parity mismatch: commands/acp.foo.md has no prompt companion
  ❌ Parity mismatch: .github/prompts/acp-bar.prompt.md has no opencode companion
  ```
- [ ] On pass: print `✅ Parity: 63 commands × 3 surfaces — all matched`

---

## Route-039 — Add 9 taxonomy entries + getSkillFile() mapping (ROUTING-001 + ROUTING-002)

**Finding ROUTING-001**: `agent/routing/taxonomy.yml` has 16 entries. Nine task types that occur regularly in sessions history are absent, causing Persona B/C dispatch to fall back to wrong executor and skill context.  
**Finding ROUTING-002**: `getSkillFile()` in `scripts/acp-dispatch.ts` has no explicit mapping for 7 of the 9 missing types — they silently fall through to `crosscut.md`.

### ROUTING-001 — 9 new taxonomy entries
Add the following 9 entries to `agent/routing/taxonomy.yml`:

| task_type | executor | skill | tokens_est | notes |
|-----------|----------|-------|-----------|-------|
| `wiki-update` | deepseek-v4-flash | crosscut | 4000 | Updates to agent/wiki/ files |
| `memory-write` | copilot | crosscut | 2000 | Writing to sessions.md, lessons.md, etc. |
| `changelog-update` | deepseek-v4-flash | crosscut | 2000 | CHANGELOG.md version entries |
| `progress-update` | deepseek-v4-flash | crosscut | 3000 | progress.yaml status updates |
| `adr-write` | copilot | crosscut | 3000 | Writing ADRs to decisions.md |
| `audit-run` | copilot | crosscut | 8000 | Running /acp-audit against a milestone |
| `milestone-create` | copilot | crosscut | 5000 | Creating milestone documents |
| `route-create` | copilot | crosscut | 3000 | Creating routing task files |
| `upstream-parity-check` | deepseek-v4-flash | crosscut | 6000 | Checking upstream fork divergence |

- [ ] Each entry includes: `task_type`, `description`, `executor`, `model`, `context_required`, `skill`, `tokens_est`, `complexity`
- [ ] Follow existing taxonomy.yml entry format exactly
- [ ] Add `last_updated: 2026-05-11` to taxonomy.yml header block (prerequisite for ROUTING-003)

### ROUTING-002 — getSkillFile() explicit mapping
- [ ] In `scripts/acp-dispatch.ts`, locate `getSkillFile()` function
- [ ] Add the 9 new task types to the crosscut mapping (since all 9 map to `crosscut.md`):
  ```typescript
  const crosscutTypes = [
    'wiki-update', 'memory-write', 'changelog-update', 'progress-update',
    'adr-write', 'audit-run', 'milestone-create', 'route-create',
    'upstream-parity-check', 'documentation-sync', 'crosscut'
  ];
  if (crosscutTypes.includes(taskType)) return 'agent/skills/crosscut.md';
  ```
- [ ] Ensure existing explicit mappings (bash-scripting → scripts.md, typescript-feature → typescript.md, etc.) are preserved
- [ ] Verify: unknown task_type still falls through to default (crosscut.md or error)

---

## Route-040 — Add lessons.md archive mechanism + update getFilteredLessons() (MEMORY-001)

**Finding**: `lessons.md` has no expiry or archive mechanism. Lessons with `priority: high` are loaded on every task type, forever — including the TikrFlow overflow postmortem which is now redundant (its fix is codified in `constraints.yml` as `context_overflow_commit_first`).

- [ ] Add `status:` field to lessons.md schema documentation (in comments at top of file):
  - Values: `active` (default if absent) | `archived` (skip on load)
  - Optional `superseded_by:` field: reference to constraint, pattern, or newer lesson ID
- [ ] Mark the TikrFlow overflow lesson as `status: archived, superseded_by: "constraints.yml:context_overflow_commit_first"`
- [ ] Update `getFilteredLessons()` in `scripts/acp-dispatch.ts`:
  - Skip entries where `status: archived` (or where `status` key exists and is not `active`)
  - Entries with no `status:` field continue to load as before (backward compatible)
- [ ] Do NOT add `status:` to existing active lessons — only to lessons being archived
- [ ] Verify: active lessons still load correctly; archived lessons do not appear in dispatch context

---

## Route-041 — taxonomy.yml last_updated + checkStaleness() in acp-validate.ts (ROUTING-003)

**Finding**: `taxonomy.yml` header has a comment-only date (`# Generated 2026-05-01`), not a parseable YAML field. `acp-validate.ts` has no staleness check. `config.yml` got `last_verified` in route-034 but taxonomy.yml was missed.

- [ ] Add parseable `last_updated:` field to `agent/routing/taxonomy.yml` header block:
  ```yaml
  # ACP Routing Taxonomy
  last_updated: 2026-05-11    # Update whenever task types are added or changed
  version: 1.1.0
  ```
  (Note: route-039 also touches this file — coordinate to avoid double-edit. Route-039 adds the field, route-041 adds the validate check.)
- [ ] Add `checkStaleness()` function to `scripts/acp-validate.ts`:
  - Read `last_updated:` from `taxonomy.yml`
  - Read `last_verified:` from each model in `config.yml`
  - If `last_updated` > 90 days ago: `⚠️ taxonomy.yml: last_updated is [N] days ago — verify task types are current`
  - If any `last_verified` > 180 days ago: `⚠️ routing/config.yml: [model] last_verified [N] days ago — check pricing`
- [ ] Call `checkStaleness()` from no-args validate path
- [ ] Handle date parse errors gracefully (warn, do not crash)

**Coordination note**: Route-039 adds `last_updated: 2026-05-11` to taxonomy.yml header. Route-041 adds the validate check that reads it. Implement in order (036 → 037 → 038 → 039 → 040 → **041**).

---

## Route-042 — Move FINAL-REVIEW.md + M42 wrap-up (STRUCT-003)

**Finding**: `scripts/FINAL-REVIEW.md` contains a detailed UX analysis of ACP workflow but lives in `scripts/`, which is outside the `agent/` tree. The context-loading protocol never reaches it.

### STRUCT-003 — File move
- [ ] Move `scripts/FINAL-REVIEW.md` → `agent/design/acp-ux-review.md`
- [ ] Update `agent/wiki/domain.yml` design section: add entry for `acp-ux-review.md`
- [ ] Search for any README.md or QUICKSTART.md links to `scripts/FINAL-REVIEW.md` and update paths
- [ ] Verify `scripts/FINAL-REVIEW.md` no longer exists after move

### M42 wrap-up
- [ ] Bump version 6.7.0 → 6.8.0 (identity.yml, package.yaml, AGENT.md)
- [ ] Write `CHANGELOG.md` entry for `[6.8.0] - YYYY-MM-DD` covering all 7 routes
- [ ] Update `agent/progress.yaml`: M42 status → completed, progress → 100%, tasks_completed → 7/7
- [ ] Update `current_milestone: M42-complete`
- [ ] Add `next_steps` entry: `✅ M42 DONE: dispatch integrity + validation hardening (routes 036-042, v6.8.0)`
- [ ] Stamp all route files 036–042: `completed: [date]`
- [ ] Write `agent/memory/sessions.md` M42 session entry
- [ ] Update `audit-carryovers.md`: mark all 9 audit-015 entries as `status: fixed`

---

## Success Criteria

All 9 audit-015 pending findings resolved:

| Finding | Success Check |
|---------|--------------|
| BUG-003 | `updateRoutingYml()` is AFTER `appendLedger()` in dispatch.ts; SIGINT exits cleanly with no routing.yml mutation |
| MEMORY-002 | `/acp-validate` catches the BUG-001 pattern (malformed sessions.md entry) |
| VALIDATE-001 | `/acp-validate` fails if AGENTS.md exceeds 15KB |
| VALIDATE-002 | `/acp-validate --parity` prints missing filenames, not just counts |
| ROUTING-001 | `taxonomy.yml` has 25 entries (16 + 9 new); all 9 new types correctly routed |
| ROUTING-002 | `getSkillFile()` has explicit `crosscutTypes` array — no silent fallthrough |
| ROUTING-003 | `taxonomy.yml` has parseable `last_updated:`; `/acp-validate` warns on staleness |
| MEMORY-001 | `getFilteredLessons()` skips archived lessons; TikrFlow lesson archived |
| STRUCT-003 | `agent/design/acp-ux-review.md` exists; `scripts/FINAL-REVIEW.md` deleted |
