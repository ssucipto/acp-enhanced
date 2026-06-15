---
id: route-179
title: Fix the two broken integrity scanners — entropy set -e crash + unicode single-pass performance
task_type: bash-script-refactor
milestone: M64
complexity: medium
executor: copilot
context_required:
  - skills/scripts.md
  - reports/audit-070-m55-m58-gateway-deep-dive.md
files_affected:
  - agent/scripts/acp.entropy-scan.sh
  - agent/scripts/acp.unicode-scan.sh
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Make the two core scanners actually work: (a) stop `acp.entropy-scan.sh` from crashing with `exit 3` on every positive finding, and (b) make `acp.unicode-scan.sh` fast enough to use as a pre-commit/CI gate by replacing its per-line, per-codepoint double `python3` spawn with a single pass per file.

## Context

audit-070 F-070-01 (HIGH): `acp.entropy-scan.sh:56–106` runs under `set -euo pipefail` + `ERR` trap, then does `output=$(python3 -c "... sys.exit(findings)")`. When `findings > 0`, the command-substitution returns non-zero, `set -e` fires the trap, and the script exits 3 ("Error: entropy-scan.sh failed at line 56") BEFORE printing findings. Net: the scanner only works when it finds nothing — IG-17/IG-18 detection is dead.

audit-070 F-070-04 (HIGH): `acp.unicode-scan.sh:87–123` loops 16 codepoints per line and spawns `python3` twice per codepoint = up to 32 interpreter starts per line — minutes-to-hours on a real repo, defeating its `Pre-commit (--fast)` purpose.

## Steps

### Part A — entropy-scan.sh (F-070-01)
1. Stop using the process exit code as a data channel. In the Python helper, **print the finding count to stdout on a sentinel line** (e.g. `print(f"__COUNT__:{findings}")`) and always `sys.exit(0)`.
2. In bash, capture without aborting under `set -e`:
   ```bash
   output=$(ACP_THRESHOLD="$THRESHOLD" ACP_FILEPATH="$file" python3 -c "...") || true
   count=$(printf '%s\n' "$output" | sed -n 's/^__COUNT__://p')
   output=$(printf '%s\n' "$output" | grep -v '^__COUNT__:' || true)
   FINDINGS=$((FINDINGS + ${count:-0}))
   ```
3. Keep findings text routed to stdout, summary to stderr (preserve current UX). Preserve `--ci` exit-1 behaviour (but see route-182 for severity-aware `--ci`).
4. Add an explicit regression: running the script on a high-entropy fixture must print the finding AND exit 0 (non-`--ci`), not exit 3.

### Part B — unicode-scan.sh (F-070-04)
1. Replace the per-line/per-codepoint loop with **one `python3` invocation per file** that:
   - receives the full hidden-codepoint set via env (JSON list or comma-separated hex),
   - reads the file once, iterates lines, and for each hidden char found prints `line:col:U+XXXX:NAME` (and a separate stream for IG-20 AI-directive comment matches),
   - exits 0 always (count handled in bash, like Part A).
2. Bash reads that structured output and formats findings + increments `FINDINGS`.
3. Keep the bash-only directory walk + skip rules (node_modules/.git/binaries); only the inner per-file scan moves to the single Python pass.
4. Preserve `--json` output (and fix rule attribution per route-184/F-070-13 separately — here just keep parity).

## Expected Output

### Files Modified
- `agent/scripts/acp.entropy-scan.sh` — count via stdout sentinel, no crash on findings
- `agent/scripts/acp.unicode-scan.sh` — single `python3` pass per file

## Verification (double-verify)

- [ ] **Automated**: new E2E (route-184 will host it; add a temporary inline assert here) — entropy scan on a base64 blob fixture prints `entropy=` line and exits 0; unicode scan on a U+200D fixture prints the finding and exits 0
- [ ] **Manual**: `bash agent/scripts/acp.entropy-scan.sh <high-entropy-file>; echo "exit=$?"` → shows finding, `exit=0` (was `exit=3`)
- [ ] **Manual**: `time bash agent/scripts/acp.unicode-scan.sh .` completes in < 5s on this repo (was minutes)
- [ ] `bash -n` clean; `shellcheck --severity=error` clean on both scripts

## User-Observable Acceptance

- The entropy scanner reports encoded-payload findings instead of erroring out.
- A full-repo unicode scan is fast enough to run in a pre-commit hook.

## Addresses

audit-070 F-070-01 (HIGH), F-070-04 (HIGH)
