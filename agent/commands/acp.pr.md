# Command: pr

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-pr` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-pr` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."
>
> **This is an ACTION command** — run local gates (via `/acp-ci`), prepare/push a feature branch, and optionally open a PR. Do not stop at a checklist summary.

**Namespace**: acp  
**Version**: 1.2.0  
**Created**: 2026-08-14  
**Last Updated**: 2026-08-28  
**Status**: Active  
**Scripts**: `agent/scripts/acp.pr.sh`, `agent/scripts/acp.ci.sh`  

---

**Purpose**: Open a feature PR to the default working branch with local CI gates  
**Category**: Workflow / Release  
**Frequency**: After each shippable slice (milestone batch, task group)  

---

## Arguments

| Flag | Aliases | Description |
|------|---------|-------------|
| `--dry-run` | | Show plan only; no push/PR; gates still delegated with `--dry-run` |
| `--yes` | `-y` | Skip confirmation prompts |
| `--skip-local` | | Skip local gates (CI is the remaining gate) |
| `--strict-local` | | Run **full** CI tier locally instead of `fast` |
| `--auto` | | Derive title/body from commits since base |
| `--skip-push` | | Local gates only |
| `--base BRANCH` | | PR base (default: `identity.yml → git_workflow.default_working_branch`) |
| `--branch NAME` | | Feature branch (required if on default branch with unpushed commits) |
| `--title TEXT` | | PR title |
| `--body TEXT` | | PR body |
| `--body-file PATH` | | PR body from file |
| `--create-pr` | | Run `gh pr create` after push |
| `-h`, `--help` | | Help |

**Natural language examples**:
- `/acp-pr` — infer branch/title from chat context
- `/acp-pr --dry-run` — preview only
- `/acp-pr --strict-local` — full gates before release PR

### Argument Parsing

Default base = `develop` (AE gitflow-lite). Production branch = `mainline`. Never invent CodeRabbit wave ids or fixtures (M81 / ADR-22).

---

## What This Command Does

`/acp-pr` routine-izes the **feature PR handshake** for this repo: verify branch safety, run local gates, push a feature branch, open a PR against `develop` (or configured default working branch).

**Gate rule (D2 / ADR-24)**: `acp.pr.sh` implements **no** validate/shellcheck/e2e/tsc/lint gate logic. It **only** calls `bash agent/scripts/acp.ci.sh …`.

| Mode | Delegation |
|------|------------|
| default | `acp.ci.sh --fast` |
| `--strict-local` | `acp.ci.sh --full` |
| PR base = `production_branch` (`mainline`) | `acp.ci.sh --full` |

`/acp-ci --fast` beforehand is feedback; this step is enforcement.

---

## Prerequisites

- [ ] On `default_working_branch` (`develop`), `feature/*`, or `fix/*` — **not** `production_branch` (`mainline`)
- [ ] Commits ready (do not bundle unrelated WIP)
- [ ] Prefer `/acp-ci --fast` already green — this command re-runs it
- [ ] Optional: `/acp-smoke` if the slice touched device/UI launch paths — this command does **not** wait and **must not** call `acp.smoke.sh`
- [ ] `gh` authenticated only if `--create-pr`

---

## Steps

### 0. Display Command Header

```
⚡ /acp-pr
  Local gates → feature branch → push → PR

  Usage:
    /acp-pr                              Infer from context
    /acp-pr --dry-run                    Preview only
    /acp-pr --strict-local               Full CI tier locally
    /acp-pr --create-pr --title "…"      Open PR via gh

  Related:
    /acp-ci          Local CI predictor (gates live here)
    /acp-smoke       Optional device preflight; this command does not invoke it
    /acp-review      Local ACP rule scan before PR
    /acp-commit      Session memory for the slice
```

### 1. Branch safety

Read `agent/core/identity.yml → git_workflow`.

- **On `production_branch` (`mainline`)** → STOP with switch instructions.
- **On `default_working_branch` with unpushed commits** → require `--branch feature/…`.

### 2. Optional CodeRabbit path-filter check

If `agent/scripts/acp.coderabbit.sh` exists **and** CodeRabbit preferences/config are present, run the path-filter check.  
If **not** configured → emit **SKIP** with an install/config hint (never silent pass). Do **not** invent fixtures.

### 3. Infer PR metadata (`--auto`)

| Field | Derived from |
|-------|--------------|
| Branch | current branch |
| Base | `git_workflow.default_working_branch` |
| Title | first commit subject since base |
| Body | commit list + `task-NNN` ids + test-plan checklist |

### 4. Run local gates (delegation only)

Unless `--skip-local`:

```bash
bash agent/scripts/acp.ci.sh --fast          # default
bash agent/scripts/acp.ci.sh --full          # --strict-local or base=mainline
```

**FORBIDDEN**: duplicated tsc/lint/test/shellcheck implementations inside `acp.pr.sh`.

### 5. Push / create PR

Only when not `--dry-run` / not `--skip-push`. Use `gh pr create` when `--create-pr` or title provided.

---

## Verification

- [ ] `rg -n "tsc|jest|eslint|shellcheck" agent/scripts/acp.pr.sh` shows no gate implementations (help strings OK)
- [ ] Script calls `acp.ci.sh`
- [ ] `--dry-run` prints `delegating to: acp.ci.sh --fast` (or `--full`) without network
- [ ] Branch safety respects `develop` → `mainline`

## User-Observable Acceptance

`bash agent/scripts/acp.pr.sh --dry-run` prints `delegating to: acp.ci.sh --fast` (or equivalent).

---

## Related Commands

- [`acp.ci.md`](acp.ci.md) — local CI gates (required dependency)
- [`acp.smoke.md`](acp.smoke.md) — optional device preflight; **do not** call from `acp.pr.sh`
- [`acp.commit.md`](acp.commit.md) — session memory
- [`acp.review.md`](acp.review.md) — quality scan before PR
- [`acp.stakeholder-report.md`](acp.stakeholder-report.md) — PR summary material
