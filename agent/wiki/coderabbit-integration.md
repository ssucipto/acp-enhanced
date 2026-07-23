# ACP Enhanced — Working with CodeRabbit

How to use ACP's **optional** CodeRabbit integration — and what it does (and doesn't) do today.

> **TL;DR** — CodeRabbit is entirely optional. ACP's `/acp-review` and carryover
> loop work fully without it. The integration is **off by default**; turn it on
> only if your repo uses CodeRabbit. PR-review integration is **not yet wired** —
> see [Roadmap](#roadmap).

---

## What CodeRabbit is

[CodeRabbit](https://coderabbit.ai) is an AI code-review service: LLM PR review plus 40+ bundled analysis engines (linters, SAST, secret scanning), delivered as line-by-line PR comments. It has a genuine free tier. ACP treats it as a *detection/review* provider that **augments** ACP's governance — it never replaces it.

## Is it required?

**No.** ACP is a distributed framework and assumes nothing about your toolchain:

- `/acp-review` (64-rule quality/security review) runs standalone.
- The audit-carryover accountability loop runs standalone.
- A fresh ACP install with no CodeRabbit behaves exactly as it always has.

The binding design rule (ADR-21): **CodeRabbit augments, never gates, an ACP code path.**

## Enabling it

The integration is governed by two preferences (both off/inert by default):

| Preference | Default | Meaning |
|------------|---------|---------|
| `integrations.coderabbit.enabled` | `false` | Master opt-in switch |
| `integrations.coderabbit.config_path` | `.coderabbit.yaml` | File whose presence signals a CodeRabbit-configured repo |

Turn it on (project level):

```bash
/acp-preferences-set acp integrations.coderabbit.enabled true
# optional, if your config lives elsewhere:
/acp-preferences-set acp integrations.coderabbit.config_path .github/.coderabbit.yaml
```

Check the resolved value:

```bash
bash agent/scripts/acp.preferences.sh get acp integrations.coderabbit.enabled
```

## How ACP behaves — on vs off

Detection lives in `agent/scripts/acp.coderabbit.sh` (`coderabbit_available` / `coderabbit_active`). The three-gate contract is: **opt-in → detection → silent degradation** (see the pattern `agent/patterns/local.optional-external-tool.md`).

| State | `enabled` | `.coderabbit.yaml` | ACP behavior |
|-------|-----------|--------------------|--------------|
| Default | false | — | Silent no-op. No CodeRabbit references anywhere. |
| Opted-in, tool absent | true | missing | One non-fatal hint: "enabled but no config detected". No failure. |
| Active | true | present | `coderabbit_active` is true — CodeRabbit-aware branches may run. |
| Opt-in wins | false | present | Still inactive. The switch is authoritative, not mere presence. |

**Absence is normal, not an error** — unlike a required dependency (e.g. `gh` in `acp.branch-protection-setup.sh`, where absence is a hard failure).

## What is live in this release (v6.28.0, M78)

- ✅ Preference toggle (`integrations.coderabbit.*`)
- ✅ Feature detection helpers (`acp.coderabbit.sh`)
- ✅ Graceful-degradation contract + pattern + E2E coverage
- ✅ This guide

## Roadmap — what is NOT yet built (GATED)

The following stay **gated under [ADR-19](../memory/decisions.md)** until CodeRabbit is operational on a real repo with 2+ weeks of findings — they are designed against the tool's *live output*, not vendor docs:

- ❌ **PR-check integration** (ACP consuming CodeRabbit's PR review results)
- ❌ `acp.findings-import.sh` — CodeRabbit findings → audit-carryover ledger
- ❌ `.coderabbit.yaml` **generation** from ACP patterns/lessons (and the `generate_on_commit` preference)
- ❌ Recurring-task rewire (`weekly-code-review` → CodeRabbit analytics)

**Do we still need CodeRabbit PR review?** Yes — it is the core deliverable of the gated M74/M75 roadmap. When the adoption gate clears, run `/acp-plan M74`. Nothing here forecloses it; this foundation is what makes it safe to add for users who don't have CodeRabbit.

---

## References

- [ADR-21](../memory/decisions.md) — optionality foundation carved out of the ADR-19 gate
- [ADR-19](../memory/decisions.md) — M74–M77 tool-integration roadmap gated on operational adoption
- `agent/patterns/local.optional-external-tool.md` — the reusable 3-gate contract
- `agent/reports/audit-097-optional-coderabbit-integration.md`, `audit-098-m78-pre-impl-readiness.md`
