# Milestone 84: Review Rule Overrides (`review.rule_overrides` hotfix)

<!-- @acp.meta.milestone
topic: acp-review, rule-overrides, preferences, legacy-adoption, hotfix
description: Per-rule enable/disable and severity overrides for /acp-review, plus the legacy adoption guide, shipped as a hotfix on top of M83
status: completed
updated: 2026-07-28
@acp.meta.end -->

**Planned version**: v6.29.1 → v6.29.2
**Status**: completed
**Progress**: 2/2 tasks
**Estimated effort**: ~6h
**Source**: audit-105 (M83 post-impl, F-105-01), audit-106 (M84 post-impl)
**Closes**: F-105-01, F-105-02, F-106-01

> **Backfilled record (2026-07-28).** M84 shipped as v6.29.1/v6.29.2 and is referenced
> in `CHANGELOG.md`, `progress.yaml` prose, and two commits, but never had a milestone
> document or a `milestones:` entry. audit-111 surfaced the gap while planning M85;
> this document reconstructs the record from the shipping commits rather than inventing
> scope. Dates and deliverables are taken from `3b5f237` and `8f078e7`.

---

## Why this milestone existed

audit-105 (M83 post-implementation) raised **F-105-01**: `/acp-review` shipped 38 deterministic rules with no way for a project to disable one or lower its severity. On an existing codebase that makes the scanner all-or-nothing — a single noisy rule forces teams to abandon the whole gate rather than adopt it incrementally.

M83 had just moved the scanner from ~8% recall to a measured 100% on the corpus. Without an adoption path, that accuracy would have gone unused on exactly the legacy codebases that need it most.

## Goal

Let a project turn individual rules off or change their severity through the existing preference layers, and document the baseline → tighten adoption workflow.

## Deliverables

| Deliverable | File |
|---|---|
| Rule override resolver | `agent/scripts/acp.review-rule-overrides.py` |
| Override plumbing in the finding emitter | `agent/scripts/acp.integrity-output.sh` |
| `review.rule_overrides` preference keys | `agent/preferences/acp.default.yaml` |
| Legacy adoption guide | `agent/wiki/review-legacy-adoption.md` |
| E2E coverage (B30–B33) | `e2e/acp.review-scan.test.sh` |

## Post-implementation remediation (audit-106)

audit-106 found the overrides were loaded lazily, so emitters that ran before the first
load silently ignored them. Fixed by preloading in `ig_parse_common_args`, with B32/B33
added to cover the JSON-file and project-YAML override paths.

## Success criteria

- [x] A rule can be disabled project-wide via `review.rule_overrides.<RULE>.enabled: false`
- [x] A rule's severity can be overridden and the finding still reported at the new level
- [x] Overrides resolve from project YAML preferences and from `IG_RULE_OVERRIDES_JSON`/`_FILE`
- [x] Suppression counted separately as `suppressed_rule_override` in the JSON summary
- [x] Overrides preloaded before any emit loop (audit-106)
- [x] Legacy adoption workflow documented

## References

- `agent/reports/audit-105-m83-post-impl.md` — F-105-01 origin
- `agent/reports/audit-106-m84-post-impl.md` — remediation findings
- `agent/wiki/review-legacy-adoption.md` — adoption workflow
- Commits `3b5f237` (feature), `8f078e7` (remediation)
