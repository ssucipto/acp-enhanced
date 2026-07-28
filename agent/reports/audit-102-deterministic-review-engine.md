# Audit Report: Deterministic Code Review Engine (`/acp-review` Phase 1 expansion + duplicate detection)

**Audit**: #102
**Date**: 2026-07-27
**Subject**: `/acp-review` deterministic capability — what exists, what is buildable, and whether to adopt dupehound-style duplicate detection
**Trigger**: CodeRabbit rate limiting (M82 F-M82-06) forces review to happen locally
**Executor**: claude-opus-5

---

## Summary

M82 proved the operational thesis: CodeRabbit's CLI rate-limited after **2 of 4** chunks, so the local layer is not a fallback — it is the primary review path. This audit asked what that local layer actually delivers today.

Two things came out of it. First, `/acp-review`'s Phase 1 scanner has a **scope bug that silently discards every path but the last one**. The self-review recipe printed in the command doc (`acp.review-scan.sh --ci scripts/ agent/scripts/`) has therefore only ever scanned `agent/scripts/`. Scanning `scripts/` on its own surfaces **2 previously-invisible HIGH findings**, one of them in the `curl | bash` bootstrap script. M82's "Phase 1 clean" result was, in part, an artifact of this bug.

Second, the documented Phase 1/Phase 2 split (8 deterministic / 56 "cannot be scripted") **understates what is automatable by roughly 4×**. At least **30 of the 56** are deterministically checkable with the techniques already in the scanner, two more (YM-03, ACP-02) are *already* automated in `scripts/acp-validate.ts` but still counted as semantic, and one (SH-03) is covered for free by `shellcheck`, which is installed and currently unused — it reports 221 findings on `agent/scripts/` alone.

Duplicate detection (CH-05) is the single rule that genuinely cannot be regexed. dupehound is a credible fit — MIT, offline, no account, no rate limit, and it exposes exactly the `check --diff` / `--json` / exit-code contract ACP already uses. Its risk is maturity: **v0.1.2, 153 total downloads, first published 5 weeks ago**. Recommendation is to adopt it through the existing optional-external-tool 3-gate pattern (never a hard dependency), which also means the CH-05 gap does not block the rest of the work.

The headline: **the local deterministic layer can go from 8 rules to ~38–40 without any external service, and that work is not blocked by anything.** M81's fixture gate blocks CodeRabbit import only.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/commands/acp.review.md` | command doc | 64-rule ruleset; Phase 1/2 split; `--self` + flag table |
| `agent/scripts/acp.review-scan.sh` | script | Phase 1 scanner (8 rules) — **3 defects found** |
| `agent/scripts/acp.integrity-output.sh` | script | shared finding emitter (`ig_emit_finding`, `--ci`, `--json`) |
| `agent/scripts/acp.coderabbit.sh` | script | reference implementation of the 3-gate optional-tool contract |
| `agent/patterns/local.optional-external-tool.md` | pattern | 3-gate contract governing any new tool adoption |
| `agent/wiki/coderabbit-policy-map-lite.md` | wiki | rule→owner map; "Phase 1 never deferred" binding rule |
| `scripts/acp-validate.ts` | source | already automates YM-03 + ACP-02 (overlap, undocumented) |
| `agent/memory/decisions.md` (ADR-19/21/22) | memory | governance gates on external-tool integration |
| `agent/reports/review-002-local-thorough-campaign.md` | report | M82 campaign result; rate-limit evidence |
| `e2e/acp.review.test.sh` | test | 248 lines — **doc-assertion only, zero scanner behaviour tests** |
| `github.com/Rafaelpta/dupehound` + crates.io | external | duplicate-detection candidate |

---

## Key Findings

| ID | Sev | Finding | Location |
|----|-----|---------|----------|
| F-102-01 | **HIGH** | Multi-path invocation silently drops all but the last path — masked 2 real HIGH findings | `agent/scripts/acp.review-scan.sh:18-26` |
| F-102-02 | **HIGH** | `--self` is documented in the flag table and the self-review recipe but unimplemented in the scanner (exits 2) | `agent/commands/acp.review.md:81` vs `acp.review-scan.sh:18-26` |
| F-102-03 | MEDIUM | `.mjs`/`.cjs` scanned in file mode but omitted from directory traversal — silent scope gap | `agent/scripts/acp.review-scan.sh:133` vs `:141` |
| F-102-04 | MEDIUM | Doc claims 56 rules "cannot be scripted"; ≥30 are deterministic and 2 are already automated elsewhere | `agent/commands/acp.review.md:41,56` |
| F-102-05 | MEDIUM | `shellcheck` is installed and covers SH-03 (+221 findings) but is not wired into `/acp-review` | `agent/commands/acp.review.md:359` |
| F-102-06 | LOW | Rule ownership between `/acp-validate` and `/acp-review` is undocumented — YM-03/ACP-02 double-counted | `scripts/acp-validate.ts:1913,2182` |
| F-102-07 | MEDIUM | CH-05 (duplicate code) has no implementation path; needs AST fingerprinting, not regex | `agent/commands/acp.review.md:194` |
| F-102-08 | MEDIUM | `e2e/acp.review.test.sh` asserts only doc content — no test executes the scanner, which is why F-102-01/02 survived | `e2e/acp.review.test.sh:26-88` |

