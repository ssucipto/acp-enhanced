# Audit Report: Optional CodeRabbit Integration into ACP

**Audit**: #97
**Date**: 2026-07-22
**Subject**: How to integrate CodeRabbit into ACP Enhanced as an **optional** capability — ACP consumers may not have CodeRabbit, so the framework must degrade gracefully when it is absent.

## Summary

Prior direction research (`research-acp-vs-coderabbit-aikido-2026.md`, 2026-07-15) and **ADR-19** (2026-07-17) already concluded the strategy — *buy detection, build governance, integrate the two* — and gated the M74–M77 build roadmap until CodeRabbit + Aikido are operational on a Rygan repo with 2+ weeks of real findings. That work framed CodeRabbit as **Rygan's own** tooling for its own repos.

This audit addresses a **different, un-covered concern**: ACP Enhanced is a *distributed framework* (`fork_of` upstream, published as packages, installed by other teams). Any CodeRabbit integration shipped in ACP will land in repos where CodeRabbit is **not installed**. So optionality is not a nice-to-have — it is a **hard design constraint** on the integration surface. This audit does **not** re-open ADR-19; it defines the *optionality contract* that the (gated) M75 integration layer must satisfy, and identifies the one integration piece that is safe to ship **before** the gate because it is inert for non-users.

**Key takeaway**: ACP already has every mechanism it needs for optional external tooling — a preferences/configurables toggle system, a proven `command -v` graceful-degradation pattern, and conditionally-executed recurring tasks. The integration should be built as *feature-detected + preference-gated + off-by-default*, exactly like the existing `gh`-dependent branch-protection command.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| agent/reports/research-acp-vs-coderabbit-aikido-2026.md | doc | Prior gap analysis; M74–M77 roadmap; §4 integration steps |
| agent/memory/decisions.md (ADR-19) | doc | Gates the build; scopes what this audit may/may not touch |
| agent/configurables/acp.configurables.yaml | config | Preference-definition schema — home for an `enabled` toggle |
| agent/scripts/acp.preferences.sh | source | Resolves preference precedence (project>workspace>user>default) |
| agent/scripts/acp.branch-protection-setup.sh | source | **Exemplar**: `command -v gh` detection + clean exit when absent |
| agent/scripts/acp.common.sh | source | Repeated `command -v` capability-detection idiom (sha256, jq, yaml) |
| agent/progress.yaml (recurring_tasks) | config | weekly-code-review / monthly-dependency-audit — conditional wiring |
| .github/workflows/ci.yaml, e2e-tests.yaml | config | Where CodeRabbit CI hooks would (optionally) attach |
| agent/preferences/acp.default.yaml | config | Default preference values ship here |

## Key Findings

| Finding | Location | Notes |
|---------|----------|-------|
| ADR-19 gates the *build*, not the *design constraint* | decisions.md:163 | Optionality is orthogonal to the adoption gate — it can be specified now without violating "no M74–M77 progress.yaml entries" |
| Prior research assumed Rygan-owned repos | research-…-2026.md §3–4 | "Generate `.coderabbit.yaml`", "rewire recurring tasks" implicitly assume CodeRabbit is present — no absent-tool path specified. **This is the gap this audit fills.** |
| ACP already has an optional-tool exemplar | acp.branch-protection-setup.sh:27 | `command -v gh` → explicit message + non-fatal exit. This is the template for CodeRabbit optionality |
| Preferences system is the correct toggle home | acp.configurables.yaml:28, acp.preferences.sh | 4-level precedence already exists; add `integrations.coderabbit.*` keys, default `enabled: false` |
| `.coderabbit.yaml` is inert for non-users | (artifact) | A generated config file is read *only* by CodeRabbit's bot. In a repo without CodeRabbit it is a harmless dotfile — **safe to generate pre-gate** |
| Recurring tasks must not hard-depend | progress.yaml:7147 | weekly-code-review currently runs `/acp-review`; adding a CodeRabbit step must be a *conditional branch*, not a replacement |
| 2 open carryovers exist (unrelated) | audit-carryovers.md | e.g. "FIFOZ consumer path — /acp-version-update on downstream not verified" — noted, not addressed here |

## Optionality Design Contract (the deliverable)

