# Audit Report: Post-Push Implementation Review

**Audit**: #007  
**Date**: 2026-05-05  
**Subject**: All changes since last push to `origin/mainline` (`a26d565`) — commits `1f73b24`, `67f3ff2`, `58259bc`  
**Scope**: Regression, compatibility, correctness, lost functionality, and consistency  

---

## Summary

Three commits were made since the last push, closing two milestones: **M30** (Drafts Convention Fix, live bug) and **M34** (Command Naming Convention, pure docs). 16 files changed, 246 insertions, 27 deletions.

All e2e tests that were passing before the changes still pass. The new `acp.drafts.test.sh` (7/7 assertions) confirms the M30 fix is end-to-end correct. No functionality was lost or reverted.

**One actionable bug was discovered** during the audit: `acp.project-create.md` still embeds the old `agent/drafts/` (bare) gitignore pattern that was fixed everywhere else. This is a missed application of the `install-script-gitignore-heredoc-sync` pattern. Two additional lower-priority structural findings are noted.

---

## Files Analyzed

| File | Type | Change | Relevance |
|------|------|--------|-----------|
| `agent/.gitignore` | config | modified | Core fix: `drafts/` → `drafts/**` + exceptions |
| `agent/scripts/acp.install.sh` | script | modified | Install path: adds drafts .gitkeep + heredoc fix |
| `scripts/acp-bootstrap.sh` | script | modified | Bootstrap path: adds `mkdir -p agent/drafts` + template copy |
| `AGENT.md` | doc | modified | Directory tree: adds `drafts/` entry |
| `agent/drafts/.gitkeep` | sentinel | new | Ensures dir tracked in git |
| `agent/drafts/draft.template.md` | template | new | 3-question draft template for `/acp-plan` |
| `e2e/acp.drafts.test.sh` | test | new | 7-assertion E2E for drafts convention |
| `agent/memory/patterns.md` | memory | modified | Two new patterns added |
| `agent/patterns/local.command-naming-convention.md` | pattern | new | Canonical naming reference doc |
| `agent/skills/commands.md` | skill | modified | Naming convention callout added at top |
| `agent/memory/lessons.md` | memory | modified (unstaged) | +1 line cross-ref to pattern doc |
| `agent/progress.yaml` | state | modified | M30 + M34 marked complete |
| `agent/commands/acp.project-create.md` | command | NOT changed | Contains stale `agent/drafts/` bare pattern — **BUG** |

---

## Key Findings

| # | Severity | Finding | Location | Notes |
|---|----------|---------|----------|-------|
| 1 | **HIGH** | `acp.project-create.md` embeds bare `agent/drafts/` in its sample `.gitignore` template | [acp.project-create.md:292](../commands/acp.project-create.md) | Same bug fixed everywhere else. New projects created via `/acp-project-create` will have broken drafts gitignore. Exception rules `!drafts/.gitkeep` won't work. |
| 2 | MEDIUM | `agent/memory/lessons.md` is gitignored but still tracked by git | `agent/.gitignore` line 30 | Was committed before the gitignore rule was applied. `git rm --cached` never run. Shows as modified in `git status`. Same for `decisions.md`. Pre-existing, not introduced here. |
| 3 | LOW | `agent/memory/lessons.md` task-177 change (+1 line cross-ref) is unstaged and not committed | Working tree only | Intentional by gitignore design, but creates disconnect: task claims "update lessons.md" but change is purely local and ephemeral. Will be lost on `git stash` or new clone. |
| 4 | INFO | `local-star-exclusion-case-loop` pattern references `task-184` — looks unfamiliar | [patterns.md:9](../memory/patterns.md) | Valid. task-184 exists in M29 (completed prior session). Pattern is accurate. |
| 5 | INFO | 4 pre-existing e2e failures: `acp.project-update` (Should confirm tag added, Should detect duplicate) and `acp.project-workflow` (Should update/remove successfully) | `e2e/` | Confirmed pre-existing — identical failures when running against HEAD with or without local changes. Not introduced by M30/M34. |
| 6 | INFO | 6 e2e timeout failures (acp.experimental-features, acp.index, acp.package-install-list, acp.package-search, acp.script-command-binding, acp.template-files) | `e2e/` | Pre-existing timeouts. Not introduced by M30/M34. |

---

## Correctness Verification

### M30 — Drafts Convention Fix