### F-102-01 — evidence

```
$ bash agent/scripts/acp.review-scan.sh $S/a $S/b     # two dirs, one secret each
[CRITICAL] .../b/y.ts:1 SC-01 — hardcoded secret pattern
Total findings: 1          ← should be 2; $S/a was never scanned
```

Cause: the arg loop assigns rather than accumulates —

```bash
*) TARGET="$1"; shift ;;      # acp.review-scan.sh:24 — last path wins
```

Consequence on this repo. The documented recipe scans `agent/scripts/` only. Scanning `scripts/` separately:

```
[HIGH] scripts/acp-bootstrap.sh:1  SH-01 — missing set -euo pipefail
[HIGH] scripts/acp-dispatch.ts:131 TS-01 — any type usage
```

Both verified genuine. `acp-bootstrap.sh` uses `set -e` + `set -o pipefail` with **no `trap ERR`** — this is the exact anti-pattern named in `CLAUDE.md` ("Never use `set -e` without trapping errors"), and it is the highest-blast-radius script in the repo since it is documented for `curl | bash`. `acp-dispatch.ts:131` is a genuine `as any` on `yaml.load`.

Neither is tracked as a pending carryover today.

---

## Current State — what we actually have

| Layer | Mechanism | Rules | Status |
|-------|-----------|-------|--------|
| Phase 1 scanner | `acp.review-scan.sh` | 8 (EH-01/02, SC-01, TS-01/02, AP-01, NC-01, SH-01) | working, 3 defects |
| Structural validator | `scripts/acp-validate.ts` | YM-03, ACP-02 + ~30 ACP-internal checks | working, not credited to review |
| Shared emitter | `acp.integrity-output.sh` | `--ci` / `--json` / severity counts | **reusable as-is** |
| Integrity scanners | `acp.entropy-scan.sh`, `acp.pattern-scan.sh`, … | 70 IG-* rules | separate command, same emitter |
| CodeRabbit | cloud, PR-based | Phase 2 overlap only | **rate-limited**; import blocked on M81 fixture |
| Phase 2 agent review | LLM reasoning | nominally 56 | required for release |

The good news buried in that table: `acp.integrity-output.sh` already gives any new scanner uniform output, `--ci` exit semantics, JSON mode, and severity tallying. **New rules are incremental additions to a working harness, not new infrastructure.**

Local tooling available and unused: `shellcheck` ✓, `rg` ✓, `jq` ✓, `python3` 3.14 ✓, `node` 26 ✓, `cargo` 1.96 ✓. Missing: `semgrep`, `jscpd`, `tree-sitter`.

---

## Gap Analysis — rule scriptability

Reclassifying all 64 rules against the techniques the scanner already uses (line regex, Python brace-matching, file naming, config reads, subprocess):

| Tier | Meaning | Count | Examples |
|------|---------|-------|----------|
| **A** | Deterministic, built | 8 | EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01 |
| **B** | Deterministic, built *elsewhere*, miscounted as semantic | 2 | YM-03, ACP-02 (`acp-validate.ts`) |
| **C** | Deterministic, **buildable now** | **~30** | see below |
| **D** | Needs AST fingerprinting — tool delegation | 1 | CH-05 |
| **E** | Genuinely agent-only | ~23 | SC-06/07 (authz), SC-02, EH-10, TS-09/11/12, CH-09/10, AP-04/05 |

### Tier C detail — the buildable 30

| Group | Rules | Technique | Est. effort |
|-------|-------|-----------|-------------|
| **Free via shellcheck** | SH-03 (+bonus SC2155/SC2034 class) | wrap `shellcheck -f gcc`, map to SH-03 | XS |
| **Security regex, high value** | SC-03, SC-08, SC-10, SC-13, SC-16, SC-18, AP-09 | single-line patterns | S |
| **Security via subprocess** | SC-14 (`npm audit --json \| jq`), SC-15 (lockfile + `git ls-files`) | verified working | XS |
| **Shell portability** | SH-02 (guard-aware `sed -i`), SH-04 (trap-EXIT in sourced libs, `trap - EXIT`-aware) | regex + context | S |
| **Code health** | CH-01, CH-03, CH-06, CH-07 | regex + brace counting | S |
| **TypeScript** | TS-03, TS-04, TS-06, TS-07, TS-08, TS-13 | regex + `tsconfig.json` read | S |
| **Error handling** | EH-03, EH-04, EH-07, EH-08, EH-09 | reuse existing Python brace-matcher | M |
| **Naming** | NC-02, NC-04, NC-06, NC-09 | regex + pure filename checks | S |
| **ACP hygiene** | ACP-01, ACP-03, YM-01, YM-02 | grep + filename + YAML parse | XS |

