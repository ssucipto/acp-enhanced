#!/usr/bin/env bash
# acp.backfill-markers.sh — Batch backfill @acp.meta.* markers for design/task/pattern files.
#
# Usage:
#   ./agent/scripts/acp.backfill-markers.sh [--dry-run] [--area design|tasks|patterns|all]
#
# --dry-run: Show what would change without modifying files.
# --area:    Limit to specific area. Default: all.

set -euo pipefail
trap 'echo "[acp.backfill-markers] Error on line $LINENO" >&2; exit 1' ERR

DRY_RUN=false; AREA="all"
while [[ $# -gt 0 ]]; do
  case "$1" in --dry-run) DRY_RUN=true; shift ;; --area) AREA="$2"; shift 2 ;;
    *) echo "Usage: $0 [--dry-run] [--area design|tasks|patterns|all]"; exit 1 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; cd "$ROOT"

ADDED=0; SKIPPED=0; ERRS=0

has_marker() { head -20 "$1" | grep -q '@acp\.meta\.'; }
is_template() { echo "$1" | grep -qE '\.template\.'; }
heading() { grep -m1 '^# ' "$1" | sed 's/^# //'; }
keywords() { echo "$1" | sed 's/[^a-zA-Z0-9 -]//g' | sed 's/  */ /g' | tr '[:upper:]' '[:lower:]' | sed 's/ /, /g'; }

prose_field() { head -30 "$1" | grep -E "^\*\*${2}\*\*:" | head -1 | sed 's/^*'${2}'*: *//'; }

desc() {
  local f="$1" d
  d=$(prose_field "$f" "Concept") && [ -n "$d" ] && echo "$d" && return
  d=$(sed -n '/^## Overview/,/^$/p' "$f" | head -3 | grep -v '^##' | tr -d '\n' | head -c 150)
  [ -n "$d" ] && echo "$d" && return
  heading "$f" | head -c 150
}

pstatus() {
  local s=$(prose_field "$1" "Status") && case "$s" in
    *"Implement"*) echo "active" ;; *"Specification"*) echo "draft" ;;
    *"Proposal"*) echo "draft" ;; *"Not Start"*) echo "draft" ;;
    *"Draft"*) echo "draft" ;; *"Active"*) echo "active" ;;
    *"Complete"*) echo "completed" ;; *"In Progr"*) echo "in_progress" ;;
    *) echo "active" ;;
  esac
}

pupdated() {
  local f="$1" d
  d=$(prose_field "$f" "Last Updated") && [ -n "$d" ] && echo "$d" && return
  d=$(prose_field "$f" "Created") && [ -n "$d" ] && echo "$d" && return
  date +%Y-%m-%d
}

milestone_from_dir() {
  local b=$(basename "$(dirname "$1")")
  echo "$b" | grep -qE '^milestone-[0-9]+' && echo "$b" | sed 's/milestone-/M/' || echo ""
}

insert_after_heading() {
  local file="$1" marker="$2"
  awk -v m="$marker" 'NR==1 && /^# / { print; print m; next } { print }' "$file" > "${file}.bak" && mv "${file}.bak" "$file"
}

strip_superseded() {
  awk '/^---/{d=1} d||!/^\*\*(Status|Last Updated|Created)\*\*:/{print} ' "$1" > "$1.bak" && mv "$1.bak" "$1"
}

gen_marker() {
  local kind="$1" file="$2" h k d s u m
  h=$(heading "$file"); k=$(keywords "$h"); d=$(desc "$file"); s=$(pstatus "$file"); u=$(pupdated "$file")
  m=$(milestone_from_dir "$file")
  case "$kind" in
    design)
      cat <<BLOCK

<!-- @acp.meta.design
topic: $k
description: $d
status: $s
updated: $u
@acp.meta.end -->"
BLOCK
      ;;
    task)
      cat <<BLOCK

<!-- @acp.meta.task
topic: $k
description: $d
milestone: $m
status: $s
updated: $u
@cp.meta.end -->"
BLOCK
      ;;
    pattern)
      cat <<BLOCK

<!-- @acp.meta.pattern
topic: $k
description: $d
applies_to: testing, quality
status: active
updated: $(date +%Y-%m-%d)
@acp.meta.end -->"
BLOCK
      ;;
  esac
}

process() {
  local kind="$1" label="$2" glob="$3"
  echo "─── $label ───"
  count=0
  while IFS= read -r -d '' f; do
    # Exclude benchmarks and template files
    echo "$f" | grep -q '/benchmarks/' && continue
    is_template "$f" && echo "  ⏭  SKIP $(basename "$f") (template)" && SKIPPED=$((SKIPPED+1)) && continue
    has_marker "$f" && echo "  ⏭  SKIP $(basename "$f") (already has marker)" && SKIPPED=$((SKIPPED+1)) && continue
    
    rel="${f#$ROOT/}"
    echo "  ➡️  $rel"
    count=$((count + 1))

    if ! $DRY_RUN; then
      marker=$(gen_marker "$kind" "$f")
      echo "$marker" | head -3  # debugging
      # Remove the quote that appears at end of marker block - that was a bug in the heredoc
      marker="${marker%\"}"
      insert_after_heading "$f" "$marker" || { echo "  ❌ ERROR writing to $rel"; ERRS=$((ERRS+1)); continue; }
      strip_superseded "$f" || true
      ADDED=$((ADDED+1))
    else
      ADDED=$((ADDED+1))
    fi
  done < <(find "$glob" -name '*.md' -print0 2>/dev/null || true)
  echo "  Found $count files to process"
  echo ""
}

# ── main ─────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ACP Marker Backfill"
echo "  Mode: $($DRY_RUN && echo 'DRY RUN' || echo 'LIVE') | Area: $AREA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

[ "$AREA" = "all" ] || [ "$AREA" = "design" ] && process "design" "Design files"  "agent/design"
[ "$AREA" = "all" ] || [ "$AREA" = "tasks" ] && process "task"   "Task files"    "agent/tasks"
[ "$AREA" = "all" ] || [ "$AREA" = "patterns" ] && process "pattern" "Pattern files" "agent/patterns"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Summary: Added=$ADDED  Skipped=$SKIPPED  Errors=$ERRS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$DRY_RUN && echo "  Dry run complete. Run without --dry-run to apply."
exit $ERRS
