# ACP Enhanced Install Issue Report

**Project:** SubsNStuff (`c:\Project\SubsNStuff\SubsNStuff`)  
**Environment:** Windows 10 (build 26200), PowerShell, Git Bash (`C:\Program Files\Git\bin\bash.exe`), Git 2.50.0  
**Target repo:** [ssucipto/acp-enhanced](https://github.com/ssucipto/acp-enhanced) (`mainline` branch)  
**Date:** 2026-06-06  
**Status:** Remediated locally; upstream fixes recommended  

---

## 1. User-reported symptom

After installing ACP Enhanced into the `agent/` folder, **no `/acp-*` slash commands appeared** in Cursor autocomplete.

---

## 2. Initial state (before remediation)

The project had a **partial install** — framework layer only:

| Present | Missing |
|---|---|
| `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` | `agent/commands/` (0 files) |
| `agent/core/` (identity, constraints, routing) | `agent/scripts/` (0 files) |
| `agent/memory/`, `agent/routing/`, `agent/skills/`, `agent/wiki/` | `.github/prompts/` |
| | `.opencode/commands/` |
| | `.cursor/commands/` |
| | `AGENT.md` |

Only **15 files** under `agent/`. No command or script layer.

---

## 3. Root cause analysis

Three separate issues combined:

### Issue A — Partial bootstrap (design / UX)

`acp-bootstrap.sh` has an early-exit guard:

```bash
if [ -f "agent/core/identity.yml" ] && [ -f "AGENTS.md" ]; then
  echo "ACP Enhanced is already installed..."
  exit 0
fi
```

If bootstrap creates the framework layer but **fails or is interrupted before step 7** (commands + scripts), a re-run reports "already installed" and **exits without completing**. The partial-install warning only triggers when *one* of the two files exists, not when commands/scripts are missing.

### Issue B — `acp.install.sh` hangs on Windows Git Bash (bug)

Recommended recovery path from README:

```bash
curl -fsSL .../agent/scripts/acp.install.sh | bash
```

**Observed behavior:**

| Step | Result | Duration |
|---|---|---|
| Clone repo | ✓ Success | ~3s |
| Create directory structure | ✓ Success | immediate |
| Install context layer | ✓ Success | immediate |
| Copy command files (`agent/commands/`) | ✓ Success (67 files) | before hang |
| `Resolving script dependencies from package.yaml...` | **HANG — no further output** | **5+ minutes** |

Terminal log ended at line 26 with no `✓ Installed N required script(s)` or `Installation complete!`.

**Likely hang location** in `acp.install.sh` lines 328–375:

```bash
. "$TARGET_DIR/agent/scripts/acp.yaml-parser.sh"
yaml_parse "$TEMP_DIR/package.yaml"
cmd_index=0
while true; do
  cmd_name=$(yaml_query ".contents.commands[$cmd_index].name" ...)
  if [ -z "$cmd_name" ] || [ "$cmd_name" = "null" ]; then break; fi
  ...
  cmd_index=$((cmd_index + 1))
done
```

On Windows Git Bash, `yaml_query` may never return empty/`null` for out-of-range indices, causing an **infinite loop**. The script has a fallback path (lines 406–409) that copies all scripts when `package.yaml` is absent — but that path is never reached when `package.yaml` exists and parsing hangs.

**Evidence install did not complete:**

- `agent/manifest.yaml` still has stub content (`packages: {}`) — final step that writes `acp-core` package metadata never ran
- No `Installation complete!` message
- Process killed after ~328s (exit code `4294967295` = force-killed on Windows)

### Issue C — Cursor not covered by install (documentation / feature gap)

README slash-command table:

| Tool | Autocomplete source |
|---|---|
| VS Code Copilot | `.github/prompts/*.prompt.md` (opt-in: `--generate-prompts`) |
| opencode | `.opencode/commands/*.md` (default on) |
| Other agents | Manual: *"Read and execute `agent/commands/acp.init.md`"* |

**Cursor is not listed.** Cursor uses `.cursor/commands/*.md` for `/` autocomplete — a different mechanism from Copilot prompts and opencode commands. Bootstrap creates opencode wrappers but **never creates `.cursor/commands/`**.

`AGENT.md` line 982 confirms Cursor is "manual delegation" only — no install path for slash autocomplete.

---

## 4. Steps performed to remediate

### Step 1 — Diagnosis

- Scanned `agent/` tree; confirmed partial install
- Read [ssucipto/acp-enhanced](https://github.com/ssucipto/acp-enhanced) README and bootstrap/install scripts
- Identified three gaps: partial bootstrap, install hang, no Cursor commands

### Step 2 — Run official install script (failed)

```powershell
& "C:\Program Files\Git\bin\bash.exe" -c "
  cd '/c/Project/SubsNStuff/SubsNStuff' &&
  curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh | bash
"
```

- Hung at script dependency resolution (~5.5 min)
- Process force-killed

### Step 3 — Verify partial output from hung install

After kill, confirmed install had progressed through command copy:

- `agent/commands/` — **67 files** (including `acp.init.md`, `acp.proceed.md`, etc.)
- `.opencode/commands/` — **66 files**
- `AGENT.md` — present
- `agent/scripts/` — only **2 files** (`acp.common.sh`, `acp.yaml-parser.sh`)

### Step 4 — Manual script recovery (workaround)

```powershell
git clone --depth 1 --branch mainline https://github.com/ssucipto/acp-enhanced.git $env:TEMP\acp-enhanced-install
Copy-Item "$env:TEMP\acp-enhanced-install\agent\scripts\*.sh" "agent\scripts\" -Force
```

Result: **29 bash scripts** in `agent/scripts/`

### Step 5 — Cursor slash-command support (not in upstream)

```powershell
New-Item -ItemType Directory -Force -Path ".cursor\commands"
Copy-Item ".opencode\commands\*.md" ".cursor\commands\" -Force
```

Result: **66 Cursor command wrappers** in `.cursor/commands/`

### Step 6 — User instruction

Reload Cursor window, then type `/` in **Agent** chat to see `/acp-init`, `/acp-proceed`, etc.

---

## 5. Final state after remediation

| Component | Count | Status |
|---|---|---|
| `agent/commands/*.md` | 67 | ✓ |
| `agent/scripts/*.sh` | 29 | ✓ (manual copy) |
| `.opencode/commands/*.md` | 66 | ✓ (from install) |
| `.cursor/commands/*.md` | 66 | ✓ (manual, not upstream) |
| `.github/prompts/` | 0 | ✗ (requires `--generate-prompts`) |
| `agent/manifest.yaml` | stub | ✗ (install never finished manifest step) |

---

## 6. Is this an ACP Enhanced install script issue?

**Yes — at least two confirmed issues, one documentation gap:**

| # | Type | Severity | Description |
|---|---|---|---|
| 1 | **Bug** | High | `acp.install.sh` hangs indefinitely on Windows Git Bash during `package.yaml` script dependency resolution |
| 2 | **Design flaw** | High | `acp-bootstrap.sh` early-exit prevents completing partial installs |
| 3 | **Feature gap** | Medium | No `.cursor/commands/` generation for Cursor IDE users |
| 4 | **UX / docs** | Medium | `--generate-prompts` defaults to `false`; Copilot users won't get prompts unless they know the flag |
| 5 | **Docs gap** | Low | Windows install docs mention WSL for bootstrap but don't warn about `acp.install.sh` hang on Git Bash |

---

## 7. Recommended fixes for ACP Enhanced team

### Fix 1 — `acp.install.sh`: Windows-safe script install

```bash
# Option A: Add timeout + fallback
if ! timeout 30 bash -c 'resolve_scripts_from_package_yaml'; then
  echo "WARN: package.yaml resolution timed out — falling back to copy-all mode"
  find "$TEMP_DIR/agent/scripts" -maxdepth 1 -name "*.sh" -exec cp {} "$TARGET_DIR/agent/scripts/" \;
fi

# Option B: Detect Windows and skip selective resolution
if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
  echo "Windows detected — installing all scripts (skipping package.yaml resolution)"
  find ... # copy-all path
fi
```

Also add a **safety cap** on the `while true` loop:

```bash
if [ "$cmd_index" -gt 200 ]; then
  echo "ERROR: yaml_query loop exceeded 200 iterations — aborting" >&2
  break
fi
```

### Fix 2 — `acp-bootstrap.sh`: detect incomplete install

Replace simple early-exit with completeness check:

```bash
if [ -f "agent/core/identity.yml" ] && [ -f "AGENTS.md" ]; then
  CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l)
  if [ "$CMD_COUNT" -lt 10 ]; then
    echo "Partial install detected ($CMD_COUNT commands) — completing installation..."
    # run steps 7-8 only, or delegate to acp.install.sh
  else
    echo "Already installed. Use acp.version-update.sh to update."
    exit 0
  fi
fi
```

### Fix 3 — Add Cursor command generation

In bootstrap step 6, mirror opencode → cursor:

```bash
if [ -d ".opencode/commands" ]; then
  mkdir -p .cursor/commands
  cp .opencode/commands/*.md .cursor/commands/
fi
```

Or add `--generate-cursor` flag alongside `--generate-prompts`.

### Fix 4 — Post-install verification

Add to end of both bootstrap and install:

```bash
verify_install() {
  local errors=0
  [ "$(find agent/commands -name 'acp.*.md' | wc -l)" -lt 40 ] && echo "FAIL: agent/commands incomplete" && errors=1
  [ "$(find agent/scripts -name '*.sh' | wc -l)" -lt 20 ] && echo "FAIL: agent/scripts incomplete" && errors=1
  return $errors
}
```

Wire into `/acp-validate` as a `--install` check.

### Fix 5 — Windows install documentation

Add to `scripts/QUICKSTART.md` and README:

> **Windows (Git Bash):** If `acp.install.sh` hangs at "Resolving script dependencies", kill it and run:
>
> ```powershell
> git clone --depth 1 -b mainline https://github.com/ssucipto/acp-enhanced.git %TEMP%\acp-enhanced
> copy %TEMP%\acp-enhanced\agent\scripts\*.sh agent\scripts\
> ```
>
> **Cursor users:** After install, copy `.opencode/commands/` → `.cursor/commands/` and reload the IDE.

---

## 8. Repro steps for ACP Enhanced team

1. Fresh Windows 10/11 machine with Git for Windows (Git Bash)
2. `cd` to any git project root
3. Run partial bootstrap (or copy only `agent/core/` + `AGENTS.md` manually)
4. Run:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh | bash
   ```
5. **Expected (actual):** Hangs at `Resolving script dependencies from package.yaml...` for 5+ minutes
6. **Expected (desired):** Completes in <30s with `Installation complete!` and 25+ scripts

Secondary repro:

1. Complete bootstrap on any OS
2. Re-run bootstrap
3. **Expected (actual):** Exits immediately with "already installed"
4. **Expected (desired):** Detects missing `agent/commands/` and completes

---

## 9. Summary for issue tracker

**Title:** `acp.install.sh` hangs on Windows Git Bash during package.yaml script resolution; partial bootstrap cannot self-heal; Cursor slash commands not generated

**Labels:** `bug`, `windows`, `installer`, `cursor`, `documentation`

**Impact:** Windows + Cursor users get a broken install with no slash-command autocomplete and no clear recovery path without manual intervention.

**Upstream repo:** https://github.com/ssucipto/acp-enhanced