**Precision caveat, learned empirically.** Naive regex is not good enough on its own:

- CH-01 `TODO|FIXME` → 28 raw hits, but `e2e/*.test.sh` lines like `assert_not_contains "$STEPS" "TODO"` are false positives.
- CH-06 `console.log` → hits `acp-validate.ts` and `acp-dispatch.ts`, which are **CLI tools where console output is the product**.
- SH-02 `sed -i` → `acp.common.sh:8` and `acp.yaml-parser.sh:18` are already correctly OS-guarded.
- SH-04 `trap EXIT` → `acp.atomic-write.sh:21` sets it but clears with `trap - EXIT` at :30 — not a violation.

Every one of these needs the same **allowlist + context discipline** the scanner already applies for SH-01 (the F-M82-05 sourced-library exemption). That discipline is the design requirement for Tier C, not an afterthought — a scanner that cries wolf gets switched off.

---

## dupehound Assessment (CH-05)

| Dimension | Finding |
|-----------|---------|
| **What it does** | Structural duplicate detection — tree-sitter parse → identifiers→`ID`, literals→`LIT` → 10-token k-gram rolling hash → robust winnowing (Schleimer et al., SIGMOD 2003) → Jaccard similarity → union-find clustering |
| **Why it matters here** | Catches AI-generated near-duplicates after rename (`formatDate` → `renderTimestamp` → `stringifyDate`). Exactly the failure mode of agent-written code — ACP's own problem domain |
| **Language** | Rust; 15+ languages incl. TS/JS/Python/Go/Rust/Bash-adjacent |
| **License** | MIT (bundled fonts SIL OFL 1.1) — compatible |
| **Install** | `cargo install dupehound` (cargo 1.96 present) or Homebrew; prebuilt binaries |
| **Offline** | **Yes — no network, no account, no rate limit.** This is the decisive contrast with CodeRabbit |
| **CI contract** | `check --diff main .` → exit `0` clean / `1` findings / `2` error — matches ACP `--ci` semantics exactly |
| **Output** | `--json` versioned schema; `scan` gives "slop score" (% deletable) graded A–F |
| **Agent integration** | ships an MCP server (`dupehound mcp`) exposing `check_duplication` / `scan_duplication` |
| **Claimed perf** | vscode 3.3M LOC in 0.74s, "zero false positives across 15,000+ functions" — vendor claim, unverified |
| **⚠️ Maturity** | **v0.1.2, published 2026-06-21, 153 total downloads (100 on latest)** — pre-adoption |

### Verdict

**Adopt — but strictly through the 3-gate optional-external-tool pattern, never as a dependency.**

The maturity number is the whole argument for that structure. 153 downloads means unproven at scale, possible breaking changes across 0.x, and non-trivial abandonment risk. But the 3-gate pattern (`local.optional-external-tool.md`) was built for precisely this: opt-in preference default-off → `command -v` detection → silent no-op when absent. If dupehound disappears, ACP loses one annotation and nothing else breaks.

Two properties make it a *better* fit than CodeRabbit was:

1. **The fixture problem doesn't exist.** ADR-22 blocks M81 because a CodeRabbit PR-comment export can only come from a live consumer repo. dupehound is local — a real `--json` fixture can be generated on this repo in one command, today. No gate, no waiting, no invented fixture.
2. **The algorithm outlives the implementation.** Winnowing is a 2003 published algorithm. If dupehound stalls, the detection approach is reimplementable or swappable (jscpd, PMD-CPD) behind the same helper interface.

### Governance note

ADR-19/21/22 gate **CodeRabbit and Aikido** — cloud services whose output shape can't be known without live adoption. dupehound is a different class: local, deterministic, offline, output verifiable today. It is not covered by those gates, and it should not be silently folded under them. **A new ADR should state that explicitly** — establishing "local deterministic analyzer" as a category that the ADR-19 adoption gate does not apply to. Do not treat this as re-opening ADR-19; it is a category the gate never contemplated.

---

## Proposed Plan — M83: Deterministic Local Review Engine

Four phases. Phase 1 is a bug-fix that should ship regardless of whether the rest proceeds.

### Phase 1 — Fix the scanner (blocking, ~4h)

