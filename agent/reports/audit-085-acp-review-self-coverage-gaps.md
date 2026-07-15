# Audit Report: Can `/acp-review` Correctly Review ACP Enhanced?

**Audit**: #085  
**Date**: 2026-07-15  
**Subject**: `/acp-review` self-coverage — language scope, rule applicability, gaps vs actual codebase  
**Version**: 6.25.1  

---

## Summary

`/acp-review` **cannot correctly and completely review the ACP Enhanced codebase by itself** in its current v1.0.0 form. The command is **agent-executed only** (no companion scanners), **defaults to `src/`** (which does not exist in this repo), and its **54-rule ruleset is TypeScript/Web/Mobile-centric** while the codebase is predominantly **bash (131 `.sh`), YAML (68), and Markdown (1,128)** with only **10 TypeScript** files.

For ACP self-review, **Appendix A adds only 10 rules** — insufficient for 42 `agent/scripts/`, 59 E2E suites, 70 command docs, and 4 Python files. The only production review (`review-001`) manually scoped `scripts/ + agent/scripts/ + e2e/` and found 9 issues — it did **not** scan command docs, schemas, wiki, milestones, or the full E2E corpus.

**Verdict**: `/acp-review` is a **useful LLM-guided standards checklist for TS/JS application code**, but for ACP Enhanced it must be run with **explicit paths**, **category filtering**, and **paired with `/acp-validate` (structure) and `/acp-integrity` (trustworthiness)**. It is **not a standalone full-codebase gate**.

---

## Codebase vs Ruleset — Language Mismatch

| Asset class | File count | Primary `/acp-review` coverage |
|-------------|------------|--------------------------------|
| Markdown (commands, tasks, wiki) | ~1,128 | Appendix A only (3 rules: directive header, E2E existence, script naming) |
| Bash (`agent/scripts/`, `e2e/`, `tests/`) | ~131 + 59 E2E | Appendix A SH-01–04 (4 rules); EH/TS/NC/AP mostly N/A |
| YAML/YML (schemas, progress, routing) | ~68 | YM-01–03 (3 rules); no automated YAML rule engine |
| TypeScript (`scripts/*.ts`) | 10 | Full EH/TS/SC/CH rules apply |
| Python (`agent/scripts/*.py`, etc.) | 4 | **No rules** — v2.0 planned only for TS |