| Check | Result |
|-------|--------|
| `agent/drafts/.gitkeep` exists and is tracked | ✅ |
| `agent/drafts/draft.template.md` exists and is tracked | ✅ |
| `agent/.gitignore` uses `drafts/**` (not bare `drafts/`) | ✅ |
| `agent/.gitignore` has `!drafts/.gitkeep` exception | ✅ |
| `agent/.gitignore` has `!drafts/draft.template.md` exception | ✅ |
| `acp.install.sh` heredoc matches `agent/.gitignore` | ✅ |
| `acp.install.sh` creates `drafts/.gitkeep` via `touch` | ✅ |
| `acp.install.sh` copies `draft.template.md` idempotently | ✅ |
| `scripts/acp-bootstrap.sh` creates `agent/drafts/` dir | ✅ |
| `scripts/acp-bootstrap.sh` copies draft template idempotently | ✅ |
| `AGENT.md` directory tree includes `drafts/` in correct alpha order | ✅ |
| `e2e/acp.drafts.test.sh` all 7 assertions pass | ✅ 7/7 |
| `acp-plan.md` actually uses `agent/drafts/` (end-to-end) | ✅ |
| **`acp.project-create.md` heredoc updated** | ❌ MISSED |

### M34 — Command Naming Convention

| Check | Result |
|-------|--------|
| Pattern doc has valid YAML frontmatter | ✅ |
| Triple-file architecture table (3 rows) | ✅ |
| Invocation format table present | ✅ |
| Anti-patterns with ❌/✅ examples | ✅ |
| Upstream porting rule documented | ✅ |
| File ≤70 lines (62 actual) | ✅ |
| `agent/skills/commands.md` has naming callout at top | ✅ line 4 |
| `agent/memory/lessons.md` @acp-foo entry cross-references pattern doc | ✅ (local only — not committed) |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| [agent/.gitignore:8-10](../gitignore) | `drafts/**` + exception rules (fixed) |
| [agent/scripts/acp.install.sh:130](../scripts/acp.install.sh) | `touch "$TARGET_DIR/agent/drafts/.gitkeep"` |
| [agent/scripts/acp.install.sh:144-148](../scripts/acp.install.sh) | Heredoc with `drafts/**` + exceptions |
| [agent/scripts/acp.install.sh:234-236](../scripts/acp.install.sh) | Idempotent draft template copy |
| [scripts/acp-bootstrap.sh:29](../../scripts/acp-bootstrap.sh) | `mkdir -p agent/drafts` |
| [scripts/acp-bootstrap.sh:266-270](../../scripts/acp-bootstrap.sh) | Draft template copy from `$SCRIPT_DIR/../agent/drafts/` |
| [agent/commands/acp.project-create.md:292](../commands/acp.project-create.md) | **BUG: bare `agent/drafts/`** — needs `agent/drafts/**` + exceptions |
| [agent/patterns/local.command-naming-convention.md:1](../patterns/local.command-naming-convention.md) | New canonical naming reference |
| [agent/skills/commands.md:2-6](../skills/commands.md) | Naming convention callout block |
| [AGENT.md:224-226](../../AGENT.md) | `drafts/` entry in directory tree (alphabetically between clarifications/ and feedback/) |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-05 | `1f73b24` | fix(M30): create agent/drafts/ directory — resolves live bug in /acp-plan |
| 2026-05-05 | `67f3ff2` | fix(M30): complete drafts convention — install scripts + AGENT.md + e2e test |
| 2026-05-05 | `58259bc` | feat(M34): command naming convention pattern doc + skills cross-reference |

---

## Recommendations

1. **[HIGH — fix before push] `acp.project-create.md` line 292**: Change `agent/drafts/` to `agent/drafts/**` and add two exception lines `!agent/drafts/.gitkeep` and `!agent/drafts/draft.template.md`. Applies the same `install-script-gitignore-heredoc-sync` pattern. New projects from `/acp-project-create` currently get a broken drafts gitignore.

2. **[MEDIUM — future task] Untrack gitignored memory files**: `agent/memory/lessons.md` and `agent/memory/decisions.md` are in `.gitignore` but still tracked by git (`git rm --cached` was never run after the gitignore rule was added in `d32a0d9`). They show as modified in `git status` and their content (instance-specific) leaks into remote history. Consider a cleanup commit running `git rm --cached agent/memory/lessons.md agent/memory/decisions.md`.

3. **[LOW — note for future]** When the `lessons.md` task-177 cross-reference is truly ephemeral (only in working tree), update the task's success criteria to reflect that lessons.md changes are local-only and will not appear in git history. Prevents false confirmation of "committed" status.

4. **[INFO] Pre-existing test failures** (4 functional + 6 timeout): Tracked as known-failing, not introduced by M30/M34. Recommend opening a dedicated milestone to address the 6 timeout tests (likely network-dependent package tests) and the 2 project-update tag/duplicate assertion failures.