| Task | Scope | Sev |
|------|-------|-----|
| T-a | Accumulate multi-path args into an array; scan every path (F-102-01) | HIGH |
| T-b | Implement `--self` in the scanner: `scripts/`, `agent/scripts/`, `agent/commands/`, `e2e/`, skipping missing dirs (F-102-02) | HIGH |
| T-c | Add `*.mjs`/`*.cjs` to directory `find` (F-102-03) | MED |
| T-d | Triage the 2 unmasked findings — `acp-bootstrap.sh` `trap ERR`, `acp-dispatch.ts:131` `as any` | HIGH |
| T-e | E2E that **executes** the scanner: multi-path, `--self`, `.mjs`, exit codes, allowlist behaviour (F-102-08) | HIGH |

> T-e is the one that matters long-term. The current 248-line E2E asserts documentation strings and never runs the binary — which is exactly why a scope bug this size survived a full review campaign.

### Phase 2 — Free coverage via shellcheck (~3h)

Wrap `shellcheck -f gcc -S warning`, map to SH-03, apply an allowlist for accepted classes (SC1090/SC2034 on sourced libs). 221 findings currently available at zero implementation cost. Gate it behind `command -v shellcheck` per the 3-gate pattern.

### Phase 3 — Tier C rule expansion (~16h, incremental)

Ship in severity order so value lands first. Each rule needs: detection + allowlist/context guard + fixture-based E2E + policy-map row.

1. **Security batch** — SC-03, SC-08, SC-10, SC-13, SC-14, SC-15, SC-16, SC-18, AP-09
2. **Shell batch** — SH-02, SH-04 (both context-aware, per the false positives above)
3. **ACP hygiene batch** — ACP-01, ACP-03, YM-01, YM-02
4. **Code-health + TS batch** — CH-01, CH-03, CH-06, CH-07, TS-03, TS-04, TS-06, TS-07, TS-08, TS-13
5. **Error-handling + naming batch** — EH-03, EH-04, EH-07, EH-08, EH-09, NC-02, NC-04, NC-06, NC-09

Target: **8 → ~38 deterministic rules.** Update `acp.review.md` Phase 1/2 tables and the policy map in the same change (F-102-04), and document `/acp-validate` vs `/acp-review` ownership (F-102-06).

### Phase 4 — CH-05 via dupehound (~6h, independent)

| Step | Detail |
|------|--------|
| ADR | "Local deterministic analyzers are outside the ADR-19 adoption gate" — carve-out, not re-open |
| Preference | `integrations.dupehound.{enabled:false, min_tokens, threshold}` |
| Helper | `agent/scripts/acp.dupehound.sh` — `dupehound_available()` = `command -v dupehound`; `dupehound_active()` = enabled AND available; modelled on `acp.coderabbit.sh` |
| Fixture | Generate real `tests/fixtures/dupehound-sample.json` locally — **no gate, unlike M81** |
| Wiring | CH-05 annotation in `/acp-review`; `check --diff` in `--ci`; exit 1 maps to HIGH |
| Degradation | Absent tool → silent no-op, CH-05 stays Phase 2 agent-reviewed. E2E must assert this branch |
| Deliberately out of scope | MCP server mode; `--card` scorecards; `history` trend charts |

**Sequencing**: Phase 1 blocks nothing else and should go first. Phases 2–4 are independent and parallelizable. **None of this is blocked by M81's fixture gate** — that gate is CodeRabbit-specific.

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-24 | `e1b45ff` | M82 carryover remediation — SH-01 allowlist added to review-scan |
| 2026-07-15 | `d8b3dda` | v6.26.0 M70 gate hardening — Phase 1 gate policy introduced |
| 2026-07-15 | `1eae07e` | v6.25.2 — `acp.review-scan.sh` Phase 1 shipped |
| 2026-06-07 | `ab54988` | M55 — `/acp-review` 64-rule command created (v6.11.0) |

The scanner has existed since 2026-07-15 and has never had an execution test. The multi-path bug is present in the original implementation.

---

## Recommendations

1. **Ship Phase 1 immediately as a patch** (v6.28.3). The scope bug means every Phase 1 result recorded to date — including M82's review-002 — covered less than claimed. Re-run and amend review-002's Phase 1 row once fixed.
2. **Correct the Phase 1/Phase 2 claim in `acp.review.md`.** "56 semantic rules cannot be scripted" is not accurate and it discourages exactly the automation the rate-limit situation demands.
3. **Take the shellcheck win first** — highest coverage-per-hour in the entire plan.
4. **Run `/acp-plan M83`** using the four-phase structure above.
5. **Adopt dupehound behind the 3-gate pattern, and write the ADR first.** The 153-download maturity signal is a reason to isolate it, not to skip it.
6. **Do not wait on M81.** The CodeRabbit fixture gate is orthogonal — nothing in M83 depends on it.
7. **Make "the E2E must execute the thing" a review standard.** Doc-assertion tests gave false confidence here; that lesson generalizes beyond this scanner.

---

**Files analyzed**: 11 · **Findings**: 8 · **Code pointers**: 14 · **Carryovers written**: 8
