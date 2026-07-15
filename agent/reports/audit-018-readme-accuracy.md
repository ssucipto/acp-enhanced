# Audit Report: README Accuracy vs Project Implementation

**Audit**: #18  
**Date**: 2026-05-17  
**Subject**: README.md accuracy against current implementation (bootstrap steps, command counts, version coverage, milestone documentation)  

---

## Summary

README.md was reviewed against the current project state at v6.8.1 (commit `db56cfa`). The README is broadly accurate and well-structured, but four discrepancies were found — the most impactful being an incorrect bootstrap step count ("seven steps" vs actual eight) and missing documentation for the M43 (v6.8.1) release. Additionally, the bootstrap script itself has an internal counter inconsistency introduced when Step 8 was added in M41. All findings are low-to-medium severity and immediately actionable.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| README.md | doc | Primary audit subject |
| scripts/acp-bootstrap.sh | script | Step count and step descriptions |
| agent/commands/ (64 files) | source | Command count verification |
| .github/prompts/ (63 files) | config | Prompt file count |
| .opencode/commands/ (63 files) | config | opencode command count |
| agent/core/identity.yml | config | Version: 6.8.1 |
| package.yaml | config | Version and author metadata |
| CHANGELOG.md | doc | Feature coverage gap check |
| agent/wiki/domain.yml | doc | commands.count: 63 |
| agent/skills/ (7 files) | source | Skill file set |
| agent/routing/taxonomy.yml | config | shell-scripting task type |

---

## Key Findings

| ID | Finding | Location | Severity | Notes |
|----|---------|----------|----------|-------|
| F-001 | README says "runs in seven steps" — actual bootstrap has **8 numbered steps** | README.md:72 | Medium | Step 8 (`[8/8]`) = pre-commit hook install added in M41/route-032; README step list ends at 7 |
| F-002 | Bootstrap script internal counter inconsistency: steps `[1/7]`–`[6/7]` say `/7`, but steps 7–8 say `[7/8]` and `[8/8]` | scripts/acp-bootstrap.sh:20,35,176,273,359,529,1148,1168 | Low | Root cause: Step 8 was appended in M41 but only the last two counters were updated |
| F-003 | README "Recent Protocol Enhancements" header reads **"v6.4–v6.8"** — current version is **6.8.1**; M43 changes not documented | README.md:270 | Low | M43 adds: `shell-scripting` taxonomy entry, `checkStaleness` order fix, ledger header, `command-doc-write` threshold rule |
| F-004 | README lists "Skill files" as step 2 of bootstrap — actual script has **no separate step for skills**; skills are bundled in Step 3 (core layer files) | README.md:75 | Low | acp-bootstrap.sh:242-244: skills copied inside `[3/7]` block |
| F-005 | README bootstrap step 6 lists "opencode commands" as a discrete step — script uses `[6b/7]` sub-label (not a top-level step) | README.md:80, acp-bootstrap.sh:1129 | Info | Cosmetic: the echo label is `[6b/7]`, indicating it is a sub-step of 6, not an independent step |

---

## Key Decisions

- README "seven steps" text was accurate at the time of M39 but was not updated when M41/route-032 added the pre-commit hook as Step 8
- The bootstrap step counter bug (steps 1-6 saying `/7` while steps 7-8 say `/8`) is a script-level cosmetic issue — the steps all execute correctly regardless
- M43 (v6.8.1) is a patch release with targeted fixes; the README "Recent Protocol Enhancements" pattern covers milestones, so M43 merits a brief subsection

---

## Code Pointers

| Location | Description |
|----------|-------------|
| scripts/acp-bootstrap.sh:20 | `[1/7]` — directory structure creation |
| scripts/acp-bootstrap.sh:35 | `[2/7]` — AGENTS.md creation |
| scripts/acp-bootstrap.sh:176 | `[3/7]` — core layer files (includes skills at :242-244) |
| scripts/acp-bootstrap.sh:273 | `[4/7]` — memory + wiki stubs |
| scripts/acp-bootstrap.sh:359 | `[5/7]` — routing layer |
| scripts/acp-bootstrap.sh:529 | `[6/7]` — Copilot prompt files |
| scripts/acp-bootstrap.sh:1128 | `[6b/7]` — opencode commands (sub-step) |
| scripts/acp-bootstrap.sh:1148 | `[7/8]` — ACP commands, scripts, schemas |
| scripts/acp-bootstrap.sh:1168 | `[8/8]` — AGENTS.md pre-commit sync hook |
| README.md:72 | "This runs in seven steps:" — incorrect |
| README.md:75 | Step 2 listed as "Skill files" — no such dedicated step in script |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-02-11 | d540ffd | Initial: ACP version 1.0 |
| 2026-05-11 | f3d5f17 | feat(GAP-004): added Step 8 pre-commit hook to acp-bootstrap.sh |
| 2026-05-11 | b85393d | docs(GAP-003): documented git_workflow branch safety in README |
| 2026-05-11 | 263b3b2 | feat(OBS-004): Persona A defaults, M41 wrap-up [v6.7.0] |
| 2026-05-11 | 91560c4 | feat(M42): Dispatch Integrity + Validation Hardening [v6.8.0] |
| 2026-05-12 | df4dac7 | fix(M43/route-045): routing rules threshold + checkStaleness reorder [v6.8.1] |
| 2026-05-12 | db56cfa | chore: M43 session committed |

---

## Recommendations

1. **Fix README step count** (F-001): Update "seven steps" → "eight steps" and add Step 8 description ("Pre-commit hook — installs a git hook that auto-syncs AGENTS.md → CLAUDE.md + `.github/copilot-instructions.md` on every commit")
2. **Fix step 2 label** (F-004): Replace "Skill files" step in README with a more accurate grouping that reflects how the script actually works (skill files are part of Step 3 — core layer)
3. **Add M43 subsection** (F-003): Add a brief "M43 — Taxonomy + Validation Hygiene (v6.8.1)" section to "Recent Protocol Enhancements" covering the four v6.8.1 changes
4. **Fix bootstrap script counters** (F-002): Update steps `[1/7]` through `[6/7]` → `[1/8]` through `[6/8]` and `[6b/7]` → `[6b/8]` for consistency (separate script fix, not a README change)
5. **Update section header** (F-003): Change "v6.4–v6.8" → "v6.4–v6.8.1" in the Recent Protocol Enhancements header
