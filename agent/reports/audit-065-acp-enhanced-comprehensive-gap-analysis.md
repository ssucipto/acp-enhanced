# Audit Report: ACP Enhanced — Comprehensive Gap Analysis & Improvement Plan

**Audit**: #065  
**Date**: 2026-06-15  
**Subject**: Full ACP Enhanced implementation — gaps, inconsistencies, development directions, and production-readiness improvements for startup engineering tooling  

---

## Summary

This audit covers the entire ACP Enhanced codebase at v6.12.1 across six dimensions: (1) command coverage and structural conformance, (2) script quality, (3) memory/knowledge architecture, (4) CI/CD and security hardening, (5) startup engineering production-readiness, and (6) context-protocol completeness. 57 milestones and 65+ commands were surveyed.

**Key takeaway**: The framework's protocol layer is mature and internally consistent. The primary risk areas are test coverage gaps (65% of commands have no E2E tests), missing `decisions.md` (all ADRs lost), stale carryover tracking, and three production-readiness gaps that block confident use as a startup engineering tool: no branch protection, no SECURITY.md, and no Windows CI.

22 findings are identified: 3 Critical, 7 High, 9 Medium, 3 Low. A phased improvement plan is included.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/commands/*.md` (71 files) | command-docs | Command structural conformance |
| `agent/scripts/acp.*.sh` (29 files) | scripts | Script quality, set -e patterns |
| `agent/skills/*.md` (7 files) | skills | Coding standards |
| `agent/wiki/architecture.md` | wiki | System architecture |
| `agent/schemas/*.yaml` (5 files) | schemas | Schema coverage |
| `agent/memory/audit-carryovers.md` | memory | 8 pending carryovers |
| `agent/memory/sessions.md` | memory | Session history |
| `agent/memory/lessons.md` | memory | Correction log |
| `agent/memory/patterns.md` | memory | Reusable patterns |
| `agent/memory/decisions.md` | memory | **FILE DOES NOT EXIST** |
| `agent/core/identity.yml` | core | Identity, team, git workflow |
| `agent/core/routing.yml` | core | Context modes, session state |
| `agent/core/constraints.yml` | core | Hard rules |
| `agent/core/network_whitelist.yml` | core | Network allowlist |
| `agent/routing/taxonomy.yml` | routing | Task taxonomy |
| `agent/progress.yaml` | tracking | Milestones M44-M58 |
| `.github/workflows/ci.yaml` | CI | Syntax, shellcheck, E2E smoke |
| `.github/workflows/e2e-tests.yaml` | CI | Full E2E matrix (ubuntu+macOS) |
| `.github/workflows/benchmark.yaml` | CI | Benchmark runner |
| `scripts/acp-bootstrap.sh` | installer | Bootstrap logic, step 7 |
| `scripts/package.json` | tooling | NPM dependencies |
| `e2e/*.test.sh` (40 unique files) | tests | E2E coverage |
| `agent/reports/audit-*.md` (15 files) | reports | Audit history |

---

## Key Findings

### Category 1 — Command Coverage and Structure

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| CRIT-001 | 46 of 71 commands (65%) have no E2E test file | `e2e/` vs `agent/commands/` | Critical |
| HIGH-002 | `acp.integrity.md` and `acp.review.md` missing `## Steps` section | `agent/commands/acp.integrity.md:1`, `acp.review.md:1` | High |
| MED-003 | 5 commands missing `## Verification` section | `acp.dispatch.md`, `acp.feedback.md`, `acp.install.md`, `acp.task.md`, `acp.visualize.md` | Medium |

**CRIT-001 detail** — Commands with no E2E test (46 total):
`acp.artifact-glossary`, `acp.artifact-reference`, `acp.artifact-research`, `acp.audit`, `acp.carryover-query`, `acp.clarification-address`, `acp.clarification-capture`, `acp.clarification-create`, `acp.command-create`, `acp.commit`, `acp.cost-report`, `acp.decide`, `acp.design-create`, `acp.design-reference`, `acp.dispatch`, `acp.feedback`, `acp.handoff`, `acp.init`, `acp.memory-sync`, `acp.package-install`, `acp.package-publish`, `acp.pattern-create`, `acp.pattern-sync`, `acp.plan`, `acp.preferences-create`, `acp.preferences-get`, `acp.preferences-set`, `acp.preferences-show`, `acp.preferences-validate`, `acp.proceed`, `acp.project-create`, `acp.projects-restore`, `acp.report`, `acp.resume`, `acp.route`, `acp.session-sync`, `acp.status`, `acp.task-create`, `acp.task`, `acp.update`, `acp.validate`, `acp.version-check-for-updates`, `acp.version-check`, `acp.version-update`, `acp.visualize`, `acp.wiki-update`.

Notable high-risk untested commands: `/acp-init`, `/acp-proceed`, `/acp-plan`, `/acp-dispatch` (core workflow), `/acp-audit` (this very command), `/acp-validate`, `/acp-commit`.

### Category 2 — Script Quality

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| HIGH-004 | 17 scripts use `set -e` not `set -euo pipefail` | See list below | High |
| MED-005 | `scripts/acp-bootstrap.sh` uses `set -e` + `set -o pipefail` on separate lines — not canonical | `scripts/acp-bootstrap.sh:11-12` | Medium |

**HIGH-004 scripts** (missing `-u` unbound var check and `-o pipefail`):
`acp.install.sh`, `acp.package-create.sh`, `acp.package-info.sh`, `acp.package-install-optimized.sh`, `acp.package-install.sh`, `acp.package-list.sh`, `acp.package-publish.sh`, `acp.package-remove.sh`, `acp.package-update.sh`, `acp.package-validate.sh`, `acp.project-info.sh`, `acp.project-update.sh`, `acp.sessions.sh`, `acp.uninstall.sh`, `acp.version-check-for-updates.sh`, `acp.version-check.sh`, `acp.version-update.sh`.

Risk: unbound variable bugs silently succeed; pipeline failures are masked.

### Category 3 — Memory and Knowledge Architecture

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| CRIT-006 | `agent/memory/decisions.md` does not exist — all ADRs have no storage | `agent/memory/decisions.md` | Critical |
| MED-007 | 8 `status: pending` carryovers — 3 (BUG-045) were fixed in M51 but never marked `fixed` | `agent/memory/audit-carryovers.md:463-497` | Medium |
| MED-008 | Audit reports #052–#064 absent from `agent/reports/` — 13 reports referenced in memory but not stored | `agent/reports/` | Medium |

**CRIT-006 detail**: The AGENTS.md, CLAUDE.md, and acp.decide.md all specify that `/acp-decide` appends to `agent/memory/decisions.md`. The file does not exist. At v6.12.1 with 57+ milestones and 65+ commands, significant architectural decisions (dual-store architecture, light/full mode design, skill @-mention system, dispatch model, YAML parser choice, etc.) have never been durably recorded. Any team member or new session has no access to the decision history.

**MED-007 detail**: BUG-045-01 (step 7 file count check), BUG-045-02 (opencode independent block), BUG-045-03 (exit 1 on verify failure) — all three are confirmed fixed in the current codebase (M51, routes 113-116) but their `audit-carryovers.md` entries still show `status: pending`. This indicates the carryover lifecycle discipline broke down after M51.

### Category 4 — CI/CD and Security

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| HIGH-009 | No Windows CI runner — Windows is documented target but has no automated test coverage | `.github/workflows/` | High |
| HIGH-010 | No SECURITY.md / vulnerability disclosure process | repo root | High |
| MED-011 | No CODEOWNERS — no ownership model for review enforcement | repo root | Medium |
| MED-012 | `team_members: []` in identity.yml — IG-37 git author verification is disabled | `agent/core/identity.yml:25` | Medium |
| MED-013 | No Dependabot/Renovate — 3 NPM packages and 3 pinned GitHub Actions not auto-monitored | repo root | Medium |
| LOW-014 | `network_whitelist.yml` has empty `reviewed_by` field | `agent/core/network_whitelist.yml:29` | Low |

### Category 5 — Startup Production Readiness

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| CRIT-015 | No branch protection rules on `mainline` or `develop` — force-push, direct commits unblocked | GitHub repository settings | Critical |
| MED-016 | No PR or issue templates — no standardized contribution workflow | `.github/` | Medium |
| MED-017 | No `package-lock.json` in `scripts/` — `^` ranges allow silent upgrades; no pinned lockfile | `scripts/package.json` | Medium |
| MED-018 | No SAST in CI — only shellcheck; no dependency vulnerability scan, no secret scanning | `.github/workflows/ci.yaml` | Medium |

### Category 6 — Context Protocol Completeness

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| LOW-019 | `routing.yml context_modes.current: full` persisted from prior session — static config file holds dynamic state | `agent/core/routing.yml` | Low |
| LOW-020 | Light-mode `confirm_output` template hardcodes `~200 tokens` — should be advisory label, not a computed estimate | `agent/core/routing.yml` | Low |
| LOW-021 | `acp.commit.md` steps 2b/3b/6b (dual-store sync) documented in architecture wiki but absent from `acp.commit.md` help text | `agent/commands/acp.commit.md` | Low |

---

## Key Decisions

- **Dual-store architecture** (v6.9.0): compact YAML registry + synced markdown documents. Documented in `agent/wiki/architecture.md`. No ADR recorded.
- **@-mention skill system** (v6.8.2): skills are now invoked explicitly, not auto-loaded. Documented in AGENTS.md. No ADR recorded.
- **Light/full context modes** (v6.8.2): daily-use mode loads ~200 tokens; full mode loads ~800 tokens. Routing tracked in `routing.yml`. No ADR recorded.
- **BUG-045 fixes** (M51): all three bootstrap bugs were fixed but carryover cleanup was skipped.
- **Actions SHA pinning** (M57/integrity-001): three workflow files now use commit-hash pinned actions. This session confirmed fix.

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/core/identity.yml:25` | `team_members: []` — IG-37 author verification list is empty |
| `agent/core/network_whitelist.yml:29` | `reviewed_by: ""` — no sign-off on whitelist |
| `agent/core/routing.yml:5` | `executor: copilot` + `context_modes.current: full` — session state in static file |
| `agent/memory/audit-carryovers.md:463-497` | BUG-045-01/02/03 — fixed in M51 but status still `pending` |
| `agent/scripts/acp.install.sh:6` | `set -e` without `-u` or `pipefail` (representative of 17 scripts) |
| `agent/commands/acp.integrity.md:1` | No `## Steps` section — largest command doc, missing structural marker |
| `.github/workflows/ci.yaml:1` | No Windows runner job |
| `scripts/package.json:1` | No `package-lock.json` — `^` ranges allow silent version drift |
| `scripts/acp-bootstrap.sh:11-12` | `set -e` and `set -o pipefail` on separate lines |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-06-07 | `2f13486` | M57 complete — recurring tasks + maintenance sync |
| 2026-06-07 | `9344dfb` | Trim identity.yml to 388 tokens (Layer 1 budget) |
| 2026-06-07 | `72d03d8` | M56 — /acp-integrity v1.0 |
| 2026-06-07 | `ab54988` | M55 — /acp-review command |
| 2026-06-07 | Various | CI/CD fixes: YAML parser EXIT trap, parallel test isolation, manifest template |

---

## Gap Matrix Summary

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Command coverage | 1 | 1 | 1 | 0 | 3 |
| Script quality | 0 | 1 | 1 | 0 | 2 |
| Memory/knowledge | 1 | 0 | 2 | 0 | 3 |
| CI/CD & security | 0 | 2 | 3 | 1 | 6 |
| Production readiness | 1 | 0 | 3 | 0 | 4 |
| Context protocol | 0 | 1 | 0 | 3 | 4 |
| **Total** | **3** | **5** | **10** | **4** | **22** |

---

## Comprehensive Improvement Plan

### Phase 1 — Foundations (address Critical findings)

**P1-A: Create `agent/memory/decisions.md`** (CRIT-006)
- Create the file with the schema defined in `acp.decide.md`
- Reconstruct key ADRs from the wiki, patterns.md, and commit history:
  - ADR-001: YAML parser choice (pure-bash, no yq dependency)
  - ADR-002: Light/full context mode design
  - ADR-003: Dual-store registry-to-document architecture
  - ADR-004: @-mention skill invocation (deprecating auto-load)
  - ADR-005: Parallel task DAG model
  - ADR-006: Dispatch model (OpenRouter, Persona B/C)
- Route: 1 task, est. 4h

**P1-B: Enforce branch protection** (CRIT-015)
- Enable required status checks (CI Checks job) on both `mainline` and `develop`
- Require PR review for `mainline` merges
- Disable direct force-push to `mainline`
- Reference: M54 (already planned)
- Action: GitHub repository settings → Branch protection rules

**P1-C: Bulk E2E test stubs for untested commands** (CRIT-001)
- Priority tier 1 (core workflow, highest risk): `/acp-init`, `/acp-proceed`, `/acp-plan`, `/acp-dispatch`, `/acp-commit`, `/acp-validate`, `/acp-audit`, `/acp-route`
- Priority tier 2 (package workflow): `/acp-package-install`, `/acp-project-create`, `/acp-version-check`, `/acp-version-update`
- Priority tier 3 (memory/knowledge): `/acp-decide`, `/acp-status`, `/acp-resume`, `/acp-feedback`
- Route: 3 tasks (one per tier), est. 12h total

### Phase 2 — Quality Hardening (address High findings)

**P2-A: Upgrade 17 scripts from `set -e` to `set -euo pipefail`** (HIGH-004)
- Batch-upgrade all 17 scripts listed in CRIT-004
- Verify no existing code breaks on `-u` (unbound variable errors surface)
- Route: 1 task, est. 3h

**P2-B: Add `## Steps` to `acp.integrity.md` and `acp.review.md`** (HIGH-002)
- These are the flagship M55/M56 commands — structural conformance is high visibility
- Both files likely use an alternative organization (rule-tables instead of numbered steps)
- Solution: add a `## Steps` section that serves as an overview/entry-point to the rule tables
- Route: 1 task, est. 2h

**P2-C: Add Windows CI runner** (HIGH-009)
- Add `windows-latest` to the `e2e-tests.yaml` matrix (ubuntu + macOS + Windows)
- Prerequisite: ensure `.gitattributes` LF enforcement is committed (already done, integrity-001 fix)
- Route: 1 task, est. 2h

**P2-D: Add SECURITY.md** (HIGH-010)
- Describe vulnerability disclosure process (private GitHub security advisory)
- Define scope: which components are in-scope (scripts, dispatch, bootstrap)
- Route: 1 task, est. 1h

### Phase 3 — Process Hardening (address Medium findings)

**P3-A: Fix stale carryovers** (MED-007)
- Mark BUG-045-01, BUG-045-02, BUG-045-03 as `status: fixed` in `audit-carryovers.md`
- Set `fix_applied_date: 2026-06-06` (M51 completion date) and `verified_in_audit: "046"`
- Add process rule: after each milestone, sweep carryovers and close any addressed items

**P3-B: Restore missing audit reports #052–#064** (MED-008)
- These were generated in prior sessions but not committed
- Create stub/reconstruction reports from sessions.md and lessons.md entries
- Alternatively: document as a known gap in a single `audit-archive-gap.md` note
- Route: 1 task, est. 2h

**P3-C: Add `## Verification` to 5 commands** (MED-003)
- `acp.dispatch.md`, `acp.feedback.md`, `acp.install.md`, `acp.task.md`, `acp.visualize.md`
- Route: 1 task, est. 1h

**P3-D: Populate `team_members` in identity.yml** (MED-012)
- Add the developer's git email to `team_members:` list
- This enables IG-37 git author verification in `/acp-integrity`
- Route: 0 tasks (30-minute change)

**P3-E: Add CODEOWNERS and PR template** (MED-011, MED-016)
- `.github/CODEOWNERS` with a catch-all `*` rule
- `.github/pull_request_template.md` with checklist: E2E status, CHANGELOG entry, route file
- Route: 1 task, est. 1h

**P3-F: Dependabot configuration** (MED-013)
- Add `.github/dependabot.yml` for npm (scripts/) with weekly schedule
- Add GitHub Actions section to monitor pinned action SHA updates
- Route: 1 task, est. 1h

**P3-G: Add package-lock.json to scripts/** (MED-017)
- Run `npm install` in scripts/ to generate lockfile
- Commit and add to `.gitignore` exclusion only if it currently excludes it
- Route: 0 tasks (one command)

**P3-H: Add SAST step to CI** (MED-018)
- Add `npm audit` step to CI for dependency vulnerability scanning
- Add `truffleHog` or `gitleaks` step for secret scanning
- Route: 1 task, est. 2h

### Phase 4 — Development Directions (address in future milestones)

**M59 — Carryover + Audit Hygiene**
- Address 5 audit-062 carryovers (hooks format, checklist verification, auto next_due, git hook reference, findings feedback loop)
- Estimated: M59, 5 routes

**M60 — Comprehensive Test Coverage Sprint (Tier 1)**
- E2E tests for 8 core workflow commands
- Goal: no critical command without at least a smoke test
- Estimated: M60, 8 routes

**M61 — Production Readiness Pack**
- Branch protection (M54)
- SECURITY.md + CODEOWNERS + PR template
- Dependabot + npm audit in CI
- Windows CI
- ADR reconstruction
- Estimated: M61, 10 routes

**M62 — Test Coverage Sprint (Tier 2 + 3)**
- E2E tests for 24 more commands (package workflow + memory/knowledge)
- Estimated: M62, 12 routes

**M58 (active) — /acp-integrity v2.0**
- route-156: v2.0 command doc + wiki + skill updates (next step)
- 75% remaining

---

## Recommendations

1. **Start with P1-A (decisions.md)** — the ADR gap is an invisible knowledge loss that compounds with every new session. 30 minutes to create the file; 2–3h to reconstruct the most important decisions.

2. **Block on P1-B (branch protection)** before any further mainline merges — a single accidental force-push could corrupt the production branch history.

3. **Batch P2-A (pipefail upgrade)** as a single PR — 17 files is a one-script sed job; the risk is low since `-u` errors will surface only if the scripts have latent undefined variable bugs.

4. **Prioritize P1-C Tier 1** over other test work — 8 commands control the entire ACP workflow; their absence from E2E means a regression in `/acp-proceed` or `/acp-commit` would go undetected.

5. **Run P3-A immediately** (stale carryover cleanup) — it takes 10 minutes and improves every future session's carryover report accuracy.

6. **Use the improvement plan phases as M61 milestone inputs** — the phase structure maps directly to milestone planning: P1 = M60 critical-fix track, P2 = M61 quality-hardening track, P3 = inline carryover work.

7. **Create `decisions.md` before M58 route-156** — route-156 will likely generate architectural decisions about the v2.0 semantic analysis design; there must be a place to record them.

---

## Next Steps for Developer

| Priority | Action | Effort | Status |
|----------|--------|--------|--------|
| P0 | Create `agent/memory/decisions.md` | 30 min | Pending |
| P0 | Enable branch protection on `mainline` + `develop` | 15 min | Pending |
| P0 | Mark BUG-045 carryovers as `fixed` in audit-carryovers.md | 10 min | Pending (this audit) |
| P1 | Continue M58 route-156 (`/acp-integrity v2.0` command doc) | 4h | Active milestone |
| P1 | Add SECURITY.md | 1h | Pending |
| P2 | Upgrade 17 scripts to `set -euo pipefail` | 3h | M60 or inline |
| P2 | Add E2E tests for 8 core commands (Tier 1) | 12h | M60 |
| P2 | Windows CI runner | 2h | M61 |
| P3 | Dependabot + npm audit in CI | 2h | M61 |
| P3 | CODEOWNERS + PR template | 1h | M61 |