The integration must satisfy **three independent gates**, all of which must be true for any CodeRabbit-specific behaviour to activate:

| Gate | Mechanism | Default | Rationale |
|------|-----------|---------|-----------|
| **1. Preference opt-in** | `integrations.coderabbit.enabled` (boolean) via configurables/preferences | `false` | Off-by-default; a fresh ACP install never assumes CodeRabbit |
| **2. Feature detection** | `.coderabbit.yaml` present in repo **OR** CodeRabbit app detectable | n/a | Even if enabled, verify before acting — mirrors `command -v gh` |
| **3. Graceful degradation** | Every code path has an "absent" branch that skips + optionally hints | skip silently | Absence is normal, not an error — unlike branch-protection where `gh` is required |

**Degradation behaviour per integration point:**

| Integration point | When CodeRabbit present + enabled | When absent / disabled |
|---|---|---|
| `.coderabbit.yaml` generation (from patterns/lessons) | Generate/refresh on `/acp-commit` | **Still generate** — inert file, no-op for non-users; or skip if `enabled:false` |
| `acp.findings-import.sh` (findings → carryovers) | Ingest CodeRabbit findings | No-op; carryover ledger works from `/acp-review` alone |
| weekly-code-review recurring task | Add "check CodeRabbit open findings" step | Runs `/acp-review` only — unchanged from today |
| Golden-path scaffold (project-create) | Offer to scaffold `.coderabbit.yaml` + CI hook | Scaffold ACP-only; CodeRabbit hook omitted or commented-out |
| `/acp-review` report | Note "N findings deferred to CodeRabbit engines" | Report full ACP-only coverage; no dangling references |

**Anti-pattern to avoid**: making `/acp-review` *depend* on CodeRabbit for correctness. ACP's review/carryover loop must remain fully functional standalone — CodeRabbit *augments* it, never *replaces* a code path.

## Interaction with ADR-19 (scope discipline)

| Question | Answer |
|---|---|
| Does this re-open ADR-19? | **No.** ADR-19 gates creating M74–M77 *milestone/task entries*. This audit specifies a design constraint, not a build. |
| Can anything ship before the gate clears? | **Yes — one piece.** The `.coderabbit.yaml` generator is a pure output artifact that is inert in non-CodeRabbit repos. It can be prototyped as ops scaffolding. Everything requiring live findings (`findings-import`, recurring-task rewire) stays gated. |
| Where does the optionality contract live until M75? | This report + a carryover, so M75 planning inherits it rather than re-deriving it. |

## Recommendations

1. **Attach this optionality contract to M75 as an acceptance criterion** — "every CodeRabbit code path has a tested absent-tool branch; fresh ACP install with no CodeRabbit passes all E2E." Do this at `/acp-plan M75` time (post-gate), not now.
2. **Reserve the preference keys now** (cheap, non-gated): add `integrations.coderabbit.enabled: false` (+ `.config_path`, `.generate_on_commit`) to `acp.configurables.yaml` so downstream installs have a stable, discoverable toggle even before the engine exists. This is a config-doc change, not M74–M77 build work — but confirm with the maintainer given ADR-19's caution against speculative interfaces.
3. **Model all detection on `acp.branch-protection-setup.sh:27`** — one shared `coderabbit_available()` helper in `acp.common.sh`, so absence handling is uniform and testable.
4. **Keep `/acp-review` standalone-complete** — codify "CodeRabbit augments, never gates, the ACP review loop" as a one-line design principle when M74's policy-map ADR is written.
5. **Do not install/wire anything requiring live findings** until ADR-19's gate clears — no `findings-import`, no recurring-task rewrite. Those design against observed output, not vendor docs.

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-17 | 24fbddf | decide(ADR-19): gate M74–M77 on operational CodeRabbit + Aikido |
| 2026-07-15 | 71ae75f | research: ACP vs CodeRabbit/Aikido gap analysis |
| 2026-07-15 | f6e2695 | research: ACP direction — MCP fit, product layering |

## Open Carryovers Noted (not addressed here)

- 2 pending items in `audit-carryovers.md` (e.g. FIFOZ downstream `/acp-version-update` verification). Unrelated to this subject — surfaced for visibility only.
