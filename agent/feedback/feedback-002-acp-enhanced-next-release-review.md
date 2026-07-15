# ACP Enhanced — Field Feedback Report
## Submission: FIFOZ production usage review — v6.9 release recommendations

**Report ID**: feedback-002  
**Date**: 2026-06-03  
**Project**: FIFOZ (Rygan-Institute/FIFOZ, React Native / FastAPI / Firestore)  
**ACP Version in use**: 6.8.2  
**Executor**: cursor  
**Category**: improvement — framework UX, validation, release planning  
**Severity**: medium  
**Companion**: audit-065, feedback-001  

**Submit to**: `https://github.com/ssucipto/acp-enhanced/issues`  
**Visualizer items**: separate issues on `agent-context-protocol-visualizer`

---

## Executive Summary

FIFOZ is a **heavy production user** of ACP Enhanced: 64 audits, 14 milestones, 122 tasks,
36 patterns, 10 session commits, daily Cursor + light-mode workflow since May 2026. The framework
is **essential to project velocity** — we would not run milestone-scale work without `/acp-audit`,
`/acp-plan`, `progress.yaml`, and session memory.

This report consolidates **what we use**, **what delivers value**, **bugs and gaps found** (including
the pattern/visualizer incident in feedback-001), and a **prioritized v6.9 backlog** for the
ACP Enhanced team.

---

## 1. What We Use (And How)

### Daily workflow (Cursor + light mode)

```
Session start → identity.yml + progress.yaml + last 3 sessions (~800 tokens)
     ↓
/acp-audit / /acp-plan / implementation
     ↓
/acp-update (progress.yaml) + /acp-commit (sessions.md + patterns.md registries)
     ↓
     [REQUIRED v6.9] /acp-commit auto-syncs agent/sessions/*.md + agent/patterns/*.md
     ↓
Optional: /acp-visualize (dashboard)
```

### Commands with proven FIFOZ value

| Command | Value delivered |
|---------|-----------------|
| `/acp-audit` | 64 reports; pre-impl mode prevented CI/CD bugs (audit-064) |
| `/acp-plan` | M15 remediation, M11.2 CI/CD waves |
| `/acp-update` | Keeps progress.yaml aligned with git reality |
| `/acp-commit` | Cross-session continuity; **v6.9: must also auto-sync `agent/sessions/` + `agent/patterns/`** |
| `/acp-proceed` | Task execution from progress state |
| `/acp-version-update` | Framework upgrades (with caveats — see bugs) |
| `/acp-visualize` | Milestone dashboard (when YAML valid) |

### Memory layer inventory (2026-06-03)

| File | Scale | Role |
|------|-------|------|
| `progress.yaml` | 2706 lines, 14 milestones | Task/milestone SSOT |
| `audit-carryovers.md` | 5000+ lines | CO-xxx finding tracker |
| `patterns.md` | 36 entries | Pattern registry |
| `agent/patterns/` | 36 markdown files | Pattern documents (manual sync 2026-06-03) |
| `sessions.md` | 14 entries (10 sessions + 4 summaries) | Session registry |
| `agent/sessions/` | 14 markdown files | Session documents (manual sync 2026-06-03) |
| `lessons.md` | 322 lines | Corrections |
| `decisions.md` | 7 ADRs | Architecture decisions |
| `agent/reports/` | 64 audits | Deep-dive knowledge base |

### Integration points that work

- `.cursor/rules/acp.mdc` → routes to `agent/commands/acp.*.md` ✅
- `.opencode/commands/` thin wrappers (61 files) ✅
- Light mode in `routing.yml` (v6.8.2) ✅
- `command_suggestions` map for related commands ✅

---

## 2. What We Benefit From (Keep Investing Here)

1. **Structured audits** — highest ROI feature; findings persist in `agent/reports/` and carryovers
2. **progress.yaml + visualizer** — stakeholders and agents share one progress view
3. **Session key_facts** — irreplaceable for multi-week milestones (M15 phase sequencing)
4. **Pre-impl audit mode** — catches plan/code mismatches before implementation
5. **Light context mode** — makes daily sessions fast without losing progress awareness
6. **Task file tree** — `agent/tasks/milestone-*/task-NNN-*.md` scopes agent work
7. **Cursor compat path** — audit-030 + `.mdc` rule eliminated VS Code Copilot dependency

