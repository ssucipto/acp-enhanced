# Command: ci

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-ci` or `/acp-ci-check` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-ci` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."
>
> **This is an ACTION command** — run the gates locally and report the result. Do not stop at a checklist summary.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-08-14  
**Last Updated**: 2026-08-14  
**Status**: Active  
**Scripts**: `agent/scripts/acp.ci.sh`, `agent/scripts/acp.ci-steps.sh`  

---

**Purpose**: Run the gates GitHub Actions runs, locally, before pushing  
**Category**: Workflow / Quality  
**Frequency**: `--static` continuously; `--fast` before every PR; `--full` when matching PR-blocking + soft supply-chain  
**Aliases**: `/acp-ci-check` (same command)

---

## Arguments

| Flag | Aliases | Description |
|------|---------|-------------|
| `--static` | | Cheapest gates: ci-validate, npm-test, validate-ts (~seconds) |
| `--fast` | | **Default**: T0+T1 — static + review-measure + integrity e2e. **No** shellcheck, **no** full e2e-smoke (~tens of seconds–~2 min) |
| `--full` | | CI-equivalent: adds shellcheck (~40s), e2e-smoke (~4.5+ min), npm-audit, e2e-matrix. Opt-in only. |
| `--only ID[,ID]` | | Explicit step list, ignoring tiers (unknown id → non-zero) |
| `--dry-run` | | Print the plan without executing gates (FG-6: not verification) |
| `--doctor` | | Probe dependencies, print the matrix, run no gates |
| `-h`, `--help` | | Help |

**Cost guidance** (see `agent/reports/m86-ci-job-baseline.md`): default `/acp-ci` stays interactive; `--full` matches multi-minute CI e2e-smoke.

**Step ids** (from `agent/configurables/ci.yml`):  
`validate-ts` `review-measure` `npm-test` `ci-validate` `shellcheck` `integrity-e2e` `integrity-v2-e2e` `e2e-smoke` `npm-audit` `e2e-matrix`

**Natural language examples**:
- `/acp-ci` — default fast tier
- `/acp-ci --static` — quick check mid-session
- `/acp-ci before PR` — infer `--fast`
- `/acp-ci full parity` — infer `--full`
- `/acp-ci --only shellcheck` — re-run one gate after a fix

### Argument Parsing

Parse flags from the user message. Unstated tier → `--fast`. Mid-session / "quick" → `--static`. "before release" / "full parity" → `--full`. Never invent Expo/Firebase flags.

---

## What This Command Does

`/acp-ci` closes the gap where agents report green after `/acp-validate`, `/acp-review`, or `/acp-integrity` while **GitHub Actions still fails**. It runs the same class of checks `.github/workflows/ci.yaml` (and e2e-tests for `--full`) run, with tiered depth, and **zero git or network side effects** — no commits, no push, no `gh`.

AE CI is **multiple jobs**, not one:

| Workflow job | Typical tier |
|--------------|--------------|
| `validate` | static / fast (split steps) |
| `shellcheck` | **full** only (~40s T2) |
| `e2e-smoke` (integrity parts) | fast (integrity-e2e / integrity-v2-e2e) |
| `e2e-smoke` (full `run-e2e-tests`) | **full** only (~4.5+ min T2) |
| `supply-chain` | full (soft / allow_skip) |
| `e2e` (matrix) | full (local single-OS proxy) |
| `benchmark` | out of scope |

**`/acp-pr` delegates its local gates here** — gate logic lives in exactly one place (ADR-24 / D2).

Config: `agent/configurables/ci.yml` (runtime matrix — **not** a preference; P-CI-1).  
Bodies: `agent/scripts/acp.ci-steps.sh` (P-PATH-1).

**Env overrides** (tests / advanced):
| Variable | Default | Purpose |
|----------|---------|---------|
| `ACP_CI_CONFIG` | `agent/configurables/ci.yml` | Alternate runtime matrix path |
| `ACP_CI_STEPS_LIB` | `agent/scripts/acp.ci-steps.sh` | Alternate step-bodies library (must still expose `ci_run_step`) |