**Implication**: Running `/acp-review` with default `src/` on this repo reviews **nothing**. Even a “full” review applying all 54 rules leaves **~95% of files** outside meaningful rule coverage.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/commands/acp.review.md` | command | Rule definitions, Appendix A, default path |
| `agent/skills/code-review.md` | skill | Executor, chunking, workflow |
| `agent/commands/acp.validate.md` | command | Boundary vs review |
| `agent/commands/acp.integrity.md` | command | Companion trustworthiness scan |
| `e2e/acp.review.test.sh` | E2E | What is actually automated |
| `agent/reports/review-001-post-m63-v6-25-1.md` | report | Only executed self-review |
| `agent/milestones/milestone-55-acp-review-command.md` | milestone | Known gaps G-001–G-006 |
| `agent/wiki/domain.yml` | wiki | Rule count inconsistency |
| `README.md` | docs | Claims 77 rules |
| `scripts/acp-validate.ts` | tooling | Structural guards review does not run |

---

## Key Findings

| ID | Finding | Location | Severity | Notes |
|----|---------|----------|----------|-------|
| F-085-01 | Default path `src/` misses entire ACP Enhanced codebase | `acp.review.md:47` | HIGH | No `src/` directory exists; silent empty review |
| F-085-02 | Ruleset is TS/JS/Web/Mobile-first; bash/YAML/md bulk uncovered | `acp.review.md:33-37` | HIGH | M55 G-002 acknowledged; not resolved for self-review |
| F-085-03 | No deterministic review scripts (unlike `/acp-integrity`) | `acp.review.md:11` | HIGH | Quality depends entirely on agent thoroughness |
| F-085-04 | Appendix A only 10 rules for entire `agent/` tree | `acp.review.md:314-329` | HIGH | SH-01 flags 1 script in review-001; 4 sourced libs exempt; 59 E2E intentionally omit pipefail |
| F-085-05 | Rule ID collision: AP-01/02/03 used in Category 4 (API) and Appendix A (ACP) | `acp.review.md:139-147,327-329` | MEDIUM | Agents may mis-attribute findings |
| F-085-06 | Documented rule count inconsistent: 54 vs 77 vs 84 mentions | `README.md:319`, `domain.yml:386`, `acp.review.md:347` | MEDIUM | 84 unique ID tokens in doc; 3 IDs duplicated across categories |
| F-085-07 | E2E does not execute `/acp-review` — only greps command doc against fixtures | `e2e/acp.review.test.sh:107-163` | MEDIUM | M55 G-004 asked for behavioral `--ci` run; only partial smoke |
| F-085-08 | No CI workflow invokes `/acp-review` | `.github/workflows/` | MEDIUM | `weekly-code-review` recurring task is manual |
| F-085-09 | `review-001` scoped 3 dirs; skipped commands/schemas/wiki/milestones | `review-001:4` | MEDIUM | Not a full self-review |
| F-085-10 | WEB/MOB rules (EH-10/11, SC-06–23, NC-08/09) irrelevant to protocol repo | `acp.review.md` | LOW | Noise if applied literally |
| F-085-11 | Python files have zero review rules | `acp.pattern-scan.py`, etc. | MEDIUM | Integrity covers patterns; review does not |
| F-085-12 | `/acp-validate` covers structure; `/acp-review` does not duplicate guards | `acp-validate.ts` | INFO | Complementary, not redundant — but no orchestration doc for “full self-check” |
| F-085-13 | SH-02 (BSD sed) not in review scope; found via integrity | `acp.git-provenance.sh` | INFO | Example of gap between review and integrity |

---

## Can It Review “By Itself”? — Capability Matrix

| Question | Answer |
|----------|--------|
| Default invocation reviews ACP Enhanced? | **No** — `src/` empty |
| All languages in repo covered? | **No** — bash/YAML/md/python largely uncovered |
| Deterministic/reproducible? | **No** — LLM agent variance |
| Full codebase in one session? | **No** — skill chunks at >20 files; 200+ code files |
| E2E proves review works? | **No** — doc-structure tests only |
| CI enforces it? | **No** |
| Complements validate + integrity? | **Yes** — TS tooling quality + partial shell rules |

**Minimum viable self-review invocation for ACP Enhanced:**

```
/acp-review scripts/ agent/scripts/ --rules typescript,security,code-health
/acp-review agent/scripts/ --rules error-handling   # N/A for bash — use appendix-a manually
/acp-review agent/commands/ agent/core/ --rules naming,code-health  # weak coverage
/acp-validate && /acp-integrity --self --fast
```

---

## review-001 vs Full Self-Review Gap

| Area | review-001 scanned? | Rules that would apply |
|------|---------------------|------------------------|
| `scripts/*.ts` | ✅ | TS-*, SC-14, EH-* |
| `agent/scripts/*.sh` | ✅ (sampled) | SH-01–04 |
| `e2e/*.sh` | ✅ (fixture note only) | SH-01 (mostly waived) |
| `agent/commands/*.md` | ❌ | Appendix A AP-01/02 |
| `agent/schemas/*.yaml` | ❌ | YM-01 |
| `agent/core/*.yml` | ❌ | YM-03 (version) — validate handles |
| `agent/scripts/*.py` | ❌ | None |
| `agent/wiki/`, milestones | ❌ | None |

---

## Inconsistencies: Review Spec vs Codebase vs Docs

| Topic | Review spec says | Codebase reality | Doc elsewhere |
|-------|------------------|------------------|---------------|
| Default path | `src/` | No `src/` | — |
| Rule count | 54 + 10 appendix | README/wiki claim **77** | sessions.md also says 77 |
| AP-01 meaning | API envelope OR Agent Directive | Same ID, different rules | Collision |
| SC-15 lockfile | Committed lockfiles | `scripts/package-lock.json` gitignored (qualifier added) | Intentional per M55 G-001 |
| SH-01 pipefail | All `.sh` files | 4 sourced libs + 59 E2E omit by design | `acp.common.sh` is library |
| AP-02 E2E per command | Every command has E2E | validate reports 70/70 mapped | Tier-2/3 registry — review doesn't verify |
| Behavioral E2E | Run review on fixtures | E2E greps rule text in command doc | M55 G-004 partial |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/commands/acp.review.md:33-39` | Language Scope — TS-first; Appendix A auto-activation |
| `agent/commands/acp.review.md:47` | Default `[path]` → `src/` |
| `agent/commands/acp.review.md:139-147` | Category 4 AP-01–AP-09 (Web API) |
| `agent/commands/acp.review.md:314-329` | Appendix A — SH/YM/AP self-rules (AP ID collision) |
| `agent/skills/code-review.md:61-68` | Chunking >20 files — summary-first |
| `e2e/acp.review.test.sh:7` | Explicit: no `set -e` in E2E harness |
| `e2e/acp.review.test.sh:142-163` | Fixture smoke: grep command doc, not run review |
| `agent/reports/review-001-post-m63-v6-25-1.md:4` | Actual scope: scripts + agent/scripts + e2e |
| `scripts/acp-validate.ts` | `validateCommandE2eCoverage()` — structural, not quality |
| `agent/milestones/milestone-55-acp-review-command.md:47-50` | G-002 language gap — acknowledged, open |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| — | `ab54988` | M55 — `/acp-review` shipped (v6.11.0) |
| — | `72d03d8` | M56 — `/acp-integrity` companion (v6.12.0) |
| — | `bcd16c8` | Added Steps/Verification to review command doc |

---

## Recommendations

### P1 — Make self-review invocable correctly

1. Add `--self` flag (mirror integrity): default paths `scripts/`, `agent/scripts/`, `agent/commands/`, `e2e/`
2. Document “ACP Enhanced self-review recipe” in `acp.review.md`: review + validate + integrity trilogy

### P2 — Fix spec inconsistencies

3. Rename Appendix A `AP-01/02/03` → `ACP-01/02/03` (eliminate collision with API rules)
4. Reconcile rule counts: **64 distinct rule definitions** (54 core + 10 appendix, minus 3 ID duplicates) — update README/domain.yml/sessions (stop claiming 77 without definition)

### P3 — Expand or honest-scope bash/YAML coverage

5. Add **SH-05+** rules: sourced-library exemption list, E2E harness exemption, `shellcheck` gate
6. Add **PY-01+** or defer explicitly to integrity `pattern-scan` for Python

### P4 — Automation

7. Implement M55 G-004 fully: E2E invokes agent or script-backed rule checks on fixture dir with `--ci` exit code
8. Optional: `acp.review-scan.sh` for deterministic SC-01/SH-01/EH-02 grep passes (integrity model)

### P5 — Operational

9. Run chunked self-review: `scripts/` → `agent/scripts/` → `agent/commands/` (appendix rules only)
10. Track open CR-001..005 from review-001 separately (supply chain + TS + SH-01)

---

## Readiness Verdict (Audit Question)

**PARTIAL** — `/acp-review` can review **TypeScript tooling** and **spot-check bash** via Appendix A, but **cannot** serve as a complete, default, self-contained quality gate for the ACP Enhanced monorepo. Use explicit paths, category filters, and pair with `/acp-validate` + `/acp-integrity`.
