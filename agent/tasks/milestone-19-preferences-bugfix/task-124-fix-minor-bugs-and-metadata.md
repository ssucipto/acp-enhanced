# Task 124: Fix Minor Bugs and Stale Metadata

<!-- @acp.meta.task
topic: fix, minor, bugs, and, stale, metadata
description: Task 124: Fix Minor Bugs and Stale Metadata
milestone: M19
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Task ID**: task-124  
**Milestone**: M19 — Preferences System Bug Fix Sprint  
**Priority**: Normal  
**Estimated Hours**: 1–2  
**Bugs Fixed**: BUG-9, BUG-10, BUG-11, BUG-13  
**Files**: `acp.package-install.sh`, `acp.preferences.sh`, `acp.yaml-parser.sh`, `AGENT.md`  

---

## Objective

Fix four minor bugs that cause misleading output or incorrect exit codes, and update
stale project metadata:

| Bug | File | Summary |
|-----|------|---------|
| BUG-9  | `acp.package-install.sh` | "Repository cloned" success message printed twice on success |
| BUG-10 | `acp.preferences.sh`    | `get_preference_source()` returns exit 1 for the `"none"` case — valid non-error state |
| BUG-11 | `acp.yaml-parser.sh`    | `yaml_query` returns `"key:"` (with colon) for map/array nodes — undocumented, surprising |
| BUG-13 | `AGENT.md`              | Version header says `5.41.0`, project is at `6.2.0` |

---

## Context

### BUG-9: Double "Repository cloned" in `acp.package-install.sh`

```bash
if [ -d "$REPO_URL" ]; then
    cp -r "$REPO_URL"/* "$TEMP_DIR/" ...
    echo "${GREEN}✓${NC} Local directory copied"
elif ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &>/dev/null; then
    echo "${RED}Error: Failed to clone repository${NC}"
    exit 1
else
    echo "${GREEN}✓${NC} Repository cloned"   # ← inside else branch (correct)
fi

echo "${GREEN}✓${NC} Repository cloned"       # ← always printed after the if/else block
```

On a successful `git clone`, the message appears twice. The second unconditional print
should be removed.

### BUG-10: `get_preference_source()` returns exit 1 for `"none"`

```bash
get_preference_source() {
  ...
  echo "none"
  return 1     # ← returns 1 for a valid "not found" result
}
```

"Preference not set anywhere" is not an error — it's a valid, expected state for new
preferences. Callers that do:
```bash
source_level="$(get_preference_source "acp" "plan.draft.create_mode")"
```
...under `set -e` will have the script **exit silently** when no preference is
configured anywhere. The correct exit code is `0` — the function succeeded at
reporting the source (which is "none").

### BUG-11: `yaml_query` appends `:` to map/array child key names

In `yaml_query`, when the resolved node is a map or array:
```bash
if [ "$node_type" = "map" ] || [ "$node_type" = "array" ]; then
    for child_id in $children; do
        local child_key
        child_key=$(get_node_field "$child_id" 3)
        echo "${child_key}:"    # ← colon appended to key name
    done
fi
```

A caller querying a map node expects to receive the key name, not `"plan:"` with a
trailing colon. This is inconsistent with scalar query return values (no colon).
No caller currently uses this return value for map-node queries, but it is a latent
bug in the API surface. Document the behaviour, or strip the colon.

**Recommended fix**: Document this behaviour explicitly in the function's header
comment, since callers may rely on the colon for YAML-formatted output. Do **not**
silently strip it — that could break callers that expected the colon. The fix is
documentation only unless a broken caller is identified.

### BUG-13: `AGENT.md` version is stale

```markdown
**Version**: 5.41.0
```

The project is at `v6.2.0` (per `agent/progress.yaml` and `package.yaml`).

---

## Steps

### Step 1 — Remove the duplicate print in `acp.package-install.sh` (BUG-9)

```bash
# Remove the unconditional line after the if/elif/else block:
echo "${GREEN}✓${NC} Repository cloned"
echo ""
```

Keep only the one inside the `else` branch. After the fix:

```bash
if [ -d "$REPO_URL" ]; then
    cp -r "$REPO_URL"/* "$TEMP_DIR/" 2>/dev/null || cp -r "$REPO_URL"/.[!.]* "$TEMP_DIR/" 2>/dev/null || true
    echo "${GREEN}✓${NC} Local directory copied"
elif ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &>/dev/null; then
    echo "${RED}Error: Failed to clone repository${NC}"
    exit 1
else
    echo "${GREEN}✓${NC} Repository cloned"
fi

echo ""
```

### Step 2 — Fix `get_preference_source()` exit code for `"none"` (BUG-10)

In `acp.preferences.sh`, update the final branch of `get_preference_source`:

```bash
# Before:
  echo "none"
  return 1

# After:
  echo "none"
  return 0
```

If callers need to distinguish between "preference is set with value `none`" and
"preference was not found", they should compare the output string, not the exit code.
The exit code should convey whether the function itself succeeded.

### Step 3 — Document `yaml_query` map/array return format (BUG-11)

Add a clarifying comment to `yaml_query` in `acp.yaml-parser.sh`:

```bash
# yaml_query: query the loaded AST for a value at the given dot-path.
# For SCALAR nodes: returns the value (no trailing colon).
# For MAP or ARRAY nodes: returns each child key followed by ':' (YAML key format).
#   Callers querying maps get "key:" formatted output — this is intentional for
#   YAML-list-style output. If you need bare key names, strip the trailing colon.
# Returns: empty string and exit 1 if path not found.
yaml_query() {
```

### Step 4 — Update `AGENT.md` version (BUG-13)

Change the version line near the top of `AGENT.md`:

```markdown
# Before:
**Version**: 5.41.0

# After:
**Version**: 6.2.0
```

---

## Verification

- [ ] Installing a package via git URL prints "Repository cloned" exactly once
- [ ] `./acp.preferences.sh source acp plan.draft.create_mode` (with no files) prints `none` and exits 0
- [ ] `./acp.preferences.sh source acp plan.draft.create_mode` under `set -e` does NOT exit the script
- [ ] `head -5 AGENT.md | grep Version` shows `6.2.0`
- [ ] `yaml_query` function block has a comment describing the map/array colon behaviour

---

## Files Modified

- `agent/scripts/acp.package-install.sh` — remove duplicate echo
- `agent/scripts/acp.preferences.sh` — `return 0` in `get_preference_source` "none" case
- `agent/scripts/acp.yaml-parser.sh` — add documentation comment to `yaml_query`
- `AGENT.md` — update version number

---

## Dependencies

None — all fixes are independent and safe to apply in any order.
