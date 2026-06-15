---
id: route-144
title: "M56-003: manifest-hash.sh + network-whitelist-validate.sh"
task_type: bash-script-create
milestone: M56
complexity: medium
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, route-142]
files_affected: [agent/scripts/acp.manifest-hash.sh, agent/scripts/acp.network-whitelist-validate.sh]
tokens_est: 8000
created: 2026-06-07
completed: 2026-06-08
---

# Route 144: Manifest Hasher + Network Whitelist Validator

## Objective

Build two P0 scripts: SHA-256 manifest hash generator for `--diff` tamper detection, and network whitelist validator for outbound call analysis.

## Expected Output

### Files Created
- `agent/scripts/acp.manifest-hash.sh`
- `agent/scripts/acp.network-whitelist-validate.sh`

## Script Specifications

### acp.manifest-hash.sh
- **Purpose**: Generate/verify SHA-256 hashes of ACP framework files for tamper detection
- **Modes**:
  - `--generate`: Hash all tracked ACP files → output to `agent/manifest.yaml`
  - `--verify`: Compare current file hashes against stored manifest
  - `--diff`: Alias for `--verify` with diff output
- **Input**: Directory (default: project root)
- **Output**: `<file> OK` or `<file> CHANGED (expected: <sha>, actual: <sha>)`
- **Exit codes**: 0 = all match, 1 = changes detected
- **Rules covered**: `--diff` flag, IG-42

### acp.network-whitelist-validate.sh
- **Purpose**: Scan source for outbound network calls and validate against whitelist
- **Detects**: `fetch()`, `axios`, `http.request()`, `WebSocket`, `XMLHttpRequest` in .ts/.js/.tsx/.jsx
- **Input**: File/directory + `agent/core/network_whitelist.yml`
- **Output**: `<file>:<line> <call-type> → <domain> [WHITELISTED|UNLISTED]`
- **Implementation**: `grep -n` for call patterns, extract URL, cross-ref whitelist
- **Rules covered**: IG-01, IG-02, IG-03, IG-05, IG-06

## Verification

- [ ] Both scripts have `set -euo pipefail` and `trap ERR`
- [ ] Both scripts pass `shellcheck --severity=error`
- [ ] `acp.manifest-hash.sh --generate` creates `agent/manifest.yaml` with valid hashes
- [ ] `acp.manifest-hash.sh --verify` passes on unmodified files
- [ ] `acp.manifest-hash.sh --verify` fails on modified file with diff output
- [ ] `acp.network-whitelist-validate.sh` flags `fetch('https://evil.com')` as UNLISTED
- [ ] `acp.network-whitelist-validate.sh` passes `fetch('https://api.github.com')` as WHITELISTED
- [ ] Both tested on macOS

## User-Observable Acceptance

- `acp.manifest-hash.sh --verify` shows file integrity status
- `acp.network-whitelist-validate.sh src/` lists all outbound calls with whitelist status