---

## 3. Bugs and Findings (Consolidated)

### 3.1 Framework bugs / gaps (ACP Enhanced)

| ID | Type | Issue | Impact on FIFOZ |
|----|------|-------|-----------------|
| F-01 | **Gap** | `/acp-commit` does not auto-sync `memory/patterns.md` → `agent/patterns/*.md` after step 3 | 36 registry entries invisible to `/acp-init`, `/acp-plan` for months |
| F-01b | **Gap** | `/acp-commit` does not auto-sync `memory/sessions.md` → `agent/sessions/*.md` after step 2 | 14 registry entries invisible; no session document directory until manual fix |
| F-02 | **Gap** | `/acp-validate` does not YAML-lint memory/progress files | Broken YAML undetected until visualizer or manual inspection |
| F-03 | **Bug** | `/acp-version-update` overwrites project `identity.yml`, `domain.yml`, `taxonomy.yml` | Required git restore after 6.8.2 bump |
| F-04 | **Gap** | `write_patterns_at_discovery` in constraints not enforced | Reusable patterns lost in session key_facts |
| F-05 | **Gap** | 61 commands installed, ~8 used — no guided onboarding | Power features (validate, memory-sync, index) undiscovered |
| F-06 | **UX** | Agent writes unquoted colons in progress.yaml `notes:` | Recurring parse failures (lines 795, 1380) |
| F-07 | **Docs** | Dual pattern store model not documented | Agents and developers confused about registry vs files |
| F-08 | **Gap** | Weekly-summary compaction writes unquoted colons in `key_facts` | sessions.md parse failure → empty Sessions visualizer page |
| F-09 | **Gap** | `/acp-commit` writes `tasks:` but visualizer expects `tasks_completed` | Sessions timeline shows "0 tasks" even when YAML valid |

### 3.2 Visualizer bugs (separate repo — feedback-001)

| ID | Issue |
|----|-------|
| V-01 | Silent empty state on bad patterns.md / sessions.md (no ErrorCard) |
| V-02 | js-yaml vs Ruby parse divergence → silent data merge |
| V-03 | SessionEntry schema drift (`tasks` vs `tasks_completed`; weekly-summary unsupported) |
| V-04 | React 19 SSR devtools log echo loop in dev mode |
| V-05 | Cold start slow (mermaid + TanStack dep optimization) |

### 3.3 Not framework bugs

- FIFOZ-specific YAML typos (fixed in session)
- Cursor sandbox EPERM on visualizer launch (environment)
- progress.yaml / pattern files uncommitted (project git hygiene)

---

## 4. Proposed v6.9 Release Backlog

### Primary requirement (non-negotiable)

**`/acp-commit` must automatically generate or update markdown documents from registries on every successful commit.** Standalone sync commands are optional extras for repair/dry-run — not a substitute for commit-time sync.

Target flow after v6.9:

```
/acp-commit
  Step 2 → prepend entry to agent/memory/sessions.md
  Step 2b → auto-sync agent/sessions/{date}-{slug}.md  ← NEW, default ON
  Step 3 → append to agent/memory/patterns.md (if applicable)
  Step 3b → auto-sync agent/patterns/{name}.md         ← NEW, default ON
  Step 6 → compact sessions (if >15 entries)
  Step 6b → re-sync affected session documents        ← NEW after compaction
  Step 7 → confirm: registries + N session files + M pattern files updated
```

**Escape hatch**: `/acp-commit --no-sync` skips steps 2b/3b/6b (for debugging only; must warn that document dirs may drift).

**Accept criteria**:

- After every default `/acp-commit`, every registry entry has a corresponding markdown file (create if missing, update if registry entry changed).
- Sync is **idempotent** — re-running commit without registry changes does not rewrite files unnecessarily.
- Confirmation output lists files created/updated (counts + paths optional in verbose mode).
- `/acp-pattern-sync` and `/acp-session-sync` remain available as **manual repair** tools (`--dry-run`, `--all`) but are **not required** for normal workflow.

### Must-have (P0)

