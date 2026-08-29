#!/usr/bin/env bash
# acp.m94-purge-paths.sh — fail-closed KEEP/PURGE list for git filter-repo (M94 / ADR-29)
#
# Usage:
#   bash agent/scripts/acp.m94-purge-paths.sh [--output PATH]
#
# Writes paths for: git filter-repo --invert-paths --paths-from-file FILE
# KEEP paths must never appear. Required PURGE paths from index/history must appear.
#
# Crosswalk (audit-135 → tasks):
#   F-135-01 IP_REGISTER.md            → 376, 378, 380
#   F-135-02 design/local.*            → 375, 378, 380
#   F-135-03 design/m[0-9]*.md         → 375, 378, 380
#   F-135-04 patterns/**/local.*       → 375, 378, 380
#   F-135-05 routing/tasks/route-[0-9] → 375, 378, 380
#   F-137-02 nested typescript/local.* → this list
#   F-137-05 visualizer.requirements.md → this list
#   F-136-01 route-template.md KEEP    → fail-closed gate
#
# agent/benchmarks/** is never in this list (D16).

set -euo pipefail
trap 'echo "[acp.m94-purge-paths] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUTPUT="${ACP_M94_PURGE_PATHS:-/tmp/m94-purge-paths.txt}"

usage() {
  cat <<'EOF'
Usage: acp.m94-purge-paths.sh [--output PATH]

Build a fail-closed PURGE path list for git filter-repo --invert-paths.
Default output: /tmp/m94-purge-paths.txt (override with --output or ACP_M94_PURGE_PATHS).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      [[ $# -ge 2 ]] || { echo "[acp.m94-purge-paths] ERROR: --output needs PATH" >&2; exit 2; }
      OUTPUT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[acp.m94-purge-paths] ERROR: unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

cd "${REPO_ROOT}"

# D1 KEEP: protocol acp-*.md (not only acp-*-design.md), global-*, named protocol files, templates.
is_keep() {
  local p="$1"
  case "$p" in
    agent/benchmarks/*) return 0 ;;
    docs/USAGE.md) return 0 ;;
    agent/routing/taxonomy.yml|agent/routing/rules.md|agent/core/routing.yml) return 0 ;;
    agent/design/.gitkeep|agent/design/design.template.md|agent/design/requirements.template.md) return 0 ;;
    agent/design/acp-*.md) return 0 ;;
    agent/design/global-*.md) return 0 ;;
    agent/design/cross-agent-handoff-protocol.md) return 0 ;;
    agent/design/safe-install-update-policy.md) return 0 ;;
    agent/design/yaml-parser-design.md) return 0 ;;
    agent/design/preferences-best-practices.md) return 0 ;;
    agent/design/install-local-patterns-feature.md) return 0 ;;
    agent/patterns/.gitkeep|agent/patterns/pattern.template.md|agent/patterns/bootstrap.template.md) return 0 ;;
    agent/patterns/*/pattern.template.md|agent/patterns/*/bootstrap.template.md) return 0 ;;
    agent/routing/tasks/route-template.md) return 0 ;;
    *) return 1 ;;
  esac
}

is_purge() {
  local p="$1"
  if is_keep "$p"; then
    return 1
  fi
  case "$p" in
    IP_REGISTER.md) return 0 ;;
    agent/design/local.*) return 0 ;;
    agent/design/m[0-9]*.md) return 0 ;;
    agent/design/visualizer.requirements.md) return 0 ;;
    agent/routing/tasks/route-[0-9]*.md) return 0 ;;
  esac
  # Nested or top-level patterns/**/local.* (F-137-02). * in [[ == ]] is glob (bash 3.2).
  if [[ "$p" == agent/patterns/local.* ]] || [[ "$p" == agent/patterns/*/local.* ]] || [[ "$p" == agent/patterns/*/*/local.* ]]; then
    return 0
  fi
  return 1
}

TMP_ALL="$(mktemp /tmp/m94-all-paths.XXXXXX)"
TMP_OUT="$(mktemp /tmp/m94-purge-out.XXXXXX)"
TMP_SORTED="$(mktemp /tmp/m94-purge-sorted.XXXXXX)"
cleanup_tmp() { rm -f "${TMP_ALL}" "${TMP_OUT}" "${TMP_SORTED}"; }
trap cleanup_tmp EXIT

{
  git ls-files
  git log --all --name-only --pretty=format:
} | sed '/^$/d' | sort -u > "${TMP_ALL}"

: > "${TMP_OUT}"
while IFS= read -r p || [[ -n "${p}" ]]; do
  [[ -n "$p" ]] || continue
  if is_purge "$p"; then
    printf '%s\n' "$p" >> "${TMP_OUT}"
  fi
done < "${TMP_ALL}"

sort -u "${TMP_OUT}" -o "${TMP_SORTED}"
mv "${TMP_SORTED}" "${TMP_OUT}"

KEEP_FORBIDDEN=(
  agent/routing/tasks/route-template.md
  docs/USAGE.md
  agent/routing/taxonomy.yml
  agent/routing/rules.md
  agent/core/routing.yml
  agent/design/design.template.md
  agent/design/requirements.template.md
  agent/design/acp-commands-design.md
  agent/design/.gitkeep
  agent/patterns/pattern.template.md
  agent/patterns/bootstrap.template.md
)

fail=0
for k in "${KEEP_FORBIDDEN[@]}"; do
  if grep -Fxq "$k" "${TMP_OUT}"; then
    echo "[acp.m94-purge-paths] ERROR: KEEP path in purge list: $k" >&2
    fail=1
  fi
done

if grep -E '^agent/benchmarks/' "${TMP_OUT}" >/dev/null 2>&1; then
  echo "[acp.m94-purge-paths] ERROR: agent/benchmarks/ path in purge list (D16)" >&2
  fail=1
fi

REQUIRED=(
  IP_REGISTER.md
  agent/patterns/typescript/local.library-services.md
  agent/design/visualizer.requirements.md
)
for r in "${REQUIRED[@]}"; do
  if grep -Fxq "$r" "${TMP_ALL}"; then
    if ! grep -Fxq "$r" "${TMP_OUT}"; then
      echo "[acp.m94-purge-paths] ERROR: required PURGE path missing: $r" >&2
      fail=1
    fi
  fi
done

if [[ "${fail}" -ne 0 ]]; then
  exit 1
fi

if [[ ! -s "${TMP_OUT}" ]]; then
  echo "[acp.m94-purge-paths] ERROR: empty purge list (fail-closed)" >&2
  exit 1
fi

mkdir -p "$(dirname "${OUTPUT}")"
cp "${TMP_OUT}" "${OUTPUT}"
count="$(wc -l < "${OUTPUT}" | tr -d ' ')"
echo "wrote: ${OUTPUT}"
echo "paths: ${count}"
