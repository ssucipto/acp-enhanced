# Audit Report: Taxonomy Improvement Suggestions (Cost Report Step 5)

**Audit**: #017  
**Date**: 2026-05-12  
**Subject**: Evaluate the 3 taxonomy improvement suggestions from the `/acp-cost-report` output — determine whether each is warranted, already handled, or incorrect. Surface any genuine taxonomy gaps.

---

## Summary

All 3 suggestions from the cost report contained inaccuracies — two were redundant (the system already addresses them) and one was correct in direction but wrong in root cause. Investigation also uncovered **one genuine taxonomy gap** not identified in the cost report: `shell-scripting` is used in 2 route files but is completely absent from `taxonomy.yml`, meaning those routes silently fall back to `claude-sonnet` (the most expensive model) when dispatched.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/routing/taxonomy.yml` | config | 25 task types — full structure, all `tokens_est` values |
| `agent/routing/config.yml` | config | 5 model entries, pricing, `last_verified` dates |
| `agent/routing/ledger.md` | data | 8 ledger rows — all with blank token/cost fields |
| `scripts/acp-dispatch.ts:176-295` | source | `appendLedger()`, token capture from stream, SIGINT handler |
| `agent/routing/tasks/route-005.md` | route | `task_type: shell-scripting` — missing from taxonomy |
| `agent/routing/tasks/route-011.md` | route | `task_type: shell-scripting` — missing from taxonomy |
| `agent/routing/tasks/route-014..021.md` | routes | The 8 ledger entries — yaml-schema + command-doc-update |
| `agent/routing/tasks/route-024..027.md` | routes | `command-doc-write` creates — 8000 tokens_est each |
| `agent/routing/rules.md` | config | Routing decision rules |

---

## Key Findings

| ID | Finding | Severity | Location |
|----|---------|----------|---------|
| GAP-001 | `shell-scripting` task type used in 2 routes but not in taxonomy.yml — fallback to claude-sonnet | High | `route-005.md`, `route-011.md` |
| CORR-001 | Cost report Suggestion 1 was wrong — all 9 M42 types already have tokens_est values in taxonomy.yml | Info | `taxonomy.yml:104-160` |
| CORR-002 | Cost report Suggestion 2 was wrong — command-doc-write / command-doc-update split already exists | Info | `taxonomy.yml:10-30` |
| CORR-003 | Cost report Suggestion 3 partially wrong — write-back code is correct; real cause is copilot executor tasks never flow through dispatch.ts | Info | `acp-dispatch.ts:268-272` |
| OBS-001 | 5 of 8 ledger entry types use `executor: copilot` — these will always have blank token/cost data (architectural) | Low | `ledger.md` |
| OBS-002 | Route-019 (`command-doc-update`, tokens_est: 6000) added substantial new protocol (~40 lines) — closer to command-doc-write scope | Low | `route-019.md` |

---

## Suggestion-by-Suggestion Verdict

### Suggestion 1 — "Add tokens_est calibration for the 9 M42 task types"

**Verdict: ❌ Not needed — already done**

All 9 M42 task types have `tokens_est` values in `taxonomy.yml`:

| Task Type | tokens_est | executor |
|-----------|-----------|----------|
| wiki-update | 4,000 | deepseek-v4-flash |
| memory-write | 2,000 | copilot |
| changelog-update | 2,000 | deepseek-v4-flash |
| progress-update | 3,000 | deepseek-v4-flash |
| adr-write | 3,000 | copilot |
| audit-run | 8,000 | copilot |
| milestone-create | 5,000 | copilot |
| route-create | 3,000 | copilot |
| upstream-parity-check | 6,000 | deepseek-v4-flash |

The cost report was generated before fully reading `taxonomy.yml`. The estimates are present and fall within `complexity_thresholds` bands in `config.yml`. **No action needed.**

---

### Suggestion 2 — "Split command-doc-update into command-doc-create vs command-doc-update"

**Verdict: ❌ Not needed — the split already exists**

Two distinct types are already in taxonomy:

| Type | executor | tokens_est | Use case |
|------|----------|-----------|---------|
| `command-doc-write` | deepseek-v4-pro | 8,000 | Write a new command doc from scratch |
| `command-doc-update` | deepseek-v4-flash | 3,000 | Update an existing command doc |

Routes 024–027 (M41a — new command docs) correctly used `command-doc-write`. Routes 015–017 and 019–021 (M39/M40 — doc updates) correctly used `command-doc-update`. The routing is working as designed. **No new type needed.**

Minor observation: route-019 ("Add --pre-impl mode to acp.audit.md") was `command-doc-update` but involved ~40 lines of new protocol and a manually-bumped `tokens_est: 6000`. Tasks adding large new sections (>20 lines of new protocol behaviour) could reasonably use `command-doc-write` instead.

---

### Suggestion 3 — "Enable actual token write-back before taxonomy tuning is meaningful"

**Verdict: ⚠️ Correct direction, wrong root cause**

`acp-dispatch.ts` correctly captures token usage at lines 268-272 (`chunk.usage.prompt_tokens`/`chunk.usage.completion_tokens`) and writes to the ledger at line 286. The code is not broken.

**Real reason all 8 ledger rows are blank:**

1. **5 of 8 task types** in the ledger have `executor: copilot` — these run inside VS Code Copilot which has no mechanism to write back to `ledger.md`. The ledger rows were created as stubs, not from actual dispatch runs.

2. **The remaining rows** (deepseek-v4-flash types) either ran without `OPENROUTER_API_KEY` or were interrupted — the SIGINT handler writes `appendLedger(meta, 0, 0, 0)` (zeroed row), which matches the blank pattern.

**What actually needs to happen:**
- Accept that `executor: copilot` tasks will never populate token data — add a documentation note
- For deepseek-v4-flash/pro routes: run `(cd scripts && npx ts-node acp-dispatch.ts agent/routing/tasks/route-NNN.md)` with `OPENROUTER_API_KEY` set in env

---

## Hidden Finding: Genuine Taxonomy Gap

### GAP-001 — `shell-scripting` not in taxonomy.yml

| Route | Title | tokens_est | Correct type |
|-------|-------|-----------|-------------|
| route-005 | Auto-migrate legacy .agent/ on install/update | 800 | `bash-script-create` |
| route-011 | Fix 12 pre-existing e2e test failures (investigation + fixes) | 8,000 | `bash-script-fix` |

`shell-scripting` is absent from `taxonomy.yml`. When `acp-dispatch.ts` looks up the executor for an unknown type, it defaults to `config.yml → default_model` which is `claude-sonnet` — the most expensive model ($3.00/M input, $15.00/M output). For route-005 and route-011 this means potential 10–20× cost overrun vs the correct `deepseek-v4-flash` executor.

Fix: add `shell-scripting` as an alias entry or update both route files to use `bash-script-fix`/`bash-script-create`.

---

## Task Type Usage Across All 43 Routes

| Task Type | Count | In Taxonomy? |
|-----------|-------|-------------|
| command-doc-update | 8 | ✅ |
| typescript-feature | 6 | ✅ |
| documentation-sync | 6 | ✅ |
| yaml-schema | 5 | ✅ |
| bash-script-fix | 5 | ✅ |
| command-doc-write | 4 | ✅ |
| **shell-scripting** | **2** | **❌ MISSING** |
| design-document | 2 | ✅ |
| bash-script-refactor | 2 | ✅ |
| 9 M42 types | 1 each | ✅ |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/routing/taxonomy.yml:10-22` | `command-doc-write` (deepseek-v4-pro, 8000) — create type |
| `agent/routing/taxonomy.yml:24-30` | `command-doc-update` (deepseek-v4-flash, 3000) — update type |
| `agent/routing/taxonomy.yml:104-160` | All 9 M42 task types with tokens_est ✅ |
| `agent/routing/config.yml:6` | `default_model: claude-sonnet` — fallback for unknown task types |
| `scripts/acp-dispatch.ts:268-272` | `chunk.usage` token capture — write-back is implemented correctly |
| `scripts/acp-dispatch.ts:245-250` | SIGINT handler writes `appendLedger(meta, 0, 0, 0)` — explains blank rows |
| `agent/routing/tasks/route-005.md` | `task_type: shell-scripting` — unmapped type |
| `agent/routing/tasks/route-011.md` | `task_type: shell-scripting` — unmapped type |

---

## Git History (relevant)

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-11 | `91560c4` | feat(M42): adds 9 new task types to taxonomy.yml |
| 2026-05-11 | `0892bd9` | docs(audit-016): README/validate doc updates |

---

## Recommendations

| # | Action | Priority | Effort |
|---|--------|----------|--------|
| R1 | Fix GAP-001: add `shell-scripting` to `taxonomy.yml` (alias → `bash-script-fix`) or update route-005 + route-011 to correct existing types | **High** | 5–10 min |
| R2 | Add a comment in `ledger.md` header: "`executor: copilot` rows always have blank token/cost — Copilot doesn't expose usage via the ledger mechanism" | Low | 2 min |
| R3 | Add to `routing/rules.md`: tasks adding >20 lines of new protocol to an existing command doc should use `command-doc-write`, not `command-doc-update` | Low | 5 min |
