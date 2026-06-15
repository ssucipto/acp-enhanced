# Audit 070 — M55–M58 Engineering Quality & Code-Integrity Gateway: Deep Implementation Review

**Audit ID**: audit-070
**Date**: 2026-06-15
**Auditor**: Opus 4.8 (deep-dive executor)
**Scope**: M55 (`/acp-review`), M56 (`/acp-integrity` v1.0), M57 (recurring/pre-commit), M58 (`/acp-integrity` v2.0 plan) — **implementation + plan**
**Mandate**: Review the *actual code* of the quality + integrity gateway (not just plans). Find gaps, inconsistencies, and improvements to align with industry standards and best practices.
**Method**: Read all six integrity bash scripts line-by-line, the integrity + review command docs, the `code-integrity` skill, the integrity E2E suite, and the M55/M56/M58 milestone specs. Cross-referenced claimed coverage against implemented logic.

---

## 1. Headline

> **The quality gateway (M55) is production-grade. The integrity gateway (M56) is not yet — it *claims* 55 script-backed rules but ~18 are actually implemented, one core scanner crashes on every positive finding, and the E2E suite never exercises the detection logic, so all of this passes CI green.**

For a startup intending to depend on `/acp-integrity` as a security gate on AI-generated code, the cardinal risk is **false assurance**: the tool prints `✓` and exits 0 while the majority of its CRITICAL malicious-code rules (exfiltration IG-07–IG-13, persistence IG-21–IG-26) have no detection at all. A gate that silently does not run is worse than no gate, because it manufactures confidence (NIST SSDF RV.1 / PW.7: verification must actually execute).

M55 `/acp-review`, by contrast, is correctly pure-LLM, 54-rule, OWASP-2025-mapped, and backed by a real 52-assertion E2E suite including behavioral tests. No material defects found there.

---

## 2. Files Analyzed

| Layer | Files |
|-------|-------|
| Plans | `agent/milestones/milestone-55-*.md`, `milestone-56-*.md`, `milestone-58-*.md` |
| Integrity scripts | `agent/scripts/acp.unicode-scan.sh`, `acp.entropy-scan.sh`, `acp.network-whitelist-validate.sh`, `acp.manifest-hash.sh`, `acp.git-provenance.sh`, `acp.dependency-diff.sh` |
| Command docs | `agent/commands/acp.integrity.md`, `agent/commands/acp.review.md` |
| Skill | `agent/skills/code-integrity.md` |
| Tests | `e2e/acp.integrity.test.sh`, `e2e/acp.review.test.sh` (count only) |
| Config | `agent/core/identity.yml`, `agent/wiki/integrity-rules.md` (count) |

---

## 3. Findings

### HIGH

#### F-070-01 (HIGH) — `acp.entropy-scan.sh` crashes (exit 3) on every positive finding
The script runs under `set -euo pipefail` with an `ERR` trap, then does:

```bash
output=$(ACP_THRESHOLD="$THRESHOLD" ACP_FILEPATH="$file" python3 -c "... sys.exit(findings)" 2>/dev/null)
local ret=$?
```

The Python helper communicates its hit count via `sys.exit(findings)`. When `findings > 0`, the command-substitution assignment returns non-zero — and under `set -e`, a failing assignment fires the `ERR` trap, so the script prints `Error: entropy-scan.sh failed at line 56` and exits **3** *before* `echo "$output"` ever runs. Net effect: the entropy scanner **only works when it finds nothing**. Its entire reason for existing (IG-17/IG-18 encoded-payload detection) is non-functional, and the captured findings are discarded.
**Evidence**: `agent/scripts/acp.entropy-scan.sh:56–106`.
**Fix**: stop using the process exit code as a data channel. Either `set +e` around the call (`output=$(...) ; ret=$?` with the assignment guarded by `|| true`), or have Python print the count on stdout and parse it. Add a true-positive E2E fixture so this can never regress silently (see F-070-03).

#### F-070-02 (HIGH) — Claimed rule coverage ≫ implemented coverage (~18 of 55 v1.0 rules)
The command doc, wiki, skill, and milestone all present 55 "v1.0" rules with named script backing. Reading the scripts, the deterministic rules that are actually implemented number roughly **18**. The most serious omissions are whole CRITICAL categories that the milestone attributes to `acp.network-whitelist-validate.sh`:

