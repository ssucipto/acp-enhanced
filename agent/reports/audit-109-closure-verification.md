# Audit Report: Closure Verification — Carryovers, Findings, Shortcuts

**Audit**: #109
**Date**: 2026-07-28
**Subject**: Verify that every carryover, audit finding, and shortcut raised across audits 107–108 is genuinely closed; identify what remains
**Mode**: standard (closure verification — claims re-checked against code, not against prior reports)

## Summary

This audit re-verified closure claims mechanically instead of trusting the audit-107 and audit-108 reports. **All 27 tracked findings across F-107, audit-107, and audit-108 are confirmed implemented in code.** The carryover ledger is clean: 263 fixed, 1 deliberately deferred, 0 pending.

Two things worth recording. First, the initial ledger scan in this audit **reported a false pending item** (`F-099-03`) because the parse matched `status:pending` occurring inside a finding's prose rather than the `status:` key — the same class of naive-parse bug that produced the false positive in the duplicate-key validator during audit-108. Re-parsed with a key-anchored, indentation-aware pattern, the count is 0. Second, one genuine leftover was found and fixed: an untracked Cursor tool cache polluting the working tree.

## Carryover Ledger — Key-Anchored Parse

| Status | Count | Detail |
|--------|-------|--------|
| `fixed` | 263 | — |
| `deferred` | 1 | `CRIT-065-002` — branch protection rules |
| **`pending`** | **0** | — |

`CRIT-065-002` is **not an unaddressed shortcut**. It is blocked by an external constraint (GitHub Free tier does not offer branch protection on private repos), documented with a rationale, stamped `fix_applied_date: 2026-07-15` / `verified_in_audit: audit-097-deferred`, and has `acp.branch-protection-setup.sh` ready to run the moment the tier or repo visibility changes. Deferral is recorded, not silent.

### Parse-method warning

| Parse method | Reported pending | Correct? |
|---|---|---|
| `re.search(r'status:\s*(\S+)')` on block text | 2 (`[e.g.`, `F-099-03`) | ❌ matched prose quoting other statuses |
| `re.search(r'^    status:\s*(\S+)\s*$', re.M)` | 0 | ✅ key-anchored, indentation-aware |

`F-099-03`'s own finding text is *"…remain status:pending — carryover-ledger integrity failure"*. A prose-matching scan reads that as a status. Any future ledger tooling must anchor on the key at its indent.

## Finding Closure Matrix

Each row was checked against the source file, not the report that claimed it.

| Finding | Verification performed | Result |
|---------|------------------------|--------|
| F-107-01 | 8 of 8 scanners contain the `${#IG_REMAINING_ARGS[@]} -gt 0` guard; zero `set -- "${...[@]:-}"` remain | ✅ |
| F-107-02 | `git -C "$lock_repo" ls-files` present at `acp.review-scan.sh:452` | ✅ |
| F-107-03 | Byte-offset check: inline-suppression evaluation precedes `ig_baseline_add_entry` | ✅ |
| F-107-04 | No `sed 's/},{/…'` outside comments; `ig_format_json_array_body()` present | ✅ |
| G-107-02 | `findDuplicateEntryKeys` + `memoryDupesOk` in exit chain | ✅ |
| G-107-03 | `check-ignore -q` exemption present | ✅ |
| G-107-05 | B26 enumerates ≥8 scanners | ✅ |
| G-107-07 | Corpus lockfile fixture tracked in git | ✅ |
| G-107-08 | `_insert_experimental_flag()` present | ✅ |
| A-108-01 | lessons.md 2026-06-15 entries split | ✅ |
| A-108-04 | Splitter uses any-list-marker pattern | ✅ |
| A-108-05 | `--write-baseline` doc states active-only capture | ✅ |
| A-108-06 | `announce_yaml_rules_skipped` present | ✅ |
| R-01 / R3 | 0 `SC2046` across all three E2E suites | ✅ |
| R2 | `validateProgressYamlParses` + `progressParsesOk` in exit chain | ✅ |
| R1 | 0 suppressed mutating writes; `_remove_experimental_flag()` present | ✅ |

**27/27 verified.** Four rows initially reported ❌ — all were quoting artifacts in the check harness (`eval` expanding `${...}` and `\$`), not regressions; each was re-verified directly.

## New Finding

| ID | Severity | Finding | Status |
|----|----------|---------|--------|
| A-109-01 | LOW | `.cursor-gh-runs.json` — a Cursor CI-run cache (dated 2026-07-24) sat untracked in the repo root, absent from `.gitignore`, permanently polluting `git status` and at risk of being swept into a `git add -A` | **Fixed** — added under "Editor files"; verified it shadows no tracked path |

## Gate State

| Gate | Result |
|------|--------|
| `acp-validate.ts` | exit 0 |
| `acp.review-measure.sh --ci` | 47 cases, 0 FP, 0 FN, 100%/100% |
| `acp.manifest-hash.sh --verify` | exit 0 |
| vitest | 72/72 |
| E2E (review-scan / review / integrity / package-update / validate) | 66/66 · 71/71 · 77/77 · 13/13 · 17/17 |
| `integrity-v2` | 52/55 — 3 pre-existing (missing PyYAML), identical at HEAD |
| Working tree | 27 tracked changes, **0 untracked** |

## What Remains

Nothing is blocked on unfinished remediation. Three items are outstanding for separate reasons:

| Item | Nature | Blocked by |
|------|--------|-----------|
| **Commit + push the 27-file working set** | Ready now | Awaiting user decision on commit granularity and version bump (`6.29.3` patch — `6.30.0` is reserved for M81 per CHANGELOG) |
| **PR `develop` → `mainline`** | Ready after commit | `next_steps` already lists this for v6.29.2; this work extends it |
| **M81 tasks 270–274** | Genuinely blocked | `tests/fixtures/coderabbit-findings-sample.json` absent — requires a sanitized real CodeRabbit export (external artifact, per ADR-22) |
| **`CRIT-065-002` branch protection** | Deferred, external | GitHub Free tier on a private repo |

`integrity-v2`'s 3 failures are an environment gap (PyYAML not installed), not a code defect — they fail identically at HEAD. Installing PyYAML locally would close them.

## Recommendations

1. **Commit the working set.** It is the largest remaining risk: 27 files of verified work exist only in the working tree. Suggested split — (a) F-107 remediation + regression tests, (b) audit-108 validator gates, (c) memory corruption repairs.
2. **Bump to `6.29.3`** — patch level; these are fixes plus internal validator gates, and `6.30.0` is reserved for M81.
3. **Anchor future ledger tooling on keys, not prose.** This audit and audit-108 both produced false positives from unanchored matching; it is now a recurring class.
4. M81 remains correctly gated. Do not start 270–274 until the fixture exists — that gate is what ADR-22 exists to enforce.

---

**Findings**: 1 new (LOW, fixed) · **27/27 prior findings verified closed**
**Carryovers**: 0 pending · 1 documented deferral
**Verdict**: All carryovers, findings, and shortcuts are addressed. The outstanding work is committing, not fixing.
