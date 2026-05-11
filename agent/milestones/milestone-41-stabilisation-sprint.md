<!-- @acp.meta.milestone
id: M41
title: Stabilisation Sprint — Audit-014 External Feedback Fixes
status: completed
tasks: route-022, route-023, route-024, route-025, route-026, route-027, route-028, route-029, route-030, route-031, route-032, route-033, route-034, route-035
completed: 2026-05-11
version_introduced: 6.7.0
feedback_source: agent/feedback/acp-enhanced-full-audit-v2.md
audit_source: agent/reports/audit-014-external-feedback-quality-and-improvement-plan.md
@acp.meta.end -->

# Milestone 41: Stabilisation Sprint

**Status**: Completed
**Completed**: 2026-05-11  
**Target Version**: 6.6.0 → 6.7.0  
**Feedback Source**: [acp-enhanced-full-audit-v2.md](../feedback/acp-enhanced-full-audit-v2.md) (Perplexity AI external audit)  
**Audit**: [audit-014](../reports/audit-014-external-feedback-quality-and-improvement-plan.md)  

---

## Overview

Addresses all 13 actionable findings from audit-014 (external Perplexity AI structural audit of ACP Enhanced v6.6.0). Two-phase sprint:

- **M41a — Bug Fixes** (routes 022–028): 4 critical/high bugs and 1 count discrepancy
- **M41b — Structural Gaps** (routes 029–035): 5 discoverability and platform gaps + 2 config updates

**Why this milestone must come first**: The external audit confirms core systems are production-quality. These are onboarding and distribution blockers — invisible to current users but critical for adoption. The productisation gate (audit-014 §5.4) requires all P1+P2 items complete before shipping to other developers.

---

## M41a — Bug Fixes (Routes 022–028)

### Route-022 — Fix sessions.md malformed YAML (BUG-001)
- [ ] Locate orphaned block at line ~151 (starts with `executor: copilot`, tasks `task-156/157/158`)
- [ ] Prepend correct `- date: 2026-05-05` header
- [ ] Verify `getLastNSessions()` split pattern `\n- date:` parses cleanly
- [ ] Entry has correct fields: date, executor, tasks, done, deferred, key_fact

### Route-023 — Fix HTTP-Referer in acp-dispatch.ts (BUG-002)
- [ ] Read `homepage` and `project` from `agent/core/identity.yml` at startup
- [ ] Replace hardcoded `"https://github.com/your-handle/your-repo"` with dynamic `repoUrl`
- [ ] Replace hardcoded `"ACP Enhanced Dispatch"` with dynamic `projectName`
- [ ] Fallback: `identity?.homepage ?? \`https://github.com/${identity?.repo ?? "ssucipto/acp-enhanced"}\``
- [ ] No new dependencies added

### Route-024 — Create acp.feedback.md (BUG-003a)
- [ ] `agent/commands/acp.feedback.md` created with standard command directive header
- [ ] `.github/prompts/acp-feedback.prompt.md` created (companion prompt)
- [ ] `.opencode/commands/acp-feedback.md` created (companion opencode file)
- [ ] Command covers: capture structured feedback, write `agent/feedback/feedback-NNN.md`, optionally trigger postmortem protocol
- [ ] Version 1.0.0, Created 2026-05-11

### Route-025 — Create acp.task.md (BUG-003b)
- [ ] `agent/commands/acp.task.md` created with standard command directive header
- [ ] `.github/prompts/acp-task.prompt.md` created
- [ ] `.opencode/commands/acp-task.md` created
- [ ] Command covers: create, read, list, update routing task files in `agent/routing/tasks/`
- [ ] Version 1.0.0, Created 2026-05-11

### Route-026 — Create acp.install.md (BUG-003c)
- [ ] `agent/commands/acp.install.md` created with standard command directive header
- [ ] `.github/prompts/acp-install.prompt.md` created
- [ ] `.opencode/commands/acp-install.md` created
- [ ] Command covers: invoking `acp.install.sh`; documents options (`--global`, `--local`, `--upgrade`)
- [ ] Version 1.0.0, Created 2026-05-11

### Route-027 — Create acp.dispatch.md (BUG-003d)
- [ ] `agent/commands/acp.dispatch.md` created with standard command directive header
- [ ] `.github/prompts/acp-dispatch.prompt.md` created
- [ ] `.opencode/commands/acp-dispatch.md` created
- [ ] Command covers: Persona B/C dispatch flow, pre-checks, `cd scripts && npx ts-node acp-dispatch.ts` invocation
- [ ] Version 1.0.0, Created 2026-05-11

### Route-028 — Update domain.yml command count (BUG-004)
- [ ] `agent/wiki/domain.yml` `commands.count: 58` → `59` (current verified count)
- [ ] Note added: "Will be 63 after route-024/025/026/027 create 4 new command docs"
- [ ] Verify count matches actual `.md` files in `agent/commands/`