---

## Prerequisites

- [ ] Run from anywhere inside the repo (script resolves the root)
- [ ] `agent/configurables/ci.yml` present
- [ ] `node` / `npm` / `npx` for validate-job TypeScript steps
- [ ] `shellcheck` for the shellcheck step (hard-fail unless removed from plan)
- [ ] Optional soft tools per `allow_skip` steps

Run `/acp-ci --doctor` to see what is present and what will SKIP.

---

## Steps

### 0. Display Command Header

```
⚡ /acp-ci
  Run the gates GitHub Actions runs, locally, before pushing

  Usage:
    /acp-ci                      Default fast tier
    /acp-ci --static             Static checks only
    /acp-ci --full               Full local PR-gate parity
    /acp-ci --only shellcheck    Re-run specific gates
    /acp-ci --doctor             Dependency matrix

  Related:
    /acp-pr        Open the PR once gates are green
    /acp-review    Code quality — different concern
    /acp-validate  ACP document validation — not a CI predictor
    /acp-integrity Provenance scan — not a CI predictor
```

This step is informational only — do not wait for user input.

### 1. Infer the tier

| Signal | Tier |
|--------|------|
| "quick check", mid-session, after one edit | `--static` |
| unstated, "before PR", "is this ready" | `--fast` (default) |
| "full parity", "supply-chain", "e2e matrix" | `--full` |

### 2. Run the script

```bash
bash agent/scripts/acp.ci.sh --fast
```

Do **not** reimplement gates in chat. The script is the single source of truth.

### 3. Report the result

Surface the **first failing step** and a short fix hint. Do not dump the whole log.

### 4. On success

```
[ACP CI] PASS | tier fast | safe to /acp-pr
```

If any step reported **SKIP**, say so explicitly — the run is *not* full CI parity:

```
[ACP CI] PASS (with SKIPs) | tier full — not full CI parity; see SKIP rows
```

Never present a SKIP as green. Never claim PASS when `executed_steps` is 0 (FG-2 / FG-3).

---

## False-green contracts (mandatory)

See `agent/patterns/local.false-green-contracts.md` and `constraints.yml` bash_rules:

| ID | Rule |
|----|------|
| FG-1 | Capture status with `if cmd; then rc=0; else rc=$?; fi` — never `set +e` under `trap ERR` |
| FG-2 / FG-3 | Zero executed steps → non-zero exit (NO-OP), never PASS |
| FG-4 | Unknown `--only` id → exit 2 |
| FG-5 | SKIP ≠ PASS; banner distinguishes PASS vs PASS (with SKIPs) |
| FG-6 | `--dry-run` is planning only — not verification |
| FG-7 | Probe tools via `bash -c 'command -v …'` in script context |

---

## Verification

- [ ] `--help` and `--doctor` exit 0 and run no gates
- [ ] `--dry-run` prints the plan and exits 0 (does not count as verified)
- [ ] Steps execute in `cost_rank` order; summary prints in `ci_rank` / CI job order
- [ ] Results are tri-state PASS / FAIL / SKIP
- [ ] `--only nonexistent` exits non-zero
- [ ] Empty plan cannot PASS
- [ ] No consumer-project product paths in scripts
- [ ] Status capture uses if-context (no `set +e` under ERR trap)

## User-Observable Acceptance

`bash agent/scripts/acp.ci.sh --static` prints a PASS/FAIL/SKIP table whose step ids map to AE CI jobs (`validate`, `shellcheck`, …).

---

## Related Commands

- [`acp.pr.md`](acp.pr.md) — PR prep; delegates gates here
- [`acp.validate.md`](acp.validate.md) — ACP document validation (not CI)
- [`acp.review.md`](acp.review.md) — code quality
- [`acp.integrity.md`](acp.integrity.md) — trustworthiness / provenance
- [`acp.commit.md`](acp.commit.md) — session memory before push