| Item | Description | Accept criteria |
|------|-------------|-----------------|
| **Commit-integrated document sync** | Extend `acp.commit.md` steps 2b, 3b, 6b | Default `/acp-commit` syncs `agent/sessions/` and `agent/patterns/` from registries; `--no-sync` opt-out |
| **Memory YAML validation** | Extend `/acp-validate` or new `/acp-validate-memory` | Fails with line number on bad patterns.md, progress.yaml, sessions.md |
| **Manual repair sync (secondary)** | `/acp-pattern-sync` and `/acp-session-sync` with `[--dry-run] [--all]` | Re-sync all registry entries without a full commit; same logic as commit steps 2b/3b |
| **Version update guard** | `/acp-version-update --diff` + `--preserve-project-core` | Never silently overwrite identity/domain/taxonomy without confirmation |

### Should-have (P1)

| Item | Description |
|------|-------------|
| Pattern dual-store wiki section | architecture.md: registry vs documents; **commit auto-sync is the bridge** |
| Session dual-store wiki section | Same model for sessions.md vs agent/sessions/ |
| Commit step pattern promotion | `/acp-commit` step 3 prompts promoting key_fact → patterns.md, then step 3b syncs file |
| Commit YAML quoting for compaction | Quote `key_facts` list items containing `:` when writing weekly-summary (step 6) |
| YAML write hints | Agent directive in acp.update.md + acp.commit.md: quote scalars containing `:` |
| Command onboarding | `/acp-init` shows "commands for your current phase" (top 5) |
| Optional git hook template | Pre-commit YAML lint for progress + patterns |

### Nice-to-have (P2)

| Item | Description |
|------|-------------|
| `/acp-feedback` discoverability | Mention in acp.commit confirmation output |
| taxonomy.yml drift check | Warn if last_updated > 90 days |
| Visualizer coordination | Document minimum visualizer version in acp.visualize.md |
| Memory file ErrorCard parity | Track visualizer V-01 as dependency |

---

## 5. Suggested Release Notes Framing (v6.9)

```markdown
## v6.9.0 — Memory Integrity Release

### Added
- `/acp-commit` now auto-syncs `agent/sessions/` and `agent/patterns/` from registries (steps 2b, 3b, 6b)
- `/acp-commit --no-sync` — opt out of document sync (debug only)
- `/acp-pattern-sync` and `/acp-session-sync` — manual repair / dry-run (same engine as commit sync)
- `/acp-validate --memory` — YAML lint for patterns.md, progress.yaml, sessions.md

### Fixed
- `/acp-version-update` no longer overwrites project-specific core files without confirmation

### Changed
- Wiki: documented pattern and session dual-store models; commit is the sync trigger
- `/acp-commit`: quotes colons in weekly-summary compaction; confirmation reports sync counts
- Visualizer: SessionEntry reads `tasks` field; weekly-summary blocks render on timeline
```

---

## 6. Evidence and Metrics

**Production usage (FIFOZ, May–Jun 2026)**:

- Audits: 64
- Milestones in progress.yaml: 14 (M1–M14, non-sequential IDs)
- Tasks tracked: ~122
- Patterns (post-fix): 36 registry + 36 markdown files
- Sessions (post-fix): 14 registry + 14 markdown files
- Session commits: 10 (+ 4 compacted weekly summaries)
- ACP package version: 6.8.2 (updated 2026-06-03)

**Incident timeline (2026-06-03)**:

1. Visualizer showed YAML parse error on progress.yaml (unquoted colon) — fixed
2. Patterns page empty despite registry content — root cause chain identified
3. patterns.md line 120 malformed — js-yaml returned 0 entries
4. Manual remediation: YAML fix + 36 pattern file generation
5. Sessions page empty despite 14 registry entries — sessions.md weekly-summary colons broke js-yaml
6. Manual remediation: quote key_facts + 14 session file generation

**Reproduction commands**: see feedback-001 §4 and audit-065 findings A-065-01 through V-065-05.

---

## 7. What We Will Do on FIFOZ Side

| Action | Owner | When |
|--------|-------|------|
| Commit progress.yaml + pattern/session files + feedback/audit reports | Developer | Next git commit |
| Run `/acp-validate --memory` once available | Agent | After v6.9 |
| Add lesson for YAML colon quoting | Agent | Next acp-commit |
| Open GitHub issues from this feedback | Developer | Optional |

