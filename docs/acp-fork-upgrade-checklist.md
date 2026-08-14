# ACP Fork Upgrade Checklist

Use this when running `/acp-version-update` on a fork of ACP Enhanced (or a consumer project that customized upstream-owned files).

## Before upgrading

1. Ensure `agent/upstream-delta.yml` lists every upstream-owned file you customized, with a greppable `sentinel`.
2. Run `bash agent/scripts/acp.upgrade-guard.sh` — must PASS on a clean tree.
3. Prefer `--diff` first to preview upstream changes.

## During / after upgrade

1. `/acp-version-update` runs **upgrade-guard HARD fail (P-UG-1)** when `upstream-delta.yml` exists (skipped in `--diff` mode).
2. If guard fails: do **not** blindly re-apply. Check whether upstream now ships an equivalent (`supersede_when`). Prefer upstream when equal/better, then **delete** the collision entry.
3. Re-run `bash agent/scripts/acp.upgrade-guard.sh` until PASS.

## New commands (M86)

- `/acp-ci` — local CI predictor (`--fast` default; `--full` ≈ multi-minute CI)
- `/acp-pr` — PR prep; **delegates gates only to** `/acp-ci`

## Template

Copy `agent/upstream-delta.template.yml` → `agent/upstream-delta.yml` for new forks.
