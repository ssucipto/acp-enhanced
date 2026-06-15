# Audit Report: ACP Enhanced — Complete Consolidated Audit & Production-Readiness Roadmap

**Audit**: #067  
**Date**: 2026-06-15  
**Subject**: Complete audit consolidating audit-065 (breadth) + audit-066 (TS/CI deep-dive) + new coverage of distribution, version consistency, integrity scripts, and test quality. Final gap register + production-readiness scorecard + phased roadmap for startup adoption.  
**Supersedes for planning**: audit-065, audit-066 (this report is the single source of truth for the improvement roadmap)

---

## Summary

This is the third and consolidating audit. Round 1 (065) surveyed breadth; round 2 (066) validated round 1 and opened the TypeScript/CI internals. This round (067) closes the remaining coverage gaps — **distribution/packaging, version consistency, integrity-script quality, YAML parser robustness, and E2E test quality** — and merges all three rounds into one authoritative gap register and roadmap.

**Net state of ACP Enhanced v6.12.1**: The protocol design is mature and the bash/parser foundation is sound (the June-7 YAML-parser EXIT-trap fix is correctly applied — verified, no regression). The blockers to confident startup adoption are concentrated in five areas: (1) a data-loss bug in dispatch, (2) CI that doesn't actually validate structure, (3) 68% of commands untested, (4) packaging drift that would ship a broken install, and (5) missing production-readiness scaffolding (branch protection, SECURITY.md, Windows CI).

This round adds **5 new findings** (1 High packaging, 3 Medium, 1 Low) and **1 positive confirmation**. Combined with prior rounds, the consolidated register holds **30 distinct open findings**.

---

## Part A — New Findings (this round)

### Distribution & Packaging

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| HIGH-067-001 | **13 command docs are absent from `package.yaml`** — they would NOT be distributed via `/acp-package-install` | `package.yaml` | High |

**HIGH-067-001 detail**: `package.yaml` declares 63 commands; 68 command files exist. The 13 unpackaged commands include core workflow verbs:
`acp.commit`, `acp.decide`, `acp.dispatch`, `acp.route`, `acp.task`, `acp.feedback`, `acp.visualize`, `acp.wiki-update`, `acp.carryover-query`, `acp.cost-report`, `acp.memory-sync`, `acp.pattern-sync`, `acp.session-sync`.

A user installing ACP Enhanced as a *package* (not via the bootstrap curl, which copies the whole dir) would get a framework missing `/acp-commit`, `/acp-decide`, `/acp-route`, and `/acp-dispatch` — i.e., a non-functional install. This also breaks `/acp-package-validate`'s script-command binding check premise. Note: bootstrap installs are unaffected (they copy the entire `agent/commands/` tree), which is why this has gone unnoticed.

### Version & Documentation Consistency

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| MED-067-002 | `AGENTS.md` version header reads **v6.10.0** while project is at **6.12.1** — the auto-loaded context file is 2 minors stale. The three "synced" files are not byte-identical (AGENTS.md carries an extra `> v6.10.0` header line absent from CLAUDE.md / copilot-instructions.md) | `AGENTS.md:3` | Medium |
| MED-067-005 | No `CONTRIBUTING.md` despite being a public fork inviting contribution | repo root | Medium |

**MED-067-002 detail**: `lessons.md` already records (2026-06-04) that "version bumps MUST update 8 files" and that no automated consistency check existed pre-`/acp-validate` v2.3.0. This finding confirms the check is still not catching the AGENTS.md header — the `/acp-validate` Step 2c consistency check either doesn't run in CI (see HIGH-066-005) or doesn't inspect the prose version header. The three-copy sync (pre-commit hook) keeps the *body* identical but AGENTS.md has a divergent header.

### Test & Script Quality

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| MED-067-003 | E2E integrity test counts rules with `grep -cE '^\| IG-\d+'` — `\d` is **not a digit class in POSIX ERE** (GNU `grep -E`); it matches literal `d`. Rule count is miscomputed; the `>= 55` assertion is unreliable/non-portable | `e2e/acp.integrity.test.sh:32` | Medium |
| LOW-067-004 | `acp.git-provenance.sh` parses `team_members` with `grep`/`while read` instead of the project's YAML parser — violates the `scripts.md` rule "Never parse YAML with grep/sed/awk" | `agent/scripts/acp.git-provenance.sh:42` | Low |

### Positive Confirmation

| ID | Finding | Location | Verdict |
|----|---------|----------|---------|
| POS-067-A | YAML parser EXIT-trap data-loss bug (June-7 lesson) is **correctly fixed** — no `trap cleanup_ast EXIT` remains; cleanup happens in `init_ast()` per the documented fix | `agent/scripts/acp.yaml-parser.sh:1020-1022` | ✅ No regression |

---

## Part B — Consolidated Gap Register (all three rounds, deduplicated)

Severity reflects audit-066 reclassifications. Status as of this audit.

### Critical (2)

