# Adopting `/acp-review` on a Legacy Codebase

**Status**: active  
**Updated**: 2026-07-28  
**Related**: `agent/commands/acp.review.md`, `agent/scripts/acp.review-scan.sh`, F-105-01

---

## Goal

Land deterministic review on an existing repo **without** turning off the scanner after the first noisy run. The workflow is **baseline → tighten → gate on new findings only**.

---

## Phase 1 — Measure and baseline (day 0)

1. Run the scanner in report mode (no `--ci` yet):

```bash
bash agent/scripts/acp.review-scan.sh --json --self > /tmp/review-day0.json
```

2. Review findings. Separate **fix now** (real defects) from **accept for now** (legacy noise).

3. Write a baseline for accepted legacy findings:

```bash
bash agent/scripts/acp.review-scan.sh --self --write-baseline .acp/review-baseline.json
```

Commit `.acp/review-baseline.json` so the team shares one accepted-debt snapshot.

4. Verify baseline mode suppresses known debt but still reports new issues:

```bash
bash agent/scripts/acp.review-scan.sh --ci --baseline .acp/review-baseline.json --self
```

`--ci` should pass when only baselined findings remain.

---

## Phase 2 — Tighten (week 1–2)

Pick one lever per noisy rule — do not disable the scanner.

| Lever | When to use |
|-------|-------------|
| **Fix the code** | Real defect; remove from baseline on next `--write-baseline` refresh |
| **Inline `acp-review-ignore`** | Single known exception with a required reason |
| **`review.rule_overrides`** | Rule is useful but too noisy project-wide (disable or downgrade severity) |
| **Shrink baseline** | Re-run `--write-baseline` after fixing batches of debt |

### Per-rule overrides (preferences)

Edit `agent/preferences/acp.default.yaml` (or workspace/user preference files):

```yaml
acp:
  review:
    rule_overrides:
      NC-01:
        enabled: false        # silence snake_case rule on legacy code
      CH-03:
        severity: LOW         # keep function-length signal, non-blocking in --ci
```

Precedence: **project > workspace > user > configurables default**.

---

## Phase 3 — CI gate (steady state)

1. Add corpus/measure gate in CI (if not already):

```bash
bash agent/scripts/acp.review-measure.sh --ci
```

2. Add scanner with baseline for legacy repos:

```bash
bash agent/scripts/acp.review-scan.sh --ci --baseline .acp/review-baseline.json scripts/ src/
```

3. Policy: **new findings fail CI**; baselined findings stay suppressed. Refresh the baseline only in intentional debt-reduction PRs.

---

## Anti-patterns

- **Do not** claim 100% corpus recall equals production safety — fixture metrics are necessary but not sufficient.
- **Do not** disable whole rule families in code — use `review.rule_overrides` or baseline so the decision is visible and reversible.
- **Do not** baseline without team review — baselines are shared debt contracts.
- **Do not** skip inline reason requirements — `acp-review-ignore` without a reason is reported as `LOW`.

---

## Quick reference

| Control | Scope | CI blocking? |
|---------|-------|----------------|
| `--baseline` | Known accepted findings | Suppressed — not blocking |
| `acp-review-ignore` | Single line/file | Suppressed — not blocking |
| `review.rule_overrides.enabled: false` | Whole rule project-wide | Suppressed — not blocking |
| `review.rule_overrides.severity: LOW` | Whole rule, downgraded | Non-blocking in `--ci` |
| New HIGH/CRITICAL finding | Any | **Fails `--ci`** |

---

## References

- [acp.review.md](../commands/acp.review.md) — false-positive controls
- [audit-105-m83-post-impl.md](../reports/audit-105-m83-post-impl.md) — limitations and strengths
- [local.optional-external-tool.md](../patterns/local.optional-external-tool.md) — gitleaks / dupehound / shellcheck
