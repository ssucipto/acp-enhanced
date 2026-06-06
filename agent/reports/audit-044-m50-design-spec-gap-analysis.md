# Audit Report: M50 Design-Spec Command Integration — Gap Analysis

**Audit**: #044  
**Date**: 2026-06-06  
**Subject**: M50 plan completeness — gaps between our 7-route implementation plan, the feedback-005 requirements, the source `acp.design-spec.md` v1.1.0 command, ACP Enhanced conventions, and industry standards  

---

## Summary

M50 plans the integration of `/acp-design-spec` (v1.1.0) from FIFOZ feedback-005 into ACP Enhanced. The 7-route plan covers all P0–P2 priority items: command port, wrappers, template, E2E test, framework integration, cross-links, and version bump. P3 items (Visualizer preset, exemplar) are intentionally deferred.

**Overall assessment**: The plan is **structurally sound** — all critical integration points are covered. Three actionable gaps found (one MEDIUM, two LOW), plus four informational observations. No blocking issues. The command itself (v1.1.0) was already hardened by audit-070 in FIFOZ production — the integration risk is low.

**Key finding**: Route-107 references `.cursor/commands/` (a directory that does not exist in this project) instead of `.github/prompts/` (the VS Code prompt surface required by the triple-file architecture). This is the most significant gap.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-50-design-spec-command.md` | milestone | Primary plan document |
| `agent/routing/tasks/route-106.md` | route | Port command doc from feedback |
| `agent/routing/tasks/route-107.md` | route | Wrappers + package.yaml entry |
| `agent/routing/tasks/route-108.md` | route | Template directory + file |
| `agent/routing/tasks/route-109.md` | route | E2E smoke test |
| `agent/routing/tasks/route-110.md` | route | routing.yml + taxonomy.yml |
| `agent/routing/tasks/route-111.md` | route | Cross-links in peer commands |
| `agent/routing/tasks/route-112.md` | route | Version bump + CHANGELOG |
| `agent/feedback/feedback-005-acp-design-spec-command-upstream.md` | feedback | Requirements source |
| `agent/feedback/acp.design-spec.md` | command | Source command v1.1.0 (~500 lines) |
| `agent/feedback/audit-070-acp-design-spec-command-review.md` | audit | FIFOZ pre-ship audit |
| `agent/feedback/design-spec.template.md` | template | 19-section output template |
| `agent/feedback/design-spec-app-interfaces-m15-spine-v2.1.md` | exemplar | FIFOZ production output (731 lines) |
| `agent/patterns/local.command-naming-convention.md` | pattern | Triple-file architecture |
| `agent/patterns/local.upstream-integration-runbook.md` | pattern | Porting process |
| `agent/patterns/local.e2e-testing.md` | pattern | E2E test conventions |
| `agent/patterns/local.tracked-untracked-directories.md` | pattern | Git tracking conventions |
| `agent/.gitignore` | config | Directory tracking rules |
| `agent/core/routing.yml` | config | command_suggestions target |
| `agent/routing/taxonomy.yml` | config | task_type target |
| `run-e2e-tests.sh` | script | Test runner (auto-discovery verified) |
| `.github/prompts/` (66 files) | wrappers | VS Code prompt surface |
| `.opencode/commands/` (66 files) | wrappers | OpenCode command surface |

---

## Key Findings

| ID | Severity | Finding | Location | Recommendation |
|----|----------|---------|----------|----------------|
| G-044-01 | **MEDIUM** | Route-107 references non-existent `.cursor/commands/` directory instead of `.github/prompts/` | `route-107.md` §Changes | Update route-107: replace `.cursor/commands/acp-design-spec.md` with `.github/prompts/acp-design-spec.prompt.md`. The triple-file architecture (per `local.command-naming-convention.md`) requires `.github/prompts/acp-NAME.prompt.md` as file #2, not `.cursor/commands/`. |
| G-044-02 | **LOW** | Route-106 adaptation steps are generic — specific upstream→local adaptations not enumerated | `route-106.md` §Changes | Expand §Changes to list 4 explicit adaptation checks: exemplar path → reference-only, Visualizer refs → optional, `@acp.` notation → verify none remain, internal links → verify resolution. |
| G-044-03 | **LOW** | No `agent/index/` entry planned for the new command — reduces contextual discoverability | M50 plan (missing) | Add low-priority task or include in route-110: create `acp.design-spec` entry in `agent/index/acp.core.yaml` (or local index) so agents discover it during key-file loading. |
| G-044-04 | **INFO** | `.cursor/` directory does not exist in this project — route-107 would need to create it | `route-107.md` | Resolved by G-044-01 fix. If `.cursor/commands/` is needed for Cursor IDE integration separately from the ACP triple-file architecture, that's a separate concern outside M50 scope. |
| G-044-05 | **INFO** | `run-e2e-tests.sh` auto-discovers `e2e/*.test.sh` files — no registration needed for route-109 | `run-e2e-tests.sh:87` | Confirmed: test auto-discovery via glob. Route-109 test will be picked up automatically. No action needed. ✓ |
| G-044-06 | **INFO** | No `domain.yml` update planned — command taxonomy entry not addressed | M50 plan (missing) | Consider adding domain.yml entry in route-110 or as a follow-up. Not blocking — domain.yml is a reference file, not operational. |
| G-044-07 | **INFO** | No README.md update planned — new user-facing command not mentioned | M50 plan (missing) | Consider adding to route-112 (version bump route) or as a follow-up. README lists recent enhancements; M50 adds a significant new command category. |

---

## Key Decisions

1. **P3 items deferred**: Visualizer document type preset and abbreviated exemplar are intentionally deferred to a later milestone. The milestone doc notes this but doesn't create a carryover or follow-up task. → **Recommendation**: Add a `deferred:` entry in the M50 session commit so these aren't forgotten.

2. **Template directory tracking**: `agent/templates/` will be tracked in git (not gitignored) because `design-spec.template.md` is a framework distribution file, not instance data. This follows the same model as `agent/patterns/` (tracked) rather than `agent/milestones/` (gitignored). Decision is correct but implicit — make it explicit in route-108.

3. **E2E test naming**: Route-109 uses `e2e/acp.design-spec.test.sh` which follows ACP Enhanced convention (dot separator, `.test.sh` suffix). The feedback-005 suggested `acp-design-spec.e2e.sh` — the ACP Enhanced convention correctly overrides. ✓

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/patterns/local.command-naming-convention.md:20-24` | Triple-file architecture: command directive (.dot), VS Code prompt (.prompt.md), opencode (.md) |
| `agent/patterns/local.upstream-integration-runbook.md:62-67` | Naming translation: `@acp.<name>` → `/acp-<name>`, never use `@acp-` |
| `agent/.gitignore:22` | `milestones/**` — gitignored (instance data) |
| `agent/.gitignore:37` | `routing/tasks/**` — gitignored (instance data) |
| `agent/.gitignore:17` | `tasks/**` — gitignored; `!tasks/.gitkeep` + template excepted |
| `run-e2e-tests.sh:87` | Test auto-discovery: `for test_file in "$SCRIPT_DIR"/e2e/*.test.sh` |
| `.github/prompts/acp-plan.prompt.md:1-5` | Prompt wrapper format: frontmatter + "Read and execute `agent/commands/acp.NAME.md`" |
| `.opencode/commands/acp-design-create.md:1-4` | OpenCode wrapper format: frontmatter + "Read and execute `agent/commands/acp.NAME.md`" |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-06-06 | `7750aef` | plan(M50): create milestone and 7 routes for /acp-design-spec command integration |

---

## Industry Standards Cross-Check

The source command (v1.1.0) was audited against these standards in audit-070. Re-verified for ACP Enhanced integration:

| Standard | Coverage | Status |
|----------|----------|--------|
| **arc42** §1, §3, §5–8, §11–12 | Spec sections §1–§19 | ✅ Covered (v1.1.0) |
| **C4 Model** L1–L3 | Context, containers, components | ✅ Covered |
| **IEEE 1016** | Interface/interaction views, traceability | ✅ Covered |
| **ISO/IEC/IEEE 42010** | Stakeholders, 5 viewpoints | ✅ Covered |
| **DFD** L0–L2 | Context + process + store diagrams | ✅ Covered |
| **UML** | Sequence diagrams | ✅ Covered |
| **arc42 §10** (quality scenarios) | Intentionally excluded | ✅ Documented exclusion |
| **C4 L4** (code-level) | Intentionally excluded | ✅ Documented exclusion |
| **Full threat model** | Intentionally excluded (links ADRs) | ✅ Documented exclusion |
| **ACP triple-file architecture** | Command + prompt + opencode | ⚠️ G-044-01 |
| **ACP constraints.yml** | macOS BSD compat, no external deps | ✅ (no shell scripts) |
| **ACP bash_rules** | set -euo pipefail, trap ERR | ✅ N/A (agent directive only) |

---

## Recommendations

### Pre-Implementation (fix before starting M50)

1. **Fix route-107 wrapper targets** (G-044-01): Replace `.cursor/commands/acp-design-spec.md` with `.github/prompts/acp-design-spec.prompt.md`. The triple-file architecture requires the `.github/prompts/` surface as file #2. If `.cursor/commands/` integration is desired for Cursor IDE, that's a separate enhancement outside M50 scope.

2. **Expand route-106 adaptation checklist** (G-044-02): Add 4 explicit checks to §Changes: exemplar path → reference-only notation, Visualizer refs → optional annotation, `@acp.` notation verification, internal link resolution.

### Post-Implementation (can be done after M50 completes)

3. **Add index entry** (G-044-03): Create `acp.design-spec` entry in `agent/index/acp.core.yaml` for contextual discoverability. Low effort, high value for agent awareness.

4. **Add domain.yml entry** (G-044-06): Register design-spec in the command taxonomy under `agent/wiki/domain.yml`. Ensures `/acp-wiki-update` consistency.

5. **Mention in README** (G-044-07): Add design-spec to README's recent enhancements or command listing section.

6. **Create deferred-item tracking** (Decisions #1): When committing the M50 session, add P3 items to `deferred:` so the Visualizer preset and exemplar aren't lost.

### No Action Needed

7. **E2E test auto-discovery** (G-044-05): Confirmed working — test runner globs `e2e/*.test.sh`. No registration needed. ✓
8. **Template directory tracking** (Decisions #2): `agent/templates/` correctly tracked (not gitignored). ✓
9. **Industry standards coverage**: v1.1.0 command already passed audit-070. All documented exclusions are intentional. ✓

---

## Verdict

**M50 is READY to proceed** — the plan is comprehensive and covers all P0–P2 integration items. Two pre-implementation fixes recommended (G-044-01, G-044-02) to align route-107 with the triple-file architecture convention and to make route-106's adaptation checklist explicit. These are low-effort route file edits, not plan restructures.

No blocking gaps. No standards violations. No missing critical files. The command itself (v1.1.0) was hardened in production — integration risk is low.

---

**Audit type**: Pre-implementation gap analysis  
**Generated by**: ACP `/acp-audit` #044