| Claimed (milestone §5 / cmd doc) | Reality in script |
|---|---|
| Cat 1 IG-01–IG-06 | Only IG-01, IG-02, IG-03, IG-06. **IG-04** (eval of network content) and **IG-05** (DNS from env) absent. |
| Cat 2 IG-07–IG-13 (exfiltration, mostly CRITICAL) | **None implemented** — no `process.env→network`, `fs.readFile→network`, clipboard, storage, token-in-URL, PII, screenshot detection. |
| Cat 4 IG-21–IG-26 (persistence/exec, mostly CRITICAL) | **None implemented** — no `child_process.exec`, `fs.writeFile` to system paths, cron, self-modifying code, dynamic `require`, process injection. |

So ~18 deterministic-looking, mostly-CRITICAL "malicious code" rules silently pass. These are exactly the patterns a supply-chain/insider attack would use. The skill's boundary rule says "no deterministic task may be handled by LLM reasoning alone" — yet for these rules there is neither a script nor an explicit LLM fallback wired in the command flow; they simply do not run.
**Evidence**: `acp.network-whitelist-validate.sh:71–124` vs `milestone-56:§5 Cat 1/2/4`, `acp.integrity.md:72–120`.
**Fix**: either implement the rules or relabel them honestly (e.g., "v1.0: documented, not yet enforced") in the cmd/wiki/skill, and gate `--ci` accordingly. Do not ship a coverage table that overstates what executes.

