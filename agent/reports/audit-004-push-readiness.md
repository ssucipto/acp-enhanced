# Audit Report: Push Readiness — All Sectors

**Audit**: #004  
**Date**: 2026-05-04  
**Subject**: Is the codebase ready to push to GitHub mainline? Check README, CHANGELOG, bootstrap safety, test coverage, git hygiene, and any remaining inconsistencies.

---

## Summary

Pre-push audit across 6 sectors: documentation accuracy, changelog completeness, bootstrap idempotency, E2E test coverage, git staging hygiene, and tool consistency. Found **4 issues**, all resolved. Pre-existing E2E test failures (8 tests, 6 timeouts + 2 functional) confirmed pre-existing — not introduced by M27/M28 changes. Repository is ready to push.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `README.md` | doc | Primary project documentation — checked for accuracy |
| `CHANGELOG.md` | doc | Version history — checked for completeness |
| `scripts/acp-bootstrap.sh` | shell | Fresh install script — checked for idempotency |
| `agent/scripts/acp.version-update.sh` | shell | Update script — already fixed in audit-003 |
| `agent/scripts/acp.install.sh` | shell | Install script — already correct |
| `e2e/acp.opencode-commands.test.sh` | test | opencode parity test — 351 assertions |
| `.gitignore` / `agent/.gitignore` | config | Verified `.opencode/` not gitignored |
| `run-e2e-tests.sh` | test | Full E2E suite runner |

---

## Key Findings

| Finding | Severity | Location | Status |
|---------|----------|----------|--------|
| README referenced removed `@acp.*` notation (e.g. `@acp.init`, `@acp.resume`) | High | `README.md:67,392,435-440` | ✅ Fixed |
| README used `@git.commit`, `@git.init` (invalid — opencode uses @ for file refs) | Medium | `README.md:481-482` | ✅ Fixed |
| README had no mention of opencode or `.opencode/commands/` | Medium | `README.md` "VS Code Copilot" section | ✅ Fixed — new per-tool table |
| CHANGELOG missing M27 and M28 entries | High | `CHANGELOG.md` — last entry was 6.3.0 | ✅ Fixed — 6.4.0 added |
| `scripts/acp-bootstrap.sh` overwrites `agent/memory/*.md` unconditionally on re-run | Critical | `bootstrap.sh:267-293,509` | ✅ Fixed — `[ -f ] \|\|` guards added |
| `scripts/acp-bootstrap.sh` overwrites `agent/core/identity.yml` unconditionally | Medium | `bootstrap.sh:177` | ✅ Fixed — `[ -f ] \|\|` guard added |
| 8 pre-existing E2E failures (6 timeouts, 2 functional) | Low | `run-e2e-tests.sh` | ⚠️ Pre-existing — confirmed by git stash test |
| `.opencode/` directory untracked — needs staging | Info | `git status` | → Action required before push |

---

## Bootstrap/Install Safety — Answer

| Script | Re-run safe? | What it overwrites | What it preserves |
|--------|-------------|-------------------|-------------------|
| `scripts/acp-bootstrap.sh` (before fix) | ❌ No | memory/*.md, identity.yml, routing/ledger.md | wiki, routing static files |
| `scripts/acp-bootstrap.sh` (after fix) | ✅ Yes | Static ACP files (commands, scripts, skills, wiki, routing taxonomy) | memory/*.md, identity.yml, routing/ledger.md |
| `agent/scripts/acp.install.sh` | ✅ Yes | Static ACP files | memory files via `_create_if_absent` helper |
| `agent/scripts/acp.version-update.sh` | ✅ Yes | Static ACP files, commands, scripts | memory files via `[ -f ] \|\|` guards |

**Bottom line**: Re-running bootstrap or install does **not** delete your `agent/memory/`, `agent/routing/ledger.md`, or `agent/core/identity.yml`. Only static ACP framework files (commands, scripts, core config) are overwritten — never your project data.

---

## Key Decisions

- `@acp.*` notation is permanently retired — it was an opencode anti-pattern (@ in opencode = file reference, not command). Replaced with per-tool table in README.
- Bootstrap idempotency rule: any file containing user state must use `[ -f ] || cat >` pattern, not bare `cat >`.
- Version bump: M27+M28 together → 6.4.0. Both milestones are distribution-facing changes.

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `README.md:63` | New "Slash Commands" section — per-tool invocation table |
| `scripts/acp-bootstrap.sh:267` | Memory file guards: `[ -f agent/memory/sessions.md ] \|\| cat >` |
| `scripts/acp-bootstrap.sh:177` | identity.yml guard: `[ -f agent/core/identity.yml ] \|\| cat >` |
| `CHANGELOG.md:10` | 6.4.0 entry with M27+M28 |

---

## E2E Test Status

| Test file | Status | Notes |
|-----------|--------|-------|
| `e2e/acp.opencode-commands.test.sh` | ✅ 351/351 pass | New this session |
| `e2e/acp.command-docs.test.sh` | ✅ Pass | Pre-existing |
| `e2e/acp.version.test.sh` | ✅ Pass | Pre-existing |
| `e2e/acp.project-update.test.sh` | ❌ 18/20 | Pre-existing bug — 2 tag-related assertions |
| `e2e/acp.experimental-features.test.sh` | ⏱️ Timeout | Pre-existing — network-dependent |
| `e2e/acp.index.test.sh` | ⏱️ Timeout | Pre-existing |
| `e2e/acp.package-install-list.test.sh` | ⏱️ Timeout | Pre-existing — network-dependent |
| `e2e/acp.script-command-binding.test.sh` | ⏱️ Timeout | Pre-existing |
| `e2e/acp.template-files.test.sh` | ⏱️ Timeout | Pre-existing |

All failures confirmed pre-existing via `git stash` before/after comparison.

---

## Git Staging Required Before Push

```bash
git add .opencode/
git add e2e/acp.opencode-commands.test.sh
git add AGENT.md CHANGELOG.md README.md
git add agent/scripts/acp.install.sh agent/scripts/acp.version-update.sh
git add agent/wiki/architecture.md agent/wiki/domain.yml
git add scripts/acp-bootstrap.sh
git commit -m "feat(v6.4.0): M27+M28 opencode parity, README accuracy, bootstrap idempotency"
```

---

## Recommendations

1. **Merge pre-existing test failures as known issues** — open a tracking task for `acp.project-update` tag bug and timeout-heavy tests.
2. **Add bootstrap re-run notice to README** — document that re-running is safe (now true after this fix).
3. **Consider `.opencode/` in install section of README** — mention it appears after bootstrap alongside `.github/prompts/`.
