# dupehound Integration

## Purpose

`dupehound` is ACP's optional local analyzer for `CH-05` duplicate-code
detection. ACP does not reimplement duplicate detection; it only wraps the
local binary behind ADR-23's Variant B optional-tool contract.

## Preferences

- `integrations.dupehound.enabled`
  - `auto` (default): enable when `dupehound` is installed locally
  - `true`: expect the binary and emit one hint if missing
  - `false`: disable dupehound entirely, including install offers
- `integrations.dupehound.min_tokens`
  - reserved compatibility key for future filter tuning
- `integrations.dupehound.install_prompt_version`
  - last ACP version that prompted for dupehound installation

## Review Scan Behavior

- `acp.review-scan.sh` keeps working when `dupehound` is absent.
- When active, ACP runs `dupehound check` in JSON mode and maps findings to
  `CH-05 / MEDIUM`.
- `--ci` stays non-blocking for `CH-05` because only CRITICAL/HIGH findings
  fail the deterministic scanner.
- ACP prints one activation line per scan so users know how to disable it.

## Assisted Install

Use:

```bash
bash agent/scripts/acp.dupehound.sh install
```

Install order:

1. `brew install rafaelpta/dupehound/dupehound`
2. `cargo install dupehound` (only when `cargo` is already present)
3. If neither package manager is available, ACP prints the releases URL and
   stops. It never downloads binaries directly and never bootstraps Rust.

The installer shows the exact command, includes the maturity caveat, asks for
explicit consent, and stamps `integrations.dupehound.install_prompt_version`
after either acceptance or decline so version commands do not nag repeatedly.
