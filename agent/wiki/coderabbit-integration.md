# ACP Enhanced — Working with CodeRabbit

How to use ACP's **optional** CodeRabbit integration — and what it does (and doesn't) do today.

> **TL;DR** — CodeRabbit is entirely optional. ACP's `/acp-review` and carryover
> loop work fully without it. The integration is **off by default**; turn it on
> only if your repo uses CodeRabbit. Findings-import + review annotations are
> **M81 / ADR-22** (CodeRabbit-only) — see [Roadmap](#roadmap).

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

Quick detection:

```bash
bash agent/scripts/acp.coderabbit.sh available
bash agent/scripts/acp.coderabbit.sh active
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

## What is live (M78 optionality + M81 planning)

- ✅ Preference toggle (`integrations.coderabbit.*`)
- ✅ Feature detection helpers (`acp.coderabbit.sh`)
- ✅ Graceful-degradation contract + pattern + E2E coverage
- ✅ This guide + [policy map lite](coderabbit-policy-map-lite.md) (ADR-22)
- ⏳ `acp.findings-import.sh` + review wiring — **M81 tasks 270–274** (blocked until findings fixture exists)

## Roadmap

### CodeRabbit-only path — [ADR-22](../memory/decisions.md) / M81

When CodeRabbit is on a consumer repo **and** a sanitized findings sample is at `tests/fixtures/coderabbit-findings-sample.json`:

- `acp.findings-import.sh` — `--input` file → `audit-carryovers.md`
- `/acp-review` Phase 2 annotations from the policy map (Phase 1 **never** deferred)
- Optional weekly wrapper / review-doc path

Start: `/acp-proceed task-270` after the fixture is committed. **Do not** run `/acp-plan M74` for CodeRabbit-only needs.

### Still gated under [ADR-19](../memory/decisions.md) (Aikido + broader track)

- Aikido SCA/CVE ingest
- Full patterns/lessons → `.coderabbit.yaml` generator (`generate_on_commit`)
- M76 golden-path scaffold (ACP + CodeRabbit + Aikido)
- M77 AI supply-chain moat

Aikido is **deferred for current user-base cost**, not abandoned.

---

## References

- [ADR-22](../memory/decisions.md) — CodeRabbit-only M81 carve-out from ADR-19
- [ADR-21](../memory/decisions.md) — optionality foundation
- [ADR-19](../memory/decisions.md) — Aikido / M76 / M77 remain gated
- [Policy map lite](coderabbit-policy-map-lite.md)
- [Local thorough review playbook](coderabbit-local-thorough-review.md) (M82 — CLI chunked + ACP weeklies)
- `agent/patterns/local.optional-external-tool.md`
- `agent/reports/audit-097-optional-coderabbit-integration.md`, `audit-101-m81-pre-impl-readiness.md`
