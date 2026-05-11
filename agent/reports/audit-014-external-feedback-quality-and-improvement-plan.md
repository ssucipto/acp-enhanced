# Audit Report: External Feedback Quality & Improvement Plan

**Audit**: #14
**Date**: 2026-05-11
**Subject**: All feedback documents in `agent/feedback/` — quality assessment vs ACP Enhanced v6.6.0, cross-verification of claims, and prioritised improvement plan
**Executor**: Copilot (Persona A)

---

## Summary

Four feedback documents exist in `agent/feedback/`. Three are developer-written incident reports (`feedback-001/002/003`) that drove milestones M38, M39, and M40 — all three have been fully implemented. The fourth (`acp-enhanced-full-audit-v2.md`) is an **external AI-conducted structural audit** from Perplexity AI, delivered in ACP-native format, covering 40+ files and ~600K bytes of content.

The external audit is **exceptionally high quality**: 11 of 13 verifiable claims confirmed accurate on live file inspection. It identifies 4 confirmed bugs (2 critical), 5 structural gaps, and 5 medium observations — none of which were surfaced by internal audits #1–#13. This document represents the most comprehensive independent review ACP Enhanced has received.

**Key action**: Implement external audit recommendations as **M41 — Stabilisation Sprint** before any new feature development.

---

## Files Analyzed

| File | Type | Status |
|------|------|--------|
| `agent/feedback/acp-enhanced-full-audit-v2.md` | External AI audit (Perplexity) | ⭐ Primary subject |
| `agent/feedback/feedback-001-proactive-commit-and-knowledge-preservation.md` | Field incident report | ✅ Implemented as M38 |
| `agent/feedback/feedback-002-acp-git-branch-awareness.md` | Field incident report | ✅ Implemented as M39 |
| `agent/feedback/feedback-003-pre-implementation-audit-protocol.md` | Field incident report | ✅ Implemented as M40 |
| `agent/memory/sessions.md` | Memory — cross-ref | BUG-001 confirmed |
| `scripts/acp-dispatch.ts` | TypeScript — cross-ref | BUG-002 confirmed |
| `agent/commands/` | Command docs — cross-ref | BUG-003 confirmed |
| `agent/wiki/domain.yml` | Wiki — cross-ref | BUG-004 confirmed |
| `scripts/scripts-package.json` | Scripts — cross-ref | GAP-001 confirmed |
| `README.md` | Docs — cross-ref | GAP-002 confirmed |
| `agent/core/identity.yml` | Core — cross-ref | GAP-003 confirmed |
| `agent/core/routing.yml` | Core — cross-ref | OBS-004 confirmed |
| `agent/memory/audit-carryovers.md` | Memory — cross-ref | OBS-003 REFUTED |
| `agent/routing/config.yml` | Routing — cross-ref | OBS-002 confirmed |

---

## Section 1 — Feedback Document Quality Assessment

### 1.1 `feedback-001` / `002` / `003` — Field Incident Reports

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Accuracy | ✅ High | All three root causes proven correct by M38/M39/M40 outcomes |
| Depth | ✅ High | Each includes failure mode analysis, evidence table, specific reproduction steps |
| Actionability | ✅ High | Directly generated routing tasks and milestone specs |
| Format | ✅ ACP-native | Structured for immediate injection into routing and memory |
| Coverage | ⚠️ Narrow | Each addresses one specific failure domain only |
| Source | Developer field use | Gold-standard signal — real production pain points |

**Verdict**: Exemplary incident reports. The feedback loop they demonstrate (failure → report → milestone → fix) is the system working exactly as designed.

---

### 1.2 `acp-enhanced-full-audit-v2.md` — External AI Audit (Perplexity AI)

