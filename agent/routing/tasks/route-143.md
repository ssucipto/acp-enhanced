---
id: route-143
title: "M56-002: unicode-scan.sh + entropy-scan.sh — byte-level detection scripts"
task_type: bash-script-create
milestone: M56
complexity: medium
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, audit-053, audit-054]
files_affected: [agent/scripts/acp.unicode-scan.sh, agent/scripts/acp.entropy-scan.sh]
tokens_est: 8000
created: 2026-06-07
completed: 2026-06-08
---

# Route 143: Unicode Scanner + Entropy Calculator

## Objective

Build two P0 bash scripts that perform deterministic byte-level analysis — the foundation of the LLM/Script Boundary Rule. Covers obfuscation detection rules IG-14–IG-17, IG-38–IG-39, IG-61.

## Expected Output

### Files Created
- `agent/scripts/acp.unicode-scan.sh` — hidden Unicode byte scanner
- `agent/scripts/acp.entropy-scan.sh` — Shannon entropy calculator

## Script Specifications

### acp.unicode-scan.sh
- **Purpose**: Scan files for hidden/invisible Unicode characters used in Rules File Backdoor attacks
- **Detects**: U+200B (ZWSP), U+200C (ZWNJ), U+200D (ZWJ), U+FEFF (BOM), U+202A–U+202E (bidi), U+2066–U+2069 (bidi isolation), U+061C (ALM)
- **Input**: File path or directory (recursive). Accepts `--ci` flag (exit 1 on findings)
- **Output**: `<file>:<line>:<col> <unicode-codepoint> <char-name>` per finding
- **Implementation**: `grep -Pn` primary, Python3 `unicodedata` fallback for macOS portability
- **ACID compliance**: `set -euo pipefail`, `trap ERR`, pure bash + Python3 fallback only
- **Rules covered**: IG-14, IG-15, IG-16, IG-38, IG-39, IG-61 (Unicode in memory files — Cat 10 context deferred to M58)
- **Also covers**: IG-20 (AI-directive language in comments — grep for known agent-instruction phrases)

### acp.entropy-scan.sh
- **Purpose**: Calculate Shannon entropy for string literals in source files
- **Threshold**: >4.5 bits/char flagged as potential encoded/encrypted payload
- **Input**: File path or directory
- **Output**: `<file>:<line> <entropy-value> "<snippet-truncated-80chars>"` per finding
- **Implementation**: Python3 `math.log2` for precision. Bash wrapper for file traversal.
- **Rules covered**: IG-17
- **Also covers**: IG-18 (hex/base64 runtime decoding detection via entropy pattern matching)

## Verification

- [ ] Both scripts have `set -euo pipefail` and `trap ERR`
- [ ] Both scripts pass `shellcheck --severity=error`
- [ ] `acp.unicode-scan.sh AGENTS.md` exits 0 on clean file
- [ ] `acp.unicode-scan.sh` detects U+200B in fixture file (create temp file with hidden char)
- [ ] `acp.entropy-scan.sh` outputs entropy >4.5 for known high-entropy string
- [ ] `acp.entropy-scan.sh` outputs entropy <4.5 for normal English text
- [ ] Both scripts tested on macOS (bash 3.2+)

## User-Observable Acceptance

- Running `acp.unicode-scan.sh src/` on a clean codebase exits 0
- Running `acp.unicode-scan.sh` on a file with U+200D outputs finding with line number
- Running `acp.entropy-scan.sh` on a file with base64 blob outputs entropy value >4.5