---

## M41b — Structural Gaps (Routes 029–035)

### Route-029 — Remove duplicate package.json (GAP-001)
- [ ] `scripts/scripts-package.json` deleted (duplicate of `scripts/package.json`)
- [ ] Verify `scripts/package.json` still has all required dependencies

### Route-030 — Add QUICKSTART link to README (GAP-002)
- [ ] README hero section (top, above TOC or below badges) includes prominent link to `scripts/QUICKSTART.md`
- [ ] Text: `→ **New user? Start here**: [scripts/QUICKSTART.md](scripts/QUICKSTART.md) — full setup in 3–4 hours.`

### Route-031 — Document git_workflow in README + QUICKSTART (GAP-003)
- [ ] README: new `## Branch Safety` section added explaining Step 1b and `git_workflow:` config
- [ ] `scripts/QUICKSTART.md`: Step mentioning enabling `git_workflow:` in `identity.yml`
- [ ] Include the commented example block from audit-014 §GAP-003

### Route-032 — Pre-commit hook for AGENTS.md sync (GAP-004)
- [ ] `scripts/acp-bootstrap.sh`: new section that installs `.git/hooks/pre-commit`
- [ ] Hook: detects if `AGENTS.md` is staged → auto-copies to `CLAUDE.md` and `.github/copilot-instructions.md` → stages both
- [ ] Hook uses BSD-safe bash (no `set -e` without trap, no GNU-only flags)
- [ ] Idempotent: does not overwrite an existing hook without merging

### Route-033 — Add Windows/WSL install path (GAP-005)
- [ ] `README.md` Requirements section: adds Windows note (WSL2 required for shell scripts; TypeScript runs natively)
- [ ] `scripts/QUICKSTART.md`: adds Windows/WSL2 prerequisite step
- [ ] Content matches audit-014 §GAP-005 recommended wording

### Route-034 — Add last_verified to routing/config.yml (OBS-002)
- [ ] Each model entry in `agent/routing/config.yml` gets `last_verified: 2026-05-11`
- [ ] Comment added: `# Update last_verified whenever prices are checked`

### Route-035 — Set Persona A defaults in routing.yml + wrap-up (OBS-004)
- [x] `agent/core/routing.yml`: `executor: copilot`, `model: github-copilot` (from `unset`)
- [x] Comment preserved: "updated by acp-dispatch.ts at runtime" — Persona B/C will overwrite
- [x] Version bumped 6.6.0 → 6.7.0 (identity.yml, package.yaml, AGENT.md, progress.yaml)
- [x] `CHANGELOG.md`: [6.7.0] entry added for M41
- [x] `agent/progress.yaml`: M41 status → completed (14/14), `domain.yml` count updated to 63
- [x] `agent/wiki/domain.yml`: 4 new commands documented (feedback, task, install, dispatch)
- [x] `agent/wiki/architecture.md`: AGENTS.md sync hook documented
- [x] Route files 022–035 stamped `completed: [date]`

---

## Success Criteria

- [ ] All 13 audit-014 carryover items marked `status: fixed`
- [ ] `/acp-validate` passes clean — zero errors on command count
- [ ] `sessions.md` malformed entry fixed — manual inspection confirms `\n- date:` parses cleanly
- [ ] `HTTP-Referer` reads dynamically from `identity.yml` — no placeholder string remains
- [ ] 4 new command docs exist with prompt + opencode companions (12 total files)
- [ ] `scripts/scripts-package.json` deleted
- [ ] README links to QUICKSTART prominently
- [ ] Pre-commit hook installs via bootstrap
- [ ] Windows/WSL documented in README + QUICKSTART
- [ ] `routing/config.yml` has `last_verified:` on all model entries
- [ ] `routing.yml` ships with `executor: copilot` as Persona A default

---

## Productisation Gate Completion

After M41, the productisation checklist (audit-014 §5.4) should read:

| Item | Status |
|------|--------|
| Clean install < 15 min on macOS, Linux, WSL2 | ✅ (WSL docs added) |
| README links directly to QUICKSTART | ✅ (route-030) |
| All 4 missing command docs exist | ✅ (routes 024–027) |
| `/acp-validate` passes clean | ✅ (route-028 + route-035) |
| `sessions.md` malformed entry fixed | ✅ (route-022) |
| `HTTP-Referer` reads from `identity.yml` | ✅ (route-023) |
| Pre-commit hook auto-installs via bootstrap | ✅ (route-032) |
| `git_workflow` documented | ✅ (route-031) |
| E2E tests pass on macOS CI + Linux CI | ⬜ (existing CI from M13) |
| `audit-carryovers.md` items resolved | ✅ (route-035 verification) |