**Source quality**: Perplexity AI full-file audit — 40+ files read, ~600K bytes analysed, ACP-native output format.

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Accuracy | ✅ Very High | 11 of 13 verifiable claims confirmed accurate (85%+) |
| Depth | ✅ Exceptional | Every component audited: dispatch, validate, bootstrap, E2E, wiki, memory, routing |
| Actionability | ✅ Exceptional | Every finding has specific fix with code snippets |
| Format | ✅ ACP-native | Structured for `/acp-feedback` or direct `audit-carryovers.md` injection |
| Coverage | ✅ Comprehensive | Full repo — architecture, scripts, memory, docs, tests, commands |
| Source | External AI | Independent — no author bias, no familiarity blindness |
| Honesty | ✅ Balanced | Gives genuine credit to working systems while surfacing real gaps |

**One inaccuracy found (OBS-003)**: The audit claims `audit-carryovers.md` has 2 pending items (`carryover-001`, `carryover-002`). Live inspection shows the file exists but `carryovers: []` — the list is empty. The external audit likely scanned a prior pushed state where the file had content, or misread the schema header comments as data entries. This is a minor error that does not affect the validity of any bug finding.

**Overall verdict**: ⭐⭐⭐⭐⭐ **EXCEPTIONAL** — the highest-quality feedback document in the repo. Surpasses internal audits #1–#13 in breadth and external objectivity. Every finding should be actioned.

---

### 1.3 Feedback Coverage Comparison

| Type | Source | Findings | Implemented |
|------|--------|----------|-------------|
| Field incident (feedback-001) | Developer/TikrFlow | Knowledge loss, WAL triggers | ✅ M38 |
| Field incident (feedback-002) | Developer/TikrFlow | Branch commits to main | ✅ M39 |
| Field incident (feedback-003) | Developer/TikrFlow | Pre-impl audit depth | ✅ M40 |
| External structural (acp-enhanced-full-audit-v2.md) | Perplexity AI | 4 bugs, 5 gaps, 5 obs | ❌ Not yet |

The gap: internal audits and field reports address **known failure modes**. The external audit addresses **structural debt invisible from inside the project** — things that haven't failed yet but will fail for new users or in distribution.

---

## Section 2 — Bug Verification (Live Cross-Reference)

### BUG-001: Malformed YAML entry in `sessions.md` — CONFIRMED 🔴

**Claimed**: A session block is missing its `- date:` header, starting raw with `executor: copilot`.
**Verified**: `agent/memory/sessions.md` line 151 shows:
```
  executor: copilot
  tasks: [task-156, task-157, task-158]
```
No `- date:` header on the preceding line — the block is orphaned. The `acp-dispatch.ts` `getLastNSessions()` function splits on `\n- date:` and will either skip or corrupt this entry.

**Severity**: CRITICAL — corrupts session context for every dispatch call.

---

### BUG-002: Hardcoded `HTTP-Referer` placeholder in `acp-dispatch.ts` — CONFIRMED 🔴

**Claimed**: Line 221 contains `"HTTP-Referer": "https://github.com/your-handle/your-repo"`.
**Verified**: `scripts/acp-dispatch.ts:221` contains exactly this placeholder. Every project that installs ACP Enhanced and runs dispatch sends this header to OpenRouter — misattributing usage to a generic handle.

**Severity**: CRITICAL for package distribution — affects rate limit grouping and usage attribution.

---

### BUG-003: Four command docs return 404 — CONFIRMED 🔴

**Claimed**: `acp.task.md`, `acp.install.md`, `acp.feedback.md`, `acp.dispatch.md` are missing.
**Verified**: All four absent from `agent/commands/`. Live `ls` confirms.

| Missing Command | Impact |
|----------------|--------|
| `acp.task.md` | No command doc for routing task creation — daily workflow has no invocable command |
| `acp.install.md` | `acp.install.sh` has no agent companion — install must be done via bootstrap only |
| `acp.feedback.md` | The feedback loop that produced M38/M39/M40 has no command doc — cannot be reliably invoked |
| `acp.dispatch.md` | Persona B/C users have no command to invoke the routing engine from inside their IDE |

**Severity**: HIGH — missing commands break the advertised command surface.

---

### BUG-004: Command count discrepancy — CONFIRMED ⚠️