| ID | Finding | Source | Status |
|----|---------|--------|--------|
| C1 | No branch protection on `mainline`/`develop` | 065 (CRIT-065-002) | Open |
| C2 | 46 of 68 commands (68%) have no E2E test | 065 (CRIT-065-003) | Open |

### High (8)

| ID | Finding | Source | Status |
|----|---------|--------|--------|
| H1 | `updateRoutingYml()` overwrites `core/routing.yml` — destroys context_modes/command_suggestions | 066 | Open |
| H2 | `acp-validate.ts` never wired into CI | 066 | Open |
| H3 | `ci-validate.sh` frontmatter check is a no-op for command files | 066 | Open |
| H4 | 17 scripts use bare `set -e` not `set -euo pipefail` | 065 | Open |
| H5 | No Windows CI runner (documented target platform) | 065 | Open |
| H6 | No `SECURITY.md` / disclosure process | 065 | Open |
| H7 | `acp.integrity.md` + `acp.review.md` missing `## Steps` section | 065 | Open |
| H8 | 13 command docs absent from `package.yaml` (broken package install) | 067 | Open |

### Medium (13)

| ID | Finding | Source | Status |
|----|---------|--------|--------|
| M1 | This project never ran `/acp-decide` — its ADR history is uncaptured (gitignored file, not missing storage) | 065→066 reclass | Open |
| M2 | 5 commands missing `## Verification` section | 065 | Open |
| M3 | No CODEOWNERS | 065 | Open |
| M4 | `team_members: []` disables IG-37 author verification | 065 | Open |
| M5 | No Dependabot/Renovate | 065 | Open |
| M6 | No PR/issue templates | 065 | Open |
| M7 | No `package-lock.json` in `scripts/` | 065 | Open |
| M8 | No SAST/secret-scan in CI | 065 | Open |
| M9 | `OPENROUTER_API_KEY` non-null assertion — no preflight | 066 | Open |
| M10 | No unit tests for TS tooling (`scripts/*.test.ts` = 0) | 066 | Open |
| M11 | No schemas for memory-layer entities; existing schemas not enforced | 066 | Open |
| M12 | AGENTS.md version header stale (v6.10.0); sync files not byte-identical | 067 | Open |
| M13 | E2E integrity test `\d` regex invalid in ERE; no CONTRIBUTING.md | 067 | Open |

### Low (4)

| ID | Finding | Source | Status |
|----|---------|--------|--------|
| L1 | `network_whitelist.yml` empty `reviewed_by` | 065 | Open |
| L2 | `routing.yml` holds dynamic session state in static file | 065 | Open |
| L3 | dispatch parses sessions/lessons via string-split not YAML parser | 066 | Open |
| L4 | `git-provenance.sh` parses YAML with grep | 067 | Open |

### Resolved (closed this audit cycle)

| ID | Finding | Resolution |
|----|---------|------------|
| R1 | BUG-045-01/02/03 bootstrap bugs | Fixed in M51, marked fixed in audit-065 cycle |
| R2 | YAML parser EXIT-trap data loss | Fixed June-7, verified no regression (POS-067-A) |
| R3 | integrity-001 findings (IG-41/42/67/68) | Fixed in integrity-002 verification |

**Totals: 2 Critical, 8 High, 13 Medium, 4 Low = 27 open** (+ 3 resolved).

---

## Part C — Production-Readiness Scorecard (startup engineering tool)

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| **Context system** | 🟢 Strong | Light/full modes, tiered budget, dual-store memory — mature and well-documented |
| **Verification (CI)** | 🔴 Weak | CI runs YAML lint + shellcheck only; structural validator orphaned (H2/H3); no SAST (M8) |
| **Code quality (scripts)** | 🟡 Fair | Good patterns documented; 17 scripts non-conforming (H4); YAML-via-grep (L4) |
| **Code quality (TS)** | 🟡 Fair | Clean code, but a data-loss bug (H1) and zero unit tests (M10) |
| **Code integrity** | 🟢 Strong | `/acp-integrity` v1.0 with 55 rules + 6 scripts; whitelist; manifest hashing. IG-37 disabled (M4) |
| **Testing** | 🔴 Weak | 68% commands untested (C2); test-quality bugs (M13); no TS tests (M10) |
| **Security posture** | 🟡 Fair | Actions pinned, --ignore-scripts done; but no SECURITY.md (H6), no branch protection (C1), no secret-scan (M8) |
| **Distribution** | 🔴 Weak | package.yaml would ship a broken install missing 13 core commands (H8) |
| **Documentation** | 🟢 Strong | Extensive README, QUICKSTART, wiki, skills. Version-header drift (M12) |
| **Usability/onboarding** | 🟢 Strong | Bootstrap one-liner, Cursor/Copilot/opencode parity, slash commands, visualizer |
| **Cross-platform** | 🟡 Fair | macOS/Linux handled well; Windows documented but untested in CI (H5); LF enforced |
| **Governance** | 🔴 Weak | No CODEOWNERS (M3), no CONTRIBUTING (M13), no PR templates (M6), no branch protection (C1) |

