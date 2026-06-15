---
id: local.upstream-integration-runbook
version: 1.0.0
category: process
task: task-157
---

# Upstream Integration Runbook

<!-- @acp.meta.pattern
topic: upstream, integration, runbook
description: Upstream Integration Runbook
applies_to: testing, quality
status: active
updated: 2026-06-15
@acp.meta.end -->

## When to Run

Run when upstream (`prmichaelsen/agent-context-protocol`) releases a new minor or major version.
Check: https://github.com/prmichaelsen/agent-context-protocol/blob/mainline/CHANGELOG.md
Find last-checked version in `agent/memory/sessions.md` (`key_fact` field of last M29+ session).

## Step-by-Step Process

1. **Identify new upstream version** — Read upstream CHANGELOG since the last ACP Enhanced sync version. List every new feature, renamed concept, removed item, and behavioral change.

2. **Verify locally before assuming missing** — For each new feature, search ACP Enhanced before marking as missing: `grep -r "keyword" agent/commands/ agent/scripts/ agent/patterns/`. Many upstream additions already exist locally under a different commit history.

3. **Compare files side-by-side for shared features** — For features present in BOTH codebases, open the upstream file and the local file. If they diverge intentionally → assign **DIVERGED** (not HAVE) and document the reason. If they are semantically equivalent → assign **HAVE** with a citation of both file paths.

4. **Run code-level audit before classifying gaps** — Never classify as PORT without opening the local file at the relevant section. Local implementations may predate the upstream introduction date.

5. **Apply the 4 ACP Enhanced hard constraints to any gap:**
   - macOS BSD bash 3.2 — no `mapfile`, `readarray`, `declare -A`, `printf '%q'`
   - No external deps — no `jq`, `yq`, `python`, `node` in bash scripts
   - Token budget — new command docs must not push session context over 5,000 tokens
   - `/acp-` naming — upstream `@acp.<name>` → local `/acp-<name>` (see Naming Translation below)

6. **Assign decision code** — HAVE / PARTIAL / DIVERGED / PORT / DEFER — in `agent/design/local.upstream-parity-matrix.md`. Update summary statistics.

7. **For PORT items:** create tasks in the next available milestone. Each task must include the post-port safety gate: run `bash run-e2e-tests.sh` (≥95% pass) and verify any new bash is macOS BSD 3.2-compatible.

8. **For DIVERGED items:** document the divergence reason in the parity matrix notes column. Do not change ACP Enhanced behavior to match upstream unless a decision is made via `/acp-decide`.

9. **Update ADR-7 and ADR-8** if the integration strategy changes (e.g., new exclusion class discovered, new constraint identified).

## Naming Translation Rule

```
upstream format:  @acp.<name>           (e.g. @acp.sync, @acp.proceed)
ACP Enhanced:     /acp-<name>           (e.g. /acp-sync, /acp-proceed)

Rule: replace @acp.<name> → /acp-<name> in all ported content
      NEVER use @acp-<name> — hyphen after @ is invalid
      NEVER keep @acp.<dot> notation — eliminated per ADR-4
```

## Why No Git Merge — CRITICAL

> **NEVER run `git merge upstream/mainline`**
> **NEVER run `git cherry-pick` on upstream commits**

Upstream rewrote history at v6.0.0 (squash-merge rebase). There is no shared ancestor between upstream `mainline` and ACP Enhanced `mainline`. A merge will corrupt the repository with thousands of false conflicts and may silently overwrite intentional ACP Enhanced divergences.

All upstream integration is manual: read upstream files → compare with ACP Enhanced files → port only after analysis confirms safety. See ADR-7 for full context.

## Reference Documents

| Document | Purpose |
|----------|---------|
| `agent/memory/decisions.md` ADR-7 | Upstream integration strategy and no-merge ruling |
| `agent/memory/decisions.md` ADR-8 | No-re-port rule for already-ported features |
| `agent/design/local.upstream-parity-matrix.md` | Current feature parity state (197 items) |
| `agent/tasks/milestone-29-upstream-integration-audit/` | M29 task files (process reference) |