---

## 8. Recommendation to ACP Enhanced Team

**Accept this as field feedback from a production user**, not a theoretical review. FIFOZ depends
on ACP Enhanced for milestone-scale work. The pattern/visualizer incident is a **canary** for
broader memory-layer validation gaps — fixing F-01/F-02 prevents entire classes of silent failures.

**Priority ask for v6.9**: **`/acp-commit` must auto-sync session and pattern markdown files by default**, plus memory YAML validation and version-update guard. Standalone sync commands are repair tools only — not the primary workflow.

---

## 9. Second Round Addendum (audit-066)

A second-pass audit (`agent/reports/audit-066-acp-enhanced-second-round-usage-review.md`) validated feedback-001/002 and added workflow-shape findings.

### Feedback validation

| Original claim | Status |
|----------------|--------|
| Pattern dual-store gap | ✅ Reconfirmed |
| Validate skips memory YAML | ✅ Reconfirmed — cited in 5 audits, run in 0 sessions |
| Version-update overwrite | ✅ Reconfirmed |
| Command underutilization | ✅ Reconfirmed — reports show 25× audit, 5× validate (recommended not run) |

### New findings (not in §3)

| ID | Finding | Release impact |
|----|---------|----------------|
| B-066-01 | **Audit-first workflow** — 64 audits vs 4 plans; audits substitute for clarifications/specs | Document + audit completion hooks |
| B-066-02 | **progress.yaml ↔ git drift** recurring (uncommitted progress while tasks marked complete) | `/acp-status --health` |
| B-066-07 | **`local.main.yaml` never bootstrapped** — index layer unused | `/acp-index init` |
| B-066-08 | **carryovers.md unqueryable** at 5000+ lines | Carryover search / visualizer tab |
| B-066-09 | **`/acp-memory-sync` never run** despite 10+ sessions | Auto-prompt at 15 session entries |

### Additional v6.9 backlog (P1 workflow)

| Item | Description |
|------|-------------|
| R-066-01 | `/acp-audit` completion checklist → update, **commit (with auto-sync)**, validate |
| R-066-02 | `/acp-status --health` — YAML lint + progress.yaml git drift |
| R-066-03 | `depends_on` validator in `/acp-validate` |
| R-066-04 | `/acp-index init` — bootstrap from project patterns/commands |
| R-066-05 | Carryover query (CLI or visualizer) |
| R-066-06 | Audit-first user guide in wiki |

### FIFOZ self-improvements (project-side, not framework)

Run validate after update; commit progress.yaml with code; bootstrap index; monthly memory-sync; log ACP protocol lessons immediately. **Until v6.9**: manually re-run sync script after `/acp-commit` if registry entries change.

---

## 10. Memory Layer Incident Addendum (2026-06-03)

Combined patterns + sessions remediation confirms a **systemic memory-layer gap** in ACP Enhanced 6.8.2:

| Memory file | Registry entries | Document dir (before fix) | Parse blocker | Files generated |
|-------------|------------------|---------------------------|---------------|-----------------|
| `patterns.md` | 36 | 0 (templates only) | Missing `- date:` line 120 | 36 in `agent/patterns/` |
| `sessions.md` | 14 | 0 (dir missing) | Unquoted `:` in weekly `key_facts` | 14 in `agent/sessions/` |
| `progress.yaml` | 2706 lines | N/A (single file) | Unquoted `:` in `notes:` | Fixed in place |

**Framework ask (unambiguous)**: `/acp-commit` is the single sync trigger. On every commit:

1. Write registry (steps 2, 3 — existing behavior)
2. **Auto-generate/update markdown documents** (steps 2b, 3b — new, default ON)
3. **Re-sync after weekly compaction** (step 6b — new)
4. Validate YAML before confirm (integrate with `/acp-validate --memory`)
5. Align visualizer schema with commit output format

Standalone `/acp-pattern-sync` and `/acp-session-sync` are **repair-only** — same engine, callable without a full commit.

See feedback-001 for full incident detail and reproduction steps.

---

**Submitted by**: FIFOZ development team via Cursor  
**Audit companions**: audit-065, **audit-066**  
**Incident detail**: feedback-001
