# Command: smoke

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-smoke` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-smoke` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."
>
> **This is an ACTION command** — run the project smoke runner or fail closed. Do not invent a device path. Do not treat `/acp-ci` as smoke.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-08-28  
**Last Updated**: 2026-08-28  
**Status**: Active  
**Scripts**: `agent/scripts/acp.smoke.sh`  

---

**Purpose**: Optional device preflight via a project-configured runner. Unconfigured → exit 2 (never PASS). Not a CI step.  
**Category**: Workflow / Quality  
**Frequency**: After a device/UI slice, before `/acp-pr` — optional  

---

## Glossary (D15)

| Name | What it is | What it is not |
|------|------------|----------------|
| **`e2e-smoke`** | AE `/acp-ci --full` step id — `run-e2e-tests.sh` | Not `/acp-smoke`. Never `--only smoke`. |
| **`/acp-smoke`** | This command — optional device preflight | Not a GitHub Actions job. Not `e2e-smoke`. |

Consumer repos that already have a CI step named `smoke` keep it. AE does not steal that id.

---

## Arguments

| Flag | Aliases | Description |
|------|---------|-------------|
| `--doctor` | | Print whether `smoke.yml` names a runner and whether it exists. Exit 2 unconfigured; exit 1 configured-but-missing; exit 0 if the runner exists. |
| `--dry-run` | | Print the plan. Do not execute the runner. Unconfigured still exits 2. |
| `--android` | | Passthrough to the **project** runner — not AE Gradle. |
| `--ios` | | Passthrough to the **project** runner. |
| `-h`, `--help` | | Help (exit 0 even when unconfigured) |

**Natural language examples**:
- `/acp-smoke` — run the configured runner, or stop with exit 2
- `/acp-smoke --doctor` — configuration probe only
- `/acp-smoke --dry-run` — plan only (not verification)

### Argument Parsing

`--android` / `--ios` are **forwarded**, not implemented here. Do not add `--host` (M91). Do not boot an emulator in this command.

---

## What This Command Does

`/acp-smoke` is a thin dispatcher. The runner path lives in `agent/configurables/smoke.yml` (`runner:`). That file is a **runtime matrix** (P-CI-1 / D16), not a preference in `acp.configurables.yaml`.

- Missing `smoke.yml` **or** empty `runner:` → **exit 2**, message `not configured`, **no PASS**.
- Configured but the binary/path is missing → **exit 1**.
- `--help` always exits 0.
- Zero `git` / `gh` mutations (same as `acp.ci.sh`).

`/acp-ci` default tiers do **not** include this command. `/acp-pr` **may mention** it; it **does not wait** and **must not** call `acp.smoke.sh`.

---

## Prerequisites

- [ ] Optional: `agent/configurables/smoke.yml` with a non-empty `runner:`
- [ ] This repo (AE) ships an empty runner on purpose — exit 2 is correct

---

## Steps

### 0. Display Command Header

```
⚡ /acp-smoke
  Optional device preflight (fail-closed if unconfigured)

  Usage:
    /acp-smoke                 Run project runner or exit 2
    /acp-smoke --doctor        Probe config (no device)
    /acp-smoke --dry-run       Print plan; do not exec

  Related:
    /acp-ci --fast    Local CI predictor (does not run this command)
    /acp-pr           Feature PR; does not wait on smoke
```

### 1. Probe configuration

Read `ACP_SMOKE_CONFIG` or `agent/configurables/smoke.yml`. If the file is missing or `runner:` is empty, print `not configured` and **Stop** with exit 2.

### 2. Doctor / dry-run / run

- `--doctor`: print config path and whether the runner exists; do not exec.
- `--dry-run`: print `would exec: …`; do not exec. Unconfigured still exit 2 (FG-2).
- Default: exec the runner with any `--android` / `--ios` / extra args. Do not invent Gradle or emulator flags.

### 3. Do not confuse with CI

Never tell the operator that `/acp-ci --fast` “covers smoke”. Fast tier has **no** `e2e-smoke`. Full tier `e2e-smoke` is the **E2E test job**, not this command.

---

## Verification

- [ ] `bash agent/scripts/acp.smoke.sh --help` exits 0
- [ ] Unconfigured `bash agent/scripts/acp.smoke.sh` exits 2 and prints `not configured`
- [ ] `--doctor` on this repo exits 2
- [ ] `grep acp.smoke.sh agent/scripts/acp.pr.sh` is empty
- [ ] No `--host` in this command or script
- [ ] `grep -E '^  smoke:' agent/configurables/ci.yml` is empty

## User-Observable Acceptance

On ACP Enhanced (empty `runner:`): `bash agent/scripts/acp.smoke.sh` exits **2** and does **not** print PASS.

---

## Related Commands

- [`acp.ci.md`](acp.ci.md) — local CI predictor (`e2e-smoke` is a **full-tier** step, not this command)
- [`acp.pr.md`](acp.pr.md) — feature PR; optional mention of `/acp-smoke`; does not invoke it
- [`../wiki/exec-host.md`](../wiki/exec-host.md) — Windows OpenSSH inner-loop (012) rules
- [`acp.review.md`](acp.review.md) — code quality before a slice
- [`acp.integrity.md`](acp.integrity.md) — trust scan; distinct from device preflight
