<skill name="scripts" mention="@{scripts}">
<rules>
- Always use `set -euo pipefail` at the top of every script
- Always trap errors: `trap 'echo "Error on line $LINENO"; exit 1' ERR`
- Source acp.common.sh and acp.yaml-parser.sh from SCRIPT_DIR, not from cwd
- Use `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` pattern
- All variables must be quoted: `"${VAR}"` not `$VAR`
- Use `local` for all function-scoped variables
- Never use `grep` exit code directly with `set -e` — use `grep ... || true`
- Never use `set -e` exit from array operations — wrap with `|| true`
- False-green contracts (M86): `set +e` does **not** suppress `trap ERR` — capture status with `if cmd; then rc=0; else rc=$?; fi`. Never PASS with zero units executed; assert output contracts not exit codes alone; probe deps in the script’s execution context. Full FG-1…FG-7: `agent/core/constraints.yml` (`set_plus_e_does_not_suppress_err_trap` and following)
- macOS BSD sed: use `sed -i ''` (not `sed -i`) — detect with `uname -s`
- macOS date: `date +%N` is unavailable — use `$RANDOM$RANDOM` or python fallback
- Use `yaml_get`, `yaml_set`, `yaml_get_array` from acp.yaml-parser.sh for YAML ops
- Never parse YAML with grep/sed/awk — always use the YAML parser
- Argument parsing: use a `while [[ $# -gt 0 ]]; do case "$1" in ...` loop
- Help text: every script must have a `usage()` function and handle `--help`
</rules>

<sourced_library_exemptions>
Four libraries are **sourced** (not executed) and intentionally omit `set -euo pipefail`
because `-e` propagates into the parent shell and breaks caller control flow:
`acp.common.sh`, `acp.yaml-parser.sh`, `acp.driver-yaml.sh`, `acp.integrity-output.sh`.
Use `# shellcheck disable=SC2034` etc. where needed; document rationale inline.
</sourced_library_exemptions>

<patterns>
Script header (copy verbatim):
```bash
#!/usr/bin/env bash
# acp.foo.sh — Brief description
# Usage: ./agent/scripts/acp.foo.sh [--option] <arg>

set -euo pipefail
trap 'echo "[acp.foo] Error on line $LINENO" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/acp.common.sh"
source "${SCRIPT_DIR}/acp.yaml-parser.sh"
```

Cross-platform sed:
```bash
if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/old/new/" "$file"
else
  sed -i "s/old/new/" "$file"
fi
```

Cross-platform date (nanoseconds fallback):
```bash
if [[ "$(uname -s)" == "Darwin" ]]; then
  TIMESTAMP="${RANDOM}${RANDOM}"
else
  TIMESTAMP="$(date +%N)"
fi
```

Argument parsing loop:
```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y) YES=true; shift ;;
    --verbose|-v) VERBOSE=true; shift ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
```
</patterns>

<anti_patterns>
- NEVER use `set -e` without also setting the ERR trap
- NEVER use bare `grep pattern file` where the pattern might not match (exits 1)
- NEVER use `echo` for structured output — use `printf` for portability
- NEVER hardcode paths like `/home/user/` — use `$HOME` or `~`
- NEVER use `$(cat file)` — use `< file` redirect or `read` instead where possible
- NEVER use `[[ -z $var ]]` without quoting — use `[[ -z "${var}" ]]`
</anti_patterns>
</skill>