**Overall**: 🟡 **Beta-quality.** Strong protocol and UX core; **not yet production-ready** for a startup to depend on until the red dimensions (Verification, Testing, Distribution, Security governance) are closed.

---

## Part D — Consolidated Phased Roadmap

Ordered by leverage (highest impact per hour first). Each phase maps to a proposed milestone.

### M59 — Critical-Fix & CI Integrity Track (~10h)
*Goal: stop active bugs and make the pipeline trustworthy*
1. **H1** Fix `updateRoutingYml()` → surgical session-block update + regression test (2h)
2. **H8** Add the 13 missing commands to `package.yaml`; add a CI check that `package.yaml` command count == file count (2h)
3. **H2 + H3** Wire `acp-validate.ts` into CI; fix `ci-validate.sh` to validate command-doc structure (3h)
4. **C1** Enable branch protection on `mainline` + `develop` (15 min)
5. **M9** Add `OPENROUTER_API_KEY` preflight check (30 min)
6. **M12** Fix AGENTS.md version header + add version-header to `/acp-validate` consistency check (1h)

### M60 — Test Coverage Sprint, Tier 1 (~14h)
*Goal: no core command without a smoke test*
1. **C2 (tier 1)** E2E for 8 core commands: init, proceed, plan, dispatch, commit, validate, audit, route (12h)
2. **M13** Fix integrity test `\d` regex; add CONTRIBUTING.md (2h)

### M61 — Production-Readiness Pack (~12h)
*Goal: governance + security table stakes*
1. **H5** Windows CI runner (2h)
2. **H6** SECURITY.md (1h)
3. **M3 + M6** CODEOWNERS + PR/issue templates (1.5h)
4. **M5 + M7 + M8** Dependabot + package-lock.json + npm audit/secret-scan in CI (4h)
5. **M4** Populate `team_members`; enable IG-37 (30 min)
6. **M10** TS unit tests for dispatch + validate (3h)

### M62 — Quality Hardening + Schema Coverage (~12h)
1. **H4** Upgrade 17 scripts to `set -euo pipefail` (3h)
2. **H7 + M2** Add `## Steps`/`## Verification` to non-conforming commands (3h)
3. **M11** Memory-layer schemas + enforce in validator (4h)
4. **L1–L4** Low-severity cleanups (2h)

### M63 — Test Coverage Sprint, Tier 2+3 (~12h)
1. **C2 (tier 2/3)** E2E for remaining ~38 untested commands (12h)

### Parallel / ongoing
- **M1** Run `/acp-decide` to capture this project's key ADRs (de-prioritized, do alongside M59 design work)
- **M58 (active)** route-156 `/acp-integrity v2.0` — continue independently

**Total roadmap effort**: ~60h across M59–M63, plus active M58.

---

## Recommendations

1. **Sequence is the message**: do M59 first. Three of its items (H1, H8, H2/H3) are silent correctness bugs — a data-loss bug, a broken package install, and a validation pipeline that doesn't validate. Fixing them costs ~7h and removes the highest-risk surprises.
2. **H8 (package.yaml drift) is the cheapest high-value fix** — 13 lines + a guard test prevents shipping a broken framework to any package-install adopter.
3. **Make CI the enforcement layer** (H2/H3): once the validator runs in CI, findings H7, M2, M12, and future drift become self-detecting — converting recurring manual audit work into automated gates.
4. **Treat the scorecard's red cells as the definition of "done" for production readiness**: Verification, Testing, Distribution, Governance. When those four reach 🟡+, ACP Enhanced is startup-dependable.
5. **Adopt the consolidated register (Part B) as the canonical backlog** — supersede the separate 065/066 carryover lists with this single deduplicated view to avoid double-tracking.
6. **Keep the audit cadence but rotate focus**: 065 (breadth) → 066 (depth) → 067 (consolidation) is a good 3-pass model. The next audit should be a *post-implementation verification* after M59 ships, not another discovery pass.

---

## Next Steps for Developer

| Priority | Action | Effort | ID |
|----------|--------|--------|-----|
| P0 | Fix `updateRoutingYml()` overwrite + regression test | 2h | H1 |
| P0 | Add 13 missing commands to package.yaml + count-guard CI check | 2h | H8 |
| P0 | Wire `acp-validate.ts` into CI + fix `ci-validate.sh` no-op | 3h | H2/H3 |
| P0 | Enable branch protection | 15 min | C1 |
| P1 | E2E Tier 1 (8 core commands) | 12h | C2 |
| P1 | Continue M58 route-156 | 4h | active |
| P2 | Production-readiness pack (SECURITY, Windows CI, governance) | 12h | M61 |
| P2 | `set -euo pipefail` + structural section fixes | 6h | H4/H7/M2 |
| P3 | Schema coverage, TS tests, low-sev cleanups | 18h | M11/M10/L* |
