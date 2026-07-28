# CodeRabbit CLI — Local Thorough Review Playbook (ACP Enhanced)

How to run a **thorough local** CodeRabbit campaign on this repository.

> **Binding constraint** — CodeRabbit CLI reviews **git diffs only**. It cannot
> audit the whole tree in one shot. Thorough = many scoped reviews + ACP
> `/acp-review` (Phase 1 scanner + Phase 2 agent).

> **ADR-22** — CLI `--agent` JSON does **not** satisfy the M81 gate artifact
> `tests/fixtures/coderabbit-findings-sample.json` (that must be a sanitized
> **PR-comment** export). CLI output may inform importer design only.

---

## Prerequisites

```bash
coderabbit doctor          # storage + auth + git
coderabbit auth status     # org/seat (consumer-project login OK for local CLI)
```

Working tree should be clean of junk (e.g. do not review `.cursor-gh-runs.json`).

---

## Layer A — ACP native (always first)

```bash
# Phase 1 deterministic (8 rules)
bash agent/scripts/acp.review-scan.sh --ci scripts/ agent/scripts/

# Phase 2 — agent /acp-review --self --report --carryover (HIGH+)
# Stamp recurring_tasks.weekly-code-review after the campaign.
```

Integrity weekly (separate command / agent):

```text
/acp-integrity --self --report --carryover
```

---

## Layer B — Chunked CodeRabbit CLI

### Artifact layout

```
agent/reports/coderabbit-local-YYYY-MM-DD/
  MANIFEST.md
  chunk-scripts-ts.json          # --agent stdout / findings
  chunk-agent-scripts.json
  chunk-e2e-tests.json
  chunk-ci-workflows.json
  chunk-since-v6.27.json         # optional recent-tag window
```

Sanitize before commit: strip emails, tokens, absolute `$HOME` paths, private URLs.

### Chunk table

| Chunk | When there is a diff vs mainline | When no diff (use history) |
|-------|----------------------------------|----------------------------|
| TS tooling | `coderabbit review --dir scripts --base origin/mainline --agent` | `--base-commit <sha-before-scripts-change>` |
| Agent bash | `coderabbit review --dir agent/scripts --base origin/mainline --agent` | historical window touching `agent/scripts` |
| E2E | `coderabbit review --dir e2e --base origin/mainline --agent` | same |
| Unit tests | `coderabbit review --dir tests --base origin/mainline --agent` | same |
| CI | `coderabbit review --dir .github/workflows --base origin/mainline --agent` | same |
| Recent era | `coderabbit review --base v6.27.0 --agent` | if too many files → subdivide with `--dir` |

### Finding historical windows

```bash
# Commits that touched a path since a tag
git log --oneline v6.27.0..HEAD -- scripts/ | head
# Parent of first commit in that list can be --base-commit
```

If CLI says **too many files**, narrow `--dir` (e.g. `scripts/` → review only `scripts/acp-validate.ts` via a small dedicated branch/commit window — prefer dir narrowing first).

### Capture pattern

```bash
OUT=agent/reports/coderabbit-local-$(date +%Y-%m-%d)
mkdir -p "$OUT"
coderabbit review --dir scripts --base-commit <SHA> --agent 2>&1 | tee "$OUT/chunk-scripts-ts.raw.json"
# Prefer copying structured findings from coderabbit review findings when available
```

---

## What not to do

- Do **not** create a synthetic “touch every file” commit on `develop`/`mainline` to force a full-repo scan.
- Do **not** claim CLI JSON unblocks M81 task-270+.
- Do **not** invent carryover fields (`source:`, etc.) — live ledger shape only.

---

## Related

- [Working with CodeRabbit](coderabbit-integration.md) (product optionality + M81 roadmap)
- [Policy map lite](coderabbit-policy-map-lite.md) (Phase 1 never deferred)
- Milestone: `agent/milestones/milestone-82-local-thorough-review-campaign.md`
