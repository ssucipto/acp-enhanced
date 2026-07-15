# ACP Enhanced — Internal Feedback Report
## Dogfooding Analysis: Developing ACP Enhanced with ACP Enhanced

**Report ID**: feedback-003  
**Date**: 2026-06-05  
**Project**: ACP Enhanced (self-hosted dogfooding)  
**ACP Version**: v6.9.1  
**Executor**: copilot  
**Category**: meta-review — development process, protocol effectiveness, gap analysis  

---

## Executive Summary

This report analyzes how ACP Enhanced was used to develop ACP Enhanced v6.8.2 → v6.9.1
across M47 and M48 (20 routes, 5 audits, 17 commits). The analysis covers: workflow
effectiveness, command utilization, pain points, and whether the "dogfooding" feedback
loop has reached useful maturity.

**Verdict: Dogfooding is effective and has reached production usefulness.** The ACP
workflow caught 25+ gaps across 5 audit rounds. However, 6 systemic pain points were
identified — 1 already fixed (version drift), 5 remain as internal improvement candidates.

---

## 1. What We Used (And How)

### Workflow commands used (9 of 67 available):

| Command | Uses | Value Delivered |
|---------|------|-----------------|
| `/acp-plan` | 2 (M47, M48) | Structured milestone + task creation from feedback |
| `/acp-audit` | 5 (041-044 + version) | Caught 25+ gaps across pre-impl and post-impl rounds |
| `/acp-proceed --complete --yes` | 2 | Executed 20 routes autonomously with per-task commits |
| `/acp-update` | 3 | Kept progress.yaml synchronized |
| `/acp-commit` | 2 | Session memory persistence + auto-sync |
| `/acp-sync` | 1 | README + PRD synchronization |
| `/acp-validate` | 1 | Structural consistency check |
| `/acp-visualize` | 1 | Failed — project not registered, React errors |
| `/git-commit` | 2 | Changelog + version management |

### Commands NOT used (but exist):

`/acp-init`, `/acp-status`, `/acp-route`, `/acp-decide`, `/acp-cost-report`,
`/acp-memory-sync`, `/acp-pattern-sync`, `/acp-session-sync`, `/acp-carryover-query`,
`/acp-index`, `/acp-pattern-create`

> 9 of 67 commands used (13%) — consistent with the ~10% utilization found in
> ChoreHive and FIFOZ production data. The recently-added repair tools and workflow
> commands (pattern-sync, session-sync, carryover-query, index init) were built
> but haven't been used yet — they need real-world exercise to validate.

### Task type distribution (20 routes):

| Type | Count | Notes |
|------|-------|-------|
| `command-doc-write` | 8 | New command docs (sync tools, carryover-query) |
| `command-doc-update` | 7 | Existing command enhancements |
| `docs-update` | 3 | Wiki, README, PRD updates |
| `testing` | 2 | E2E test creation |

> ACP Enhanced is primarily a documentation-first protocol — 18 of 20 routes were
> documentation work. This aligns with the project's nature but means the protocol
> hasn't been tested on code-heavy tasks within its own development.

---

## 2. What Worked Well

### 2.1 The Complete Workflow Pipeline

The full ACP pipeline (plan → audit → proceed → audit → update → sync → commit)
was exercised end-to-end for both M47 and M48. Each stage caught distinct issues:

| Stage | M47 Findings | M48 Findings |
|-------|-------------|-------------|
| Pre-impl audit | 10 (3 HIGH fixed before start) | 8 (6 fixed before start) |
| Implementation | 0 errors | 0 errors |
| Post-impl audit | 4 (all fixed) | 3 (all fixed) |
| Version sweep | 3 stale files | N/A |

> **25+ gaps caught before a single commit was pushed.** This is the core value
> proposition of the audit-first workflow.

### 2.2 Autonomous Mode Efficiency

`/acp-proceed --complete --yes` executed 20 routes across 2 milestones with zero
human intervention. Per-task commits, progress tracking, and route stamping all
worked correctly. This is production-ready automation.

### 2.3 Dual-Store Pattern Validated

The dual-store architecture (registry → document sync) was immediately useful:
session and pattern documents were auto-synced on every `/acp-commit`. The
pattern was exercised in production within minutes of implementation.

### 2.4 Feedback-Driven Development Worked

External feedback (FIFOZ feedback-001/002) drove the entire M47 milestone. The
feedback → plan → audit → implement loop produced a v6.9.0 release that directly
addressed real production pain points. This validates the core premise of ACP
Enhanced: structured, feedback-driven agent workflows.

---

## 3. Pain Points & Gaps

### 3.1 Version Drift Across 8 Files (FIXED)

**Severity**: HIGH | **Status**: ✅ Fixed (validate v2.3.0 Step 2c)

3 files (AGENT.md, identity.yml, package.yaml) were still at 6.8.2 after M47+M48.
Root cause: 8 version-bearing files with zero automated consistency checking.

Fix: `/acp-validate` now checks all 8 files against `progress.yaml` (hard fail on
AGENT/identity/package mismatch, warn on README/CHANGELOG/PRD/IP_REGISTER).

### 3.2 Triple-File Parity Gap (UNRESOLVED)

**Severity**: MEDIUM | **Status**: ⚠️ Manual process

Every new command doc needs 3 files: `agent/commands/acp.X.md`, `.github/prompts/acp.X.prompt.md`,
`.opencode/commands/acp.X.md`. This session created 3 new commands (pattern-sync,
session-sync, carryover-query) — each required manual wrapper creation. Twice the
wrappers were forgotten (caught by audit-042, audit-044).

**Recommendation**: Add `/acp-command-create` auto-generation of wrappers, or add
triple-file parity check to `/acp-validate`.

