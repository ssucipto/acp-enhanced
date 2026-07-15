# Audit Report: README Accuracy & Implementation Consistency

**Audit**: #005
**Date**: 2026-05-05
**Subject**: Verify all claims in README.md about capabilities, mechanics, comparisons with original ACP, and memory/routing system descriptions against actual implementation

---

## Summary

README.md and supporting docs (AGENT.md, docs/USAGE.md, agent/artifacts/glossary) were audited against the actual implementation. The vast majority of claims are accurate. **Three issues were found** ranging from a critical functional bug to inaccurate token estimates. The most impactful issue is that 7 prompt/opencode command files reference `.agent/` (a non-existent path — the real path is `agent/`) which will cause commands to silently fail on any fresh install.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| README.md | doc | Primary audit target — all claims |
| AGENT.md | doc | Layer token estimates, persona descriptions |
| docs/USAGE.md | doc | Memory auto/manual breakdown |
| agent/artifacts/glossary-1-core-terminology.md | artifact | Term definitions |
| .github/prompts/*.prompt.md (58 files) | command | Slash command implementations |
| .opencode/commands/*.md (58 files) | command | opencode slash commands |
| agent/commands/*.md (53 files) | command | Backing command docs |
| scripts/acp-bootstrap.sh | script | Bootstrap phases claim |
| scripts/acp-dispatch.ts | script | Cost figures, model IDs |
| agent/routing/taxonomy.yml | config | Model selection claims |
| agent/routing/rules.md | config | Routing rule claim |
| agent/core/identity.yml + constraints.yml + routing.yml | config | Layer 1 token size |
| agent/skills/*.md (6 files) | config | Layer 2 token size |

---

## Key Findings

| # | Finding | Severity | Location | Status |
|---|---------|----------|----------|--------|
| 1 | 7 prompt + opencode command files use `.agent/` path (does not exist — real path is `agent/`) | **CRITICAL** | See list below | ❌ Unfixed |
| 2 | Layer 1 token estimate: README/AGENT.md claims ~180 tokens; actual is ~875 tokens | **INACCURATE** | AGENT.md line 820, README implied | ❌ Unfixed |
| 3 | Layer 2 token estimate: README/AGENT.md claims ~240–350 tokens; actual is ~472–657 tokens | **INACCURATE** | AGENT.md line 821 | ❌ Unfixed |
| 4 | `/acp-route` has no backing `agent/commands/acp.route.md` (exists only as prompt/opencode) | **GAP** | agent/commands/ | ❌ Unfixed |
| 5 | 5 other commands (`/acp-commit`, `/acp-decide`, `/acp-cost-report`, `/acp-memory-sync`, `/acp-wiki-update`) have no backing command docs | **GAP** | agent/commands/ | ❌ Unfixed |
| 6 | Bootstrap described as "two phases" in README; actual script has 7 numbered steps | **IMPRECISE** | README.md line 40–43 | ❌ Unfixed |
| 7 | All other README claims verified accurate | — | — | ✅ Confirmed |

---

## Finding 1 (CRITICAL): `.agent/` Path Bug

Seven files reference `.agent/` which does not exist. The real directory is `agent/`. This means on any project that doesn't happen to have a `.agent/` symlink, these commands silently fail or produce wrong paths.

**Affected files (both `.github/prompts/` and `.opencode/commands/` copies):**

| Command | References to `.agent/` |
|---------|------------------------|
| `/acp-route` | 4 (taxonomy.yml, rules.md, tasks/, ledger.md) |
| `/acp-commit` | 3 (sessions.md, patterns.md, tasks/) |
| `/acp-decide` | 2 (decisions.md × 2) |
| `/acp-cost-report` | 1 (ledger.md) |
| `/acp-init` | 2 (wiki/domain.yml, wiki/architecture.md) |
| `/acp-memory-sync` | 3 (sessions.md, patterns.md, wiki/architecture.md) |
| `/acp-wiki-update` | 3 (wiki/architecture.md × 2, wiki/domain.yml) |

All references should be `agent/` not `.agent/`.

**Note**: The `.github/prompts/acp-init.prompt.md` also writes to `.agent/wiki/` — meaning `/acp-init` would try to create wiki files in a non-existent hidden directory instead of `agent/wiki/`.

---

## Finding 2–3: Token Estimate Inaccuracy

Measured against actual file sizes (1 token ≈ 4 chars):

| Layer | README/AGENT.md Claim | Actual Measured |
|---|---|---|
| Layer 1 (3 core files) | ~180 tokens | ~875 tokens |
| Layer 2 (one skill file) | ~240–350 tokens | ~472–657 tokens |
| Total per task | ~1,680–2,230 tokens | ~2,550–3,300 tokens (est. with Layer 3) |

The estimates are off by ~4–5× for Layer 1 and ~2× for Layer 2. These numbers appear in AGENT.md's "Three-Layer Context Model" table and indirectly inform the "2,800-token budget" framing. The budget claim is conceptually valid (it exists as a discipline practice, not a technical cap), but the per-layer numbers are not accurate and should be updated.

---

## Finding 4–5: Missing Command Docs

The following commands exist as prompts/opencode slash commands but have **no backing `agent/commands/*.md`** file. This means on agents other than Copilot/opencode (e.g., Claude Code, any LLM), a user who follows the README instruction *"Tell your agent: read and execute agent/commands/acp.init.md"* cannot use these commands:

| Command | In `.github/prompts/` | In `agent/commands/` |
|---|---|---|
| `/acp-route` | ✅ | ❌ |
| `/acp-commit` | ✅ | ❌ |
| `/acp-decide` | ✅ | ❌ |
| `/acp-cost-report` | ✅ | ❌ |
| `/acp-memory-sync` | ✅ | ❌ |
| `/acp-wiki-update` | ✅ | ❌ |

These are some of the most important commands in the ACP Enhanced workflow. `/acp-commit` in particular is mentioned as the #1 required daily habit.

---

## Finding 6: "Two Phases" Bootstrap Description

README.md says the bootstrap "runs in two phases":
1. Framework layer — creates `agent/` directory structure and `AGENTS.md`
2. Commands + scripts — downloads and installs `agent/commands/`, `agent/scripts/`, `agent/schemas/`

The actual script has **7 numbered steps** (`# --- 1.` through `# --- 7.`). The "two phases" framing is a rough simplification, not wrong, but imprecise for a user trying to understand what will happen. Minor issue.

---

## Verified-Accurate Claims

| Claim | Verified |
|---|---|
| 58 slash commands in both Copilot and opencode | ✅ Confirmed: 58 in both directories |
| agent/commands has 53 command docs (not 58 — template excluded) | ✅ Accurate |
| Preferences system: 4-level hierarchy (project > workspace > user > default) | ✅ Confirmed in acp.preferences-show.md |
| Project registry at `~/.acp/projects.yaml` | ✅ File exists at `~/.acp/projects.yaml` |
| Model costs: flash $0.14/$0.28, pro $0.44/$0.87 | ✅ Matches dispatch.ts MODEL_MAP |
| `override_executor:` frontmatter field works | ✅ Confirmed in routing/rules.md |
| dispatch.ts logs to `agent/routing/ledger.md` | ✅ Confirmed in appendLedger() |
| Bootstrap creates `.github/prompts/` and `.opencode/commands/` | ✅ Steps 6 and 6b |
| Bootstrap is re-run safe (`[ -f ] \|\|` guards on memory files) | ✅ Confirmed in steps 3, 4, 5 |
| sessions.md compacted at 15 entries | ✅ In acp-commit.prompt.md step 5 |
| Routing rules: new from scratch → pro, fix existing → flash | ✅ Confirmed in routing/rules.md |
| `agent/core/routing.yml` updated per session by dispatch | ✅ updateRoutingYml() in dispatch.ts |
| ACP workflow (clarifications → design → plan → proceed) identical to original | ✅ Core command docs unmodified in substance |
| Memory row "None — every session starts cold" for original ACP | ✅ Accurate |
| `agent/memory/sessions.md` loads last 3 entries | ✅ Confirmed in dispatch.ts getLastNSessions(3) and AGENTS.md protocol |

---

## Code Pointers

| Location | Description |
|---|---|
| .github/prompts/acp-route.prompt.md:8 | `.agent/routing/taxonomy.yml` — wrong path |
| .github/prompts/acp-commit.prompt.md:9 | `.agent/memory/sessions.md` — wrong path |
| .github/prompts/acp-init.prompt.md:12 | `.agent/wiki/domain.yml` — wrong path |
| .opencode/commands/acp-route.md:7 | `.agent/routing/taxonomy.yml` — wrong path |
| AGENT.md:820 | Layer 1 token estimate: ~180 tokens (actual: ~875) |
| AGENT.md:821 | Layer 2 token estimate: ~240–350 tokens (actual: ~472–657) |
| scripts/acp-dispatch.ts:22–29 | MODEL_MAP — cost figures match README |
| scripts/acp-dispatch.ts:47 | getLastNSessions(3) — confirms 3 sessions loaded |
| agent/routing/rules.md:2–7 | Priority order for routing — matches README description |
| scripts/acp-bootstrap.sh:19–1159 | 7 steps, not 2 phases |

---

## Git History (Recent Relevant Commits)

| Date | Hash | Summary |
|---|---|---|
| 2026-05-04 | 81743d3 | docs: add model routing guide, memory layer breakdown, glossary |
| 2026-05-04 | 50d2ffb | feat(M28): opencode command parity + audit fixes (v6.4.0) |
| 2026-05-03 | 9913ac2 | feat(M27): distribution readiness fixes |

---

## Recommendations

1. **[CRITICAL — Fix now]** Replace all `.agent/` with `agent/` in the 7 affected prompt files and their 7 mirrored opencode command files (14 files total). This is a functional bug — these commands will silently use wrong paths on fresh installs.

2. **[Important — Fix soon]** Create `agent/commands/` backing docs for the 6 missing commands (`acp.route.md`, `acp.commit.md`, `acp.decide.md`, `acp.cost-report.md`, `acp.memory-sync.md`, `acp.wiki-update.md`). These are the most critical daily-use commands and should be accessible to non-Copilot/non-opencode agents.

3. **[Minor — Fix in next doc pass]** Update AGENT.md layer token estimates to reflect actual measured values (~875 for Layer 1, ~500–660 for Layer 2). The "2,800-token budget" headline can stay — it's a discipline cap, not a measurement.

4. **[Minor — Optional]** Replace "two phases" with "seven steps" in the bootstrap description, or simply say "a series of steps" to avoid locking to a number.