#### F-070-03 (HIGH) — Integrity E2E never exercises the detection logic
`e2e/acp.integrity.test.sh` is structural + smoke only:
- **B1** ("Unicode scanner detects U+200D") **never invokes `acp.unicode-scan.sh`** — it only greps the fixture file for the character. The scanner could be deleted and B1 would still pass.
- **B2 / B3** only assert the unicode/entropy scanners **exit 0 on a clean file**. No dirty-input assertion (which is why F-070-01's crash is invisible).
- **B4** "False-positive baseline" only greps `AGENTS.md` for 4 phrases. The non-negotiable baseline M56 §8 mandated — `assert_finding_count CRITICAL 0` / `HIGH 0` by actually running the gate over the clean codebase — **does not exist**.
- **S5** only runs `bash -n` (syntax) on the other four scripts; network/git-provenance/dependency detection is never executed.

Result: the gateway has near-zero behavioral coverage; F-070-01, F-070-02, F-070-06 all pass CI.
**Evidence**: `e2e/acp.integrity.test.sh:73–116`.
**Fix**: add a per-rule fixture matrix (one true-positive + one true-negative per script-backed rule) that runs the real scripts and asserts rule ID + exit code. The M58 taint-flow fixture pattern (`agent/benchmarks/fixtures/`) is the right model — extend it down to v1.

#### F-070-04 (HIGH) — `acp.unicode-scan.sh` is O(lines × 16 × 2) python spawns — unusable at scale
For every line, the script loops all 16 hidden-codepoints and spawns `python3` **twice per codepoint** (once to test, once to get the column) — up to **32 interpreter starts per line**. On a real repo (tens of thousands of lines) this is minutes-to-hours, defeating its intended use as a pre-commit / CI gate (`Frequency: Pre-commit (--fast)`).
**Evidence**: `acp.unicode-scan.sh:87–123`.
**Fix**: one `python3` pass per file (or per tree) that scans for the full codepoint set and emits all findings with line/col — eliminates ~99% of process spawns.

### MEDIUM

#### F-070-05 (MED) — No script honors the documented output contract
`code-integrity.md` defines the canonical finding shape (`findings:` YAML with `severity` + `confidence`). **No script emits it.** Each prints ad-hoc, mutually inconsistent text: `unicode` → `file:line:col U+XXXX — name`; `entropy` → `file:line entropy=N`; `network/git/dep` → `file:line IG-NN — msg`. None emit severity or confidence. The LLM is told to "invoke scripts and interpret structured output," but the output is neither structured nor uniform, making reliable aggregation/severity-mapping impossible.
**Evidence**: skill `code-integrity.md:39–52` vs all six scripts.
**Fix**: standardize on one machine-parseable line (`[SEVERITY] file:line ruleID — message` — the format M55 already uses) and/or `--json` for all scripts.

#### F-070-06 (MED) — `--ci` severity semantics contradict the spec → guaranteed CI noise
Cmd doc + skill: `--ci` "exit 1 on CRITICAL or HIGH-confidence:HIGH findings." Every script: `--ci` exits 1 on **any** finding regardless of severity. So MEDIUM-only signals (IG-30 caret version, IG-31 stale lockfile, IG-28 "postinstall present") fail the build. Worse, IG-28 fires on *any* `postinstall` (husky, etc.) — meaning a normal project's CI goes red on first run, training users to ignore the gate.
**Evidence**: `acp.dependency-diff.sh:61–80,126–129`; `acp.integrity.md:39`.
**Fix**: scripts must emit severity and `--ci` must filter to CRITICAL/HIGH only.

#### F-070-07 (MED) — Skill "Rules Covered" table overstates 4 of 6 scripts
`code-integrity.md:19–24` claims: git-provenance → IG-33–35,37 (IG-34, IG-35 not implemented; IG-36, which *is* implemented, is omitted); dependency-diff → IG-27–32 (IG-29, IG-32 not implemented); network → IG-01–03,05–06 (IG-05 not implemented); unicode → IG-14–16 (IG-16 homoglyphs not implemented). The same overstatement appears in the script headers' "Covered rules" comments.
**Fix**: align coverage tables to reality (and `bash -n`-test won't catch this — needs the fixture matrix from F-070-03).

#### F-070-08 (MED) — `acp.dependency-diff.sh`: typosquatting is not what it claims; namesake rule missing
Milestone: IG-27 = "Typosquatting (Levenshtein 1–2 from top-1000)." Implementation: crude substring match against ~60 hardcoded packages, explicitly commented "Levenshtein approximation via substring." It misses real edit-distance squats (`loadsh`, `expresss`, `momnet`, `axios`→`axioss`) and false-positives on legitimate names. **IG-29 (shadow deps — imported but absent from lockfile), the script's literal namesake/purpose, is not implemented**, nor is IG-32 (new dep without task ID).
**Evidence**: `acp.dependency-diff.sh:37–110`.
**Fix**: implement real Levenshtein (small python helper), implement IG-29 by diffing `package.json`/imports vs lockfile, or descope honestly.

#### F-070-09 (MED) — YAML parsed with grep/sed across the gateway (rule self-violation + correctness)
`acp.network-whitelist-validate.sh:45–50` extracts the whitelist with `grep -E '^\s+-'` — it captures **any** `- ` list item in the file, not items scoped under `approved_hosts:`. A list elsewhere in `network_whitelist.yml` would be silently treated as approved domains (fail-open). Same grep-as-YAML pattern in `git-provenance.sh` (team_members) and `manifest-hash.sh` (verify). This violates the project's own `skills/scripts.md` ("never parse YAML with grep") and matches the open carryover class LOW-067-004.
**Fix**: route through `agent/scripts/acp.yaml-parser.sh` (already exists) and scope extraction to the correct key.

#### F-070-10 (MED) — mtime-based staleness (IG-31) is unreliable in git/CI
`acp.dependency-diff.sh:116–124` compares file mtimes; git checkouts/clones reset mtimes to checkout time, so on CI this produces meaningless results.
**Fix**: use `git log -1 --format=%ct -- <file>` for both files.

#### F-070-11 (MED) — IG-37 provenance control is a no-op out of the box
`identity.yml` ships `team_members: []`. `acp.git-provenance.sh:68` guards author verification behind `[[ ${#TEAM_MEMBERS[@]} -gt 0 ]]`, so with the default config the headline provenance check **silently passes for every commit**. The single most marketed integrity control does nothing until a user discovers and populates the field.
**Fix**: if `team_members` is empty, emit an explicit `IG-37 SKIPPED (team_members unset)` warning rather than a silent pass, and document setup in the command's first-run path.

#### F-070-12 (MED) — Manifest tamper-detection cannot detect added core files (IG-41); `--generate` doesn't write
`acp.manifest-hash.sh:22–30` tracks a hardcoded 7-file list and never enumerates `agent/core/`, so IG-41 ("new files in `agent/core/` not in upstream manifest") is structurally undetectable. Also `--generate` prints to **stdout** (not to `agent/manifest.yaml`), while `--verify` reads the file — an asymmetry that previously forced manifest generation via an out-of-band script.
**Fix**: glob the tracked directories at generate time; have `--generate` write the file (with `--stdout` opt-out).

### LOW

#### F-070-13 (LOW) — `unicode-scan.sh` mis-attributes rule IDs; comment regex malformed
JSON output hardcodes `"rule":"IG-14"` for *all* hidden-char hits (bidi markers should be IG-15, homoglyphs IG-16); the human output omits the rule ID entirely. The comment-detector ERE `'^[[:space:]]*(//|#|/\\*|\*|<!--)'` contains `/\\*` (slash + literal backslash) so it won't match real `/*` block comments.
**Evidence**: `acp.unicode-scan.sh:117,127`.

#### F-070-14 (LOW) — Integrity E2E rule-count uses a broken regex (`\d` in ERE)
`e2e/acp.integrity.test.sh:32` `grep -cE '^\| IG-\d+'` — `\d` is literal in POSIX ERE, so the count is 0 and `[ 0 -ge 55 ]` fails (masked only by `|| echo 0`). Wiki actually has 70 IG rows. Same defect class as F-067-003.
**Fix**: `grep -cE '^\| IG-[0-9]+'`.

#### F-070-15 (LOW) — Portability/dependency fragility
`manifest-hash.sh` uses `shasum -a 256` only; many Linux CI images ship `sha256sum`, not `shasum`. `unicode`/`entropy` hard-require `python3` and degrade to a non-blocking warning+exit-2 if absent — a missing interpreter silently disables those rules. Document and/or fall back (`sha256sum`/`openssl dgst`).

#### F-070-16 (LOW) — Skill token-budget inconsistency
`code-integrity.md` header says "≤800 tokens"; M56 deliverable + verification checklist specified ≤500. Pick one and make the checklist match.

---

## 4. Positive Confirmations (do not regress)

- **M55 `/acp-review` is solid**: correctly `Scripts: None` (pure-LLM is the right call for quality heuristics), 54 OWASP-2025/MASVS-mapped rules, `--diff`/`--ci`/`--owasp` flags, and a real 52-assertion E2E with behavioral cases. This is the model the integrity side should follow.
- **Architecture is sound**: the deterministic→script / semantic→LLM boundary rule, confidence ceilings (HIGH/MEDIUM/LOW), remediation playbook, and version-pinned standards (OWASP 2025, SLSA v1.0, MITRE ATT&CK v16/ATLAS, NIST 800-53r5) are mature and industry-aligned.
- **Security hygiene in the scripts is good in principle**: `set -euo pipefail` + `ERR` trap everywhere, and untrusted values passed to Python via environment variables (not string interpolation) — avoiding shell/command injection in the scanners themselves.
- **M58 plan is honest about LLM limits**: deferring taint-flow to MEDIUM and memory/semantic-injection to LOW confidence, with a go/no-go gate, is the correct posture (avoids the false-confidence trap that v1's *implementation* fell into).

---

## 5. Industry-Standard Alignment

| Standard | Expectation | Gateway status |
|----------|-------------|----------------|
| NIST SSDF (PW.7 / RV.1) | Verification must actually run and be tested | ❌ Integrity: rules claimed but not executed/tested (F-070-02/03) |
| OWASP / SAST tooling norms | Low false-positive rate; severity-gated CI | ⚠️ `--ci` blocks on MEDIUM/any finding (F-070-06) |
| Reproducible tooling | Deterministic across environments | ⚠️ mtime + `shasum` + python deps (F-070-10/15) |
| Truth-in-advertising for security tools | Documented coverage == real coverage | ❌ 4/6 coverage tables overstated (F-070-07) |
| Supply-chain detection (SLSA-adjacent) | Real typosquat + shadow-dep detection | ⚠️ substring heuristic, IG-29 missing (F-070-08) |

---

## 6. Recommendations (priority order)

1. **Fix the entropy crash (F-070-01)** — one-line-class fix; the scanner is currently dead on arrival.
2. **Build the fixture matrix + real false-positive baseline (F-070-03)** — true+/true- per script-backed rule, plus `assert_finding_count CRITICAL/HIGH 0` over the clean codebase, as M56 §8 already promised. This is the keystone: it makes every other defect visible.
3. **Reconcile claimed vs actual coverage (F-070-02/07)** — for each unimplemented rule, either implement it or relabel as "documented, not enforced." Ship an accurate coverage matrix.
4. **Standardize output + severity-gate `--ci` (F-070-05/06)** — uniform `[SEVERITY] file:line ruleID — msg` (or `--json`); `--ci` filters to CRITICAL/HIGH.
5. **Performance: single-pass unicode scan (F-070-04)** so the gate is usable pre-commit.
6. **Implement the namesake rules (F-070-08, IG-29 shadow deps; real Levenshtein) and fix provenance no-op (F-070-11).**
7. **YAML via the parser, not grep (F-070-09); git-date staleness (F-070-10); manifest writes + directory enumeration (F-070-12).**
8. **Sweep the LOWs (F-070-13/14/15/16).**

Suggested sequencing: these map cleanly onto a new **M64 — Integrity Gateway v1.1 (Truth & Test)** before any further v2.0 semantic work, because building M58 semantic analysis on top of an untested, partially-implemented v1 compounds the false-assurance risk.

---

## 7. Carryovers Written

F-070-01 … F-070-16 appended to `agent/memory/audit-carryovers.md` (HIGH ×4, MED ×8, LOW ×4).

*audit-070 | ACP Enhanced | M55–M58 gateway deep dive | 2026-06-15*