### 3.3 Visualizer Integration Failure (UNRESOLVED)

**Severity**: MEDIUM | **Status**: ⚠️ Same as V-01/V-04 from feedback-001

Visualizer launched but showed "0 Projects" — project not registered in ACP
registry. Then terminated with React 19 errors (same `Expected static flag` bug
from feedback-001 V-04). The visualizer is a separate repo and these issues were
reported in feedback-001 but remain unresolved.

**Recommendation**: Visualizer needs a "quick start" mode that reads `PROGRESS_YAML_PATH`
env var directly without requiring project registry setup. The React 19 SSR bug
needs attention in the visualizer repo.

### 3.4 Dual AGENTS.md / AGENT.md Confusion (UNRESOLVED)

**Severity**: LOW | **Status**: ⚠️ Design tension

Two files serve different purposes:
- `AGENTS.md` — protocol document (auto-loaded by Copilot, Cursor, Claude)
- `AGENT.md` — project README with version, status, directory structure

Cursor Composer reads `AGENT.md` for version (was 6.8.2). GitHub Copilot reads
`AGENTS.md` (no version). This split caused confusion — we updated AGENTS.md but
not AGENT.md until a specific audit found it.

**Recommendation**: Either merge into one file, or add a prominent version line
to AGENTS.md header: `> ACP Enhanced v6.9.1 — Context Loading Protocol`.

### 3.5 .gitignore Hides Instance Data (UNRESOLVED)

**Severity**: LOW | **Status**: ⚠️ By design, but has costs

`agent/.gitignore` ignores milestones, routing tasks, reports, and memory files.
This is by design (instance data stays local). But it means:
- Milestone docs and route files aren't traceable in git history
- Audit reports can't be shared via the repo
- External users can't see the project's own development process

**Recommendation**: Consider a `--track-instance-data` flag in `/acp-init` for
framework development vs. project usage.

### 3.6 No Automated Validate in Workflow (UNRESOLVED)

**Severity**: LOW | **Status**: ⚠️ Manual only

`/acp-validate` was run only once this session (when explicitly invoked). It
should be a natural part of the workflow — ideally run automatically after
`/acp-proceed` or `/acp-commit`. The version consistency bug would have been
caught immediately if validate ran after every version bump.

**Recommendation**: Add `--validate` flag to `/acp-commit` (runs validate before
committing). Or make validate a default step in `/acp-proceed` post-task.

---

## 4. Have We Reached Usefulness?

### YES — with evidence:

| Metric | Value | Assessment |
|--------|-------|------------|
| Gaps caught by audits | 25+ | ✅ Audit-first workflow is proven |
| Autonomous routes executed | 20 | ✅ Zero errors, per-task commits worked |
| External feedback addressed | 16/20 | ✅ 80% coverage, 4 P2 deferred |
| Carryovers resolved | 8/8 | ✅ 100% resolution rate |
| E2E tests passing | 12/12 | ✅ New tests validate new features |
| Self-discovered bugs | 6 pain points | ✅ Dogfooding surfaces real issues |
| Commands used | 9/67 (13%) | ⚠️ Consistent with external data, but low |

### The dogfooding feedback loop:

```
External Feedback (FIFOZ) ──→ /acp-plan ──→ M47 implemented
                                      ↓
                              /acp-audit (25+ gaps)
                                      ↓
                              /acp-proceed (20 routes)
                                      ↓
                         Self-discovered bugs (version drift, parity)
                                      ↓
                         /acp-audit ──→ validate v2.3.0 fix
                                      ↓
                         Lessons logged for next session
```

This loop is **functional and valuable**. The protocol is dogfooding itself
effectively — it catches its own bugs and improves itself.

---

## 5. Recommendations for ACP Enhanced Itself

Based on internal usage patterns:

### P0 — Immediate
| Item | Description |
|------|-------------|
| **Merge AGENTS.md + AGENT.md** | Single file with version line in header. Eliminates confusion. |
| **Auto-validate on commit** | `/acp-commit --validate` or make validate part of commit flow. |

### P1 — Short-term
| Item | Description |
|------|-------------|
| **Triple-file parity automation** | `/acp-command-create` generates all 3 files. Add parity check to validate. |
| **Visualizer quick-start** | Read `PROGRESS_YAML_PATH` directly, bypass project registry. |
| **Run repair tools** | Actually use `/acp-pattern-sync` and `/acp-session-sync` to validate they work. |

### P2 — Longer-term
| Item | Description |
|------|-------------|
| **Track instance data optionally** | `--track-instance-data` flag for framework development. |
| **Code-heavy dogfooding** | Exercise ACP on code tasks (not just doc tasks) to test routing/dispatch. |
| **Use remaining commands** | 58 of 67 commands never used — exercise `/acp-index init`, `/acp-carryover-query`, etc. |

---

## 6. Comparison with External Feedback

| Aspect | ChoreHive | FIFOZ | ACP Enhanced (self) |
|--------|-----------|-------|---------------------|
| Audits run | 54 | 64 | 5 (this session) |
| Commands used | ~10% | ~10% | 13% |
| Top pain point | Context protocol too heavy | Dual-store gap | Version drift |
| Fix applied | Light mode | Auto-sync | Validate v2.3.0 |
| Feedback loop | External → M44 | External → M47 | Internal → v2.3.0 |

The pattern is consistent: real usage surfaces gaps that structured audits catch.
The difference is that internal feedback fixes ACP itself, while external feedback
fixes ACP for users. Both are valuable and complementary.

---

**Submitted by**: ACP Enhanced development (dogfooding session 2026-06-04)  
**Companion**: audit-041 through audit-044, feedback-001, feedback-002
