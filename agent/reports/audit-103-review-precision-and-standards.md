# Audit Report: `/acp-review` Deterministic Rule Precision & Industry-Standard Conformance

**Audit**: #103
**Date**: 2026-07-27
**Subject**: Do the 8 shipped Phase 1 rules actually work? Are we at industry standard? What shortcuts were taken?
**Follow-up to**: audit-102 (which found scope bugs but never tested rule correctness)
**Executor**: claude-opus-5

---

## Summary

audit-102 asked *how many* rules we automate. This audit asks whether the ones we ship are **correct** — and the answer is no.

Against a seeded fixture of 13 known defects that the 8 Phase 1 rules are specified to catch, the scanner detected **1**. Against a clean file containing zero real defects, it emitted **2 findings, both false** — one on a code comment, one on a string literal. Measured on this corpus: **recall ≈ 8%, precision 0%.**

The root cause is a single architectural shortcut. The scanner matches regexes against **raw lines with no lexing** — no comment stripping, no string-literal awareness, no token boundaries. Every line-based rule inherits this. A second defect compounds it: EH-01 tests `if "try" not in body` as a **substring**, so any async function whose body contains `retry`, `telemetry`, `entry`, `country`, or `symmetry` silently passes. Those are exactly the words that appear in async retry/telemetry code — the code EH-01 exists to check.

On standards: the ruleset correctly cites **OWASP Top 10:2025**, which is the current edition, and 6 of 7 category mappings are accurate. But one is wrong (secrets mapped to A05:2025, which is *Injection*), and **three 2025 categories have no rules at all** — A06 Insecure Design, A07 Authentication Failures, A08 Software/Data Integrity Failures. We also lack the three mechanisms every mature scanner ships: baseline mode, inline suppression, and per-rule threshold tuning.

**This changes the M83 plan.** audit-102 recommended adding ~30 rules in Phase 3. Doing that on top of an unlexed foundation would multiply the false-positive rate roughly fourfold. Industry data is blunt about the consequence: *"False positives above 30% destroy credibility... once engineers learn to ignore alerts, you're running security theater."* **Phase 3 must be re-sequenced behind a lexing fix and a measured fixture corpus.** I'm correcting my own prior recommendation.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/scripts/acp.review-scan.sh` | script | the 8 rules under test — 6 precision defects |
| `agent/scripts/acp.entropy-scan.sh` | script | ACP *already owns* entropy detection; review doesn't use it |
| `agent/scripts/acp.integrity-output.sh` | script | emitter — no suppression/baseline support |
| `agent/commands/acp.review.md` | command doc | OWASP mappings, severity assignments |
| `agent/memory/audit-carryovers.md` | memory | 13 pending / 230 fixed |
| OWASP Top 10:2025 | external | verified current edition + category list |
| gitleaks / TruffleHog / SAST 2026 comparisons | external | industry baseline for secrets + FP management |

---

## Part 1 — Measured Precision & Recall

### Method

Two fixtures: `fn.ts` seeding 13 defects the 8 rules are specified to catch, and `fp.ts` containing zero real defects but syntactically similar text in comments and strings.

### Recall — 1 of 13 detected (≈8%)

| # | Seeded defect | Rule | Detected |
|---|---|---|---|
| 1 | `const secret = "sk-live-…"` | SC-01 | ❌ |
| 2 | `const token = "ghp_…"` (GitHub PAT) | SC-01 | ❌ |
| 3 | `const awsKey = "AKIA…"` | SC-01 | ❌ |
| 4 | `let apiToken = 'xoxb-…'` (Slack) | SC-01 | ❌ |
| 5 | `Record<string, any>` | TS-01 | ❌ |
| 6 | `Promise<any>` | TS-01 | ❌ |
| 7 | `export function f<T>(x: T)` — generic | TS-02 | ❌ |
| 8 | `export const f = (a) => …` — arrow | TS-02 | ❌ |
| 9 | `export default function f(a)` | TS-02 | ❌ |
| 10 | `export function f(\n a,\n b\n)` — multi-line | TS-02 | ❌ |
| 11 | indented `const my_snake_var` | NC-01 | ❌ |
| 12 | indented `let another_snake` | NC-01 | ❌ |
| 13 | `async function retryThing()` | EH-01 | ✅ |

### Precision — 2 of 2 findings false (0%)

```
[HIGH] fp.ts:2 TS-01 — any type usage
   → line 2 is a COMMENT:  // …the return type can be : any value in legacy code
[HIGH] fp.ts:4 TS-01 — any type usage
   → line 4 is a STRING:   { note: "use as any only with a comment" }
```

### Confirmed defect: EH-01 substring suppression