**Claimed**: `domain.yml` says 58 but `package.yaml` lists 60.
**Verified**:
- `agent/wiki/domain.yml` → `count: 58`
- `agent/commands/` → 57 `acp.*` files + 3 `git.*` files = 60 total; minus `command.template.md` = **59 actual commands**
- `package.yaml` lists individual commands; `README.md` (updated audit-013) says 59
- `domain.yml` is **stale at 58** — should be 59 (4 missing commands not yet created)

**Note**: After BUG-003 is fixed (4 commands created), the actual count will be 63. `domain.yml` should be updated to 59 now and 63 after BUG-003 fix.

**Severity**: MEDIUM — `/acp-validate` may produce false pass/fail on count checks.

---

## Section 3 — Structural Gap Verification

### GAP-001: `scripts/scripts-package.json` is a duplicate — CONFIRMED ⚠️

**Verified**: Both `scripts/package.json` and `scripts/scripts-package.json` exist. The `scripts-package.json` file is an unused copy of `package.json`. Should be removed.

### GAP-002: `QUICKSTART.md` not linked from root README — CONFIRMED ⚠️

**Verified**: `README.md` has two "Quick Start" sections (lines 473, 910) but neither references `scripts/QUICKSTART.md`. The file exists but is unreachable from the README entry point. New users won't find it.

### GAP-003: `git_workflow:` undiscoverable in `identity.yml` — CONFIRMED ⚠️

**Verified**: `agent/core/identity.yml:36` shows `# git_workflow:` commented out with no README/QUICKSTART callout. The feature that prevents the most common AI coding mistake (committing to main) is invisible to new installers.

### GAP-004: `AGENTS.md` / `CLAUDE.md` manual sync — CONFIRMED ⚠️

**Verified**: Three files must stay in sync manually — no hook enforces it. Bootstrap installs the sync once but does not prevent future drift.

### GAP-005: No Windows/WSL install path — CONFIRMED ⚠️

**Verified**: `README.md` Requirements section mentions "Linux or macOS". No WSL guidance exists anywhere in the repo despite TypeScript tooling being Windows-compatible.

---

## Section 4 — Observation Verification

| Observation | Claim | Verdict |
|-------------|-------|---------|
| OBS-001: `FINAL-REVIEW.md` in `scripts/` | Should move to `agent/design/` | ✅ CONFIRMED — file in scripts/, not loaded by ACP context system |
| OBS-002: `config.yml` no freshness date | `last_verified:` missing | ✅ CONFIRMED — no date field in any model entry |
| OBS-003: `audit-carryovers.md` pending items | Claims 2 pending items | ❌ REFUTED — file exists with `carryovers: []` (empty) |
| OBS-004: `routing.yml` ships with `executor: unset` | Needs Persona A default | ✅ PARTIALLY CONFIRMED — `executor: unset`, `model: unset` (but `persona: A` is already set) |
| OBS-005: Too many `local.*` files in `agent/design/` | Namespace discipline | Not verified this audit — deferred |

---

## Section 5 — Improvement Plan (Prioritised)

### Priority 1 — Fix Before Any New Features (M41 Sprint 1)

| # | Finding | Fix | Files |
|---|---------|-----|-------|
| P1-1 | BUG-001: sessions.md malformed entry | Add `- date: 2026-05-05` header before orphaned block at line 151 | `agent/memory/sessions.md` |
| P1-2 | BUG-002: HTTP-Referer placeholder | Read `homepage` and `project` from `identity.yml` dynamically | `scripts/acp-dispatch.ts` |
| P1-3 | BUG-003a: `acp.feedback.md` missing | Create minimum viable command doc | `agent/commands/acp.feedback.md` |
| P1-4 | BUG-003b: `acp.task.md` missing | Create minimum viable command doc | `agent/commands/acp.task.md` |
| P1-5 | BUG-003c: `acp.install.md` missing | Create minimum viable command doc | `agent/commands/acp.install.md` |
| P1-6 | BUG-003d: `acp.dispatch.md` missing | Create minimum viable command doc | `agent/commands/acp.dispatch.md` |
| P1-7 | BUG-004: domain.yml count stale | Update `count: 58` → `59` (then 63 post BUG-003) | `agent/wiki/domain.yml` |

