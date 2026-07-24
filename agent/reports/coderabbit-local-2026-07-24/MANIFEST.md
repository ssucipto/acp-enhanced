# Manifest

## Base Selection

- Historical window samples were collected for `scripts/`, `agent/scripts/`, `.github/workflows/`, and `e2e/`.
- The explicit extra workflows retry used `v6.28.0` with a planned fallback to `v6.28.2` if a review could start and then rate-limit.
- The workflows retry never emitted CLI output before the requested 12-minute total wait budget expired, so the chunk is recorded as blocked.

## Chunk Runs

### `scripts`
- Status: `completed`
- Finding count: `2`
- Note: Completed successfully.
- Commands:
  - `coderabbit review --dir scripts --base v6.27.0 --agent` | exit `0` | elapsed `149.55s` | raw `agent/reports/coderabbit-local-2026-07-24/chunk-scripts.raw.txt`

### `agent/scripts`
- Status: `completed`
- Finding count: `2`
- Note: Completed after earlier rate-limit retries.
- Commands:
  - `coderabbit review --dir agent/scripts --agent --base v6.27.0` | exit `1` | elapsed `5.61s` | raw `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.attempt1.raw.txt`
  - `coderabbit review --dir agent/scripts --agent --base v6.27.0` | exit `0` | elapsed `94.64s` | raw `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.attempt2.raw.txt`
  - `coderabbit review --dir agent/scripts --base v6.27.0 --agent` | exit `1` | elapsed `5.21s` | raw `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.raw.txt`

### `e2e`
- Status: `blocked`
- Finding count: `0`
- Note: Blocked by CodeRabbit rate limiting (27 minutes wait), which exceeded the requested 10-minute per-review cap.
- Commands:
  - `coderabbit review --dir e2e --agent --base v6.27.0` | exit `1` | elapsed `9.07s` | raw `agent/reports/coderabbit-local-2026-07-24/chunk-e2e.attempt1.raw.txt`

### `.github/workflows`
- Status: `blocked`
- Finding count: `0`
- Note: Blocked: the explicit workflows retry produced no output before the requested 12-minute total wait budget expired, so no fallback run was started.
- Commands:
  - `coderabbit review --dir .github/workflows --base v6.28.0 --light --agent` | exit `n/a` | elapsed `720.0s` | raw `[none]`

## Written Paths

- `agent/reports/coderabbit-local-2026-07-24/MANIFEST.md`
- `agent/reports/coderabbit-local-2026-07-24/SUMMARY.md`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.attempt1.meta.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.attempt1.raw.txt`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.attempt2.meta.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.attempt2.raw.txt`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.meta.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-agent-scripts.raw.txt`
- `agent/reports/coderabbit-local-2026-07-24/chunk-e2e.attempt1.meta.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-e2e.attempt1.raw.txt`
- `agent/reports/coderabbit-local-2026-07-24/chunk-e2e.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-scripts.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-scripts.meta.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-scripts.raw.txt`
- `agent/reports/coderabbit-local-2026-07-24/chunk-workflows.attempt1.meta.json`
- `agent/reports/coderabbit-local-2026-07-24/chunk-workflows.json`

## Remediation follow-up

- `e2e` chunk completed on retry with `3` findings; those were addressed in the e2e test hardening pass.
- `.github/workflows` remained rate-limited, so workflow retry remains an optional residual ops step.