```ts
async function sneaky() {
  const msg = "we should retry this later";   // ← contains "try"
  await fetch("/z");                          // ← genuinely unhandled
}
```
```
✓ No findings from review-scan          ← silently suppressed
```

Cause, [acp.review-scan.sh:102](agent/scripts/acp.review-scan.sh#L102):
```python
if "try" not in body and ".catch(" not in body:
```
A substring test where a token test is required. Any body containing `retry`, `telemetry`, `entry`, `country`, `industry`, `symmetry`, `sentry`, `pantry` disables the rule for that function.

---

## Part 2 — Findings

| ID | Sev | Finding | Location |
|----|-----|---------|----------|
| F-103-01 | **HIGH** | No comment/string-literal stripping — every line-regex rule fires inside comments and strings | `acp.review-scan.sh:37-65` |
| F-103-02 | **HIGH** | EH-01 uses substring `"try" not in body` — silently suppressed by `retry`/`telemetry`/`entry` | `acp.review-scan.sh:102` |
| F-103-03 | **HIGH** | SC-01 misses all real-world token formats (`ghp_`, `AKIA`, `xoxb-`, `const secret =`) — 0/4 recall | `acp.review-scan.sh:40-44` |
| F-103-04 | **HIGH** | TS-02 misses arrow functions, generics, `export default`, multi-line signatures — 0/4 recall | `acp.review-scan.sh:50-54` |
| F-103-05 | MEDIUM | TS-01 misses `any` inside generic parameters (`Record<string, any>`, `Promise<any>`) | `acp.review-scan.sh:46` |
| F-103-06 | MEDIUM | NC-01 anchored `^(const\|let\|var)` — matches only column-0 declarations, missing all indented code | `acp.review-scan.sh:62` |
| F-103-07 | MEDIUM | No test/fixture/generated-file exclusion — test data with dummy credentials will emit CRITICAL | `acp.review-scan.sh:141` |
| F-103-08 | MEDIUM | Secrets section mapped to A05:2025 (= *Injection*); A06/A07/A08:2025 have no rules | `acp.review.md:206` |
| F-103-09 | MEDIUM | No baseline mode, inline suppression, or per-rule thresholds — industry-standard FP controls absent | `acp.integrity-output.sh` |
| F-103-10 | MEDIUM | `acp.entropy-scan.sh` already implements entropy detection but SC-01 doesn't use it (and its 4.5 threshold misses structured tokens anyway) | `acp.entropy-scan.sh:14` |

---

## Part 3 — Industry-Standard Conformance

### OWASP Top 10:2025 — verified current

The ruleset's claimed alignment is to a **real, current** standard. Mapping accuracy:

| ACP section | Claimed | Actual A**:2025 | ✓ |
|---|---|---|---|
| Cat 1 Error Handling | A10:2025 | Mishandling of Exceptional Conditions | ✅ |
| 6a Secrets & Input | A05:2025 | **Injection** | ❌ secrets ≠ injection |
| 6b Access Control | A01:2025 | Broken Access Control | ✅ |
| 6c Misconfiguration | A02:2025 | Security Misconfiguration | ✅ |
| 6d Supply Chain | A03:2025 | Software Supply Chain Failures | ✅ |
| 6e Cryptography | A04:2025 | Cryptographic Failures | ✅ |
| 6g Security Logging | A09:2025 | Security Logging and Alerting Failures | ✅ |

**Unmapped 2025 categories** — no rules at all: **A06 Insecure Design**, **A07 Authentication Failures**, **A08 Software or Data Integrity Failures**. A08 is arguably covered by `/acp-integrity`, which strengthens F-102-06's point that cross-command rule ownership is undocumented.

### Secret detection vs gitleaks / TruffleHog

| Capability | gitleaks | TruffleHog | ACP SC-01 |
|---|---|---|---|
| Known-prefix patterns (`ghp_`, `AKIA`, `xoxb-`) | ✅ ~200 rules | ✅ 800+ | ❌ 4 patterns |
| Entropy analysis | ✅ tuned per-rule | ✅ | ⚠️ exists in `entropy-scan.sh`, unused by review; threshold 4.5 misses structured tokens |
| Credential verification (live check) | ❌ | ✅ | ❌ |
| Baseline / allowlist | ✅ | ✅ | ❌ |
| Inline suppression comments | ✅ | ✅ | ❌ |

Industry guidance says to *"start with secrets detection (highest impact, lowest false-positive rate)"* — it is the rule we should be strongest on and it currently has the worst recall of the eight.

### The credibility threshold

> *"False positives above 30% destroy credibility faster than you can rebuild it."*
> *"Most teams replace their scanner within two years due to too many false positives and coverage gaps."*

Both failure modes are present simultaneously.

---

## Part 4 — Shortcuts Taken

| # | Shortcut | Consequence | Fix |
|---|---|---|---|
| 1 | Line regex, no lexing | root cause of F-103-01/05/06 | tokenize or strip comments+strings before matching |
| 2 | Substring instead of token match | F-103-02 silent suppression | word-boundary / AST check |
| 3 | `^` anchors assuming column 0 | F-103-06 misses indented code | allow leading whitespace |
| 4 | `TARGET="$1"` overwrite | audit-102 F-102-01 scope loss | accumulate array |
| 5 | Doc-assertion-only E2E | **why none of this was caught** | fixture corpus with expected findings |
| 6 | Rule count published without precision/recall measurement | "8 deterministic rules" overstated capability | publish measured metrics |
| 7 | Severities assigned uncalibrated | SC-01 CRITICAL despite ~0 recall | calibrate against fixture outcomes |

Shortcut 5 is the systemic one. A scanner with no execution tests will drift silently forever; every other defect here is downstream of not measuring.

### Shortcuts we must NOT take next

1. **Do not add ~30 rules onto the current foundation.** Same unlexed engine ⇒ ~4× the false positives. Fix lexing first.
2. **Do not hand-roll secret detection.** 4 regexes will not approach gitleaks' 200+. Either delegate (gitleaks is optional-tool-pattern eligible, exactly like dupehound) or reuse `entropy-scan.sh` — don't reinvent.
3. **Do not claim rule counts without measured recall.** Publish the corpus number alongside the count.
4. **Do not mark carryovers fixed without a regression fixture.** Quality Gate 8 in `acp.review.md` already requires re-verification; honor it here.

---

## Part 5 — Carryover State

**13 pending / 230 fixed.**

| Group | IDs | Status |
|---|---|---|
| audit-101 (M81) | F-101-02, 03, 05, 06 | blocked on CodeRabbit fixture — correctly parked |
| audit-102 (M83) | F-102-01 … 08 | open, planned M83 |
| audit-103 (this) | F-103-01 … 10 | new |

No stale or orphaned entries; `validateCarryoverFreshness` and audit-stamp checks pass. The ledger is healthy — the gap was never tracking, it was that **nothing tested the scanner**, so there was nothing to track.

---

## Part 6 — Revised M83 Plan

Changes to audit-102's sequencing shown in **bold**.

| Phase | Scope | Change |
|---|---|---|
| **1** | Scanner scope fixes (F-102-01/02/03) + **executing E2E** | unchanged — still first |
| **1b** | **NEW — Precision foundation**: comment/string stripping, token-boundary matching, `^`-anchor fix, test/fixture exclusion (F-103-01/02/05/06/07) | **new, blocks Phase 3** |
| **1c** | **NEW — Fixture corpus**: seeded TP/FP files per rule, measured recall+precision published in the doc | **new, blocks Phase 3** |
| **2** | shellcheck wrapper (SH-03) | unchanged |
| **3** | ~30 new Tier C rules | **now gated on 1b+1c** |
| **3b** | **NEW — Secrets strategy**: reuse `entropy-scan.sh` + prefix patterns, or adopt gitleaks via the optional-tool pattern (F-103-03/10) | **new** |
| **4** | dupehound CH-05 + assisted install | unchanged |
| **5** | **NEW — Standards**: fix A05 mismapping; decide on A06/A07/A08 coverage; add baseline + inline suppression (F-103-08/09) | **new** |

Effort moves from ~29h to roughly **45h**. The added work is not optional polish — without 1b/1c, Phase 3 makes the tool *less* trustworthy, not more.

---

## Recommendations

1. **Re-sequence M83: 1 → 1b → 1c before Phase 3.** The foundation fix is now the critical path.
2. **Treat F-103-02 as the most urgent single fix** — it silently disables a HIGH security rule, and the trigger words are common in exactly the code it targets.
3. **Publish measured recall/precision in `acp.review.md`**, replacing the bare "8 deterministic rules" claim. Re-measure in CI on every scanner change.
4. **Decide the secrets strategy explicitly** (F-103-03). My recommendation: delegate to gitleaks under the same 3-gate optional-tool pattern as dupehound, and keep SC-01 as a thin always-on fallback. Do not grow the hand-rolled regex set.
5. **Amend review-002.** Its Phase 1 "clean" row reflects an ~8%-recall scanner over half the intended scope. It should be annotated, not deleted.
6. **Add "does an E2E execute this?" to the definition of done for any scanner rule.** Shortcut 5 is the one that generated everything else.

---

**Files analyzed**: 7 · **Findings**: 10 · **Fixtures executed**: 3 · **Carryovers written**: 10