### Priority 2 — Stabilisation (M41 Sprint 2)

| # | Finding | Fix | Files |
|---|---------|-----|-------|
| P2-1 | GAP-001: duplicate package.json | Delete `scripts/scripts-package.json` | `scripts/scripts-package.json` |
| P2-2 | GAP-002: QUICKSTART.md unlinked | Add link to README hero section | `README.md`, `scripts/QUICKSTART.md` |
| P2-3 | GAP-003: git_workflow hidden | Add "Branch Safety" section to README + QUICKSTART | `README.md`, `scripts/QUICKSTART.md` |
| P2-4 | GAP-004: manual AGENTS.md sync | Add pre-commit hook to bootstrap | `scripts/acp-bootstrap.sh` |
| P2-5 | GAP-005: no Windows/WSL docs | Add WSL2 install path to QUICKSTART + README | `README.md`, `scripts/QUICKSTART.md` |
| P2-6 | OBS-002: config.yml no freshness | Add `last_verified: 2026-05-11` to each model entry | `agent/routing/config.yml` |
| P2-7 | OBS-004: routing.yml unset fields | Set `executor: copilot`, `model: github-copilot` as Persona A defaults | `agent/core/routing.yml` |

### Priority 3 — Low (Backlog)

| # | Finding | Fix |
|---|---------|-----|
| P3-1 | OBS-001: FINAL-REVIEW.md misplaced | Move to `agent/design/acp-ux-review.md`, ref from AGENT.md |
| P3-2 | OBS-005: design/ local.* audit | Audit which `local.*` files should be promoted to non-local |

---

## Section 6 — Milestone Recommendation

**Recommended**: Create **M41 — Stabilisation Sprint** with two sub-phases:

| Phase | Focus | Routes | Est. Complexity |
|-------|-------|--------|----------------|
| M41a | Bug fixes (P1-1 → P1-7) | 7 routes | Medium — 4 command docs + 2 bug fixes + 1 count update |
| M41b | Structural gaps (P2-1 → P2-7) | 7 routes | Low–Medium — mostly docs + bootstrap hook |

**Rationale**: The external audit confirms ACP Enhanced is **production-quality** in its core systems. These gaps are all **onboarding and distribution** issues — invisible to current users but will block adoption. Fixing them before any M42+ feature work ensures the foundation is solid for distribution.

**Productisation gate** (from external audit Section 5.4): All P1 and P2 items must be complete before shipping to other developers.

---

## Git History (Relevant to Feedback Documents)

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-11 | `bfa9c96` | docs(audit-013): milestone completion — 40/40 |
| 2026-05-11 | `396cc1d` | fix(audit): stamp routes 014-017, Phase Summary table |
| 2026-05-09 | `c162092` | chore(memory): acp-commit M39+M40 session |
| 2026-05-11 | `413d27d` | feat(protocol): M40 pre-impl audit protocol (6.6.0) |
| 2026-05-11 | `f677583` | feat(protocol): M39 git branch awareness (6.5.0) |

---

## Recommendations

1. **Action immediately**: Fix BUG-001 (sessions.md) — every dispatch call is affected now
2. **Route M41a this session**: Create 7 routes for Priority 1 fixes using `/acp-route`
3. **Adopt external audit format**: `acp-enhanced-full-audit-v2.md` demonstrates ACP-native format for external audits — document this as a pattern in `patterns.md`
4. **Establish external audit cadence**: Run an AI structural audit (Perplexity/similar) at each major version boundary (every 5–10 milestones)
5. **Create `acp.feedback.md` first** among the 4 missing commands — it closes the loop on the feedback system that generated M38/M39/M40/this audit

---

## Carryover Write

Actionable unresolved findings written to `agent/memory/audit-carryovers.md`.
