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

## Land policy (do not treat CodeRabbit as a merge gate)

Do **not** add CodeRabbit as a required GitHub status check. Merge on **CI green** plus an ACP review pass (`/acp-review`, optionally `--pr-diff`). CodeRabbit comments are advisory.

| Situation | Operator action |
|-----------|-----------------|
| Check named `Review rate limited` | **Skip** — not a pass and not a fail. Do not wait. |
| Green CodeRabbit check on the PR | **Not** a review of `HEAD`. The check can lag the tip. |
| `commit_id` in a review payload | Identifies **which SHA was reviewed**. Matching HEAD is useful; it is **not** a merge requirement. |
| Finding in the review **body** but not on a diff hunk | Still counts. Bucket it. Do not dismiss because it is “outside the diff.” |
| Multiple LLM-review layers (CodeRabbit, Copilot, a second model) | **One** architecture-level change per layer. After one parser/compiler-level fix, residual helper-style comments are non-blocking. |

### Buckets (portable)

| Bucket | Meaning | Merge impact |
|--------|---------|--------------|
| **A — production** | Honesty of user-visible results, authorization/cache, parse-unknown, enqueue ≠ sync, dates/IDs, formatter, authz | Blocking until fixed or explicitly deferred with reason |
| **B — helper** | Test/helper/tooling nits, style onions, drive-by refactors | At most **one** architecture change this pass; remainder non-blocking after one parser-level fix |

Promote recurring **classes** of Bucket A misses into **project** convention tests. Do not grow Phase 1 regex for honesty/authz.

### Consumer overlay

Projects may add `agent/wiki/local.coderabbit-land-policy.md` (never shipped by Enhanced). Put org-specific merge rules there. Framework wiki stays stack-agnostic.

Consumers **may** add `!agent/**` to CodeRabbit `reviews.path_filters` so protocol files are out of product review. The AE template stays narrower (`!agent/memory/**`, `!agent/reports/**`) so **this** repo still reviews command docs. Optional extra globs may be listed in `agent/configurables/pr.yml` (`coderabbit_exclude_globs`) — documentation only; ACP does not rewrite `.coderabbit.yaml` from that file.

## Enabling it

The integration is governed by two preferences (both off/inert by default):

| Preference | Default | Meaning |
|------------|---------|---------|
| `integrations.coderabbit.enabled` | `false` | Master opt-in switch |
| `integrations.coderabbit.config_path` | `.coderabbit.yaml` | File whose presence signals a CodeRabbit-configured repo |

### Bootstrap CodeRabbit (M81)

1. Copy the starter template to the repo root (**manual** — auto-generate deferred; no `generate_on_commit`):
   ```bash
   cp agent/templates/coderabbit.yaml.template .coderabbit.yaml
   ```
2. Install the CodeRabbit GitHub App on the repository (vendor docs).
3. Opt in:
   ```bash
   /acp-preferences-set acp integrations.coderabbit.enabled true
   ```
4. Confirm:
   ```bash
   bash agent/scripts/acp.coderabbit.sh available
   bash agent/scripts/acp.coderabbit.sh active
   ```

If the config already exists, turn it on:

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

### Import findings (when active)

```bash
bash agent/scripts/acp.findings-import.sh --input tests/fixtures/coderabbit-findings-sample.json
bash agent/scripts/acp.findings-import.sh --dry-run --input path/to/export.json
```

v1 is **`--input` file only** (no `--pr` / network). Silent no-op when CodeRabbit is inactive.
## How ACP behaves — on vs off

Detection lives in `agent/scripts/acp.coderabbit.sh` (`coderabbit_available` / `coderabbit_active`). The three-gate contract is: **opt-in → detection → silent degradation** (see ADR-29: optional-tool pattern is local-only on maintainer clones).

| State | `enabled` | `.coderabbit.yaml` | ACP behavior |
|-------|-----------|--------------------|--------------|
| Default | false | — | Silent no-op. No CodeRabbit references anywhere. |
| Opted-in, tool absent | true | missing | One non-fatal hint: "enabled but no config detected". No failure. |
| Active | true | present | `coderabbit_active` is true — CodeRabbit-aware branches may run. |
| Opt-in wins | false | present | Still inactive. The switch is authoritative, not mere presence. |

**Absence is normal, not an error** — unlike a required dependency (e.g. `gh` in `acp.branch-protection-setup.sh`, where absence is a hard failure).

## What is live (M78 optionality + M81)

- ✅ Preference toggle (`integrations.coderabbit.*`)
- ✅ Feature detection helpers (`acp.coderabbit.sh`)
- ✅ Graceful-degradation contract + pattern + E2E coverage
- ✅ This guide + [policy map lite](coderabbit-policy-map-lite.md) (ADR-22)
- ✅ `agent/templates/coderabbit.yaml.template` starter + bootstrap steps
- ✅ `acp.findings-import.sh` (`--input` / `--dry-run`) + `tests/fixtures/coderabbit-findings-sample.json`
- ✅ `/acp-review` CodeRabbit augmentation (Phase 1 never deferred; Phase 2 annotate)

## Roadmap

### CodeRabbit-only path — [ADR-22](../memory/decisions.md) / M81

Shipped when fixture + import + review wiring land:

- `acp.findings-import.sh` — `--input` file → `audit-carryovers.md`
- `/acp-review` Phase 2 annotations from the policy map (Phase 1 **never** deferred)
- Weekly recurring stays `command: /acp-review --report --carryover` (CR behavior in review doc — F-101-02)

**Do not** run `/acp-plan M74` for CodeRabbit-only needs.

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
- Optional-tool pattern (local-only on maintainer clones — ADR-29)
- Finding IDs F-097 / F-101 (full audit bodies live in local gitignored `agent/reports/` after ADR-27)
