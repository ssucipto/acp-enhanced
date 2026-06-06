# Audit Report: ACP Bootstrap Step 7 — Empty Directory False Positive

**Audit**: #045  
**Date**: 2026-06-06  
**Subject**: `acp-bootstrap.sh` — step 7 skips download on fresh installs because empty directories created in step 1 trigger a false-positive "already present" check  

---

## Summary

A user ran `curl -fsSL .../acp-bootstrap.sh | bash` on a new project. The bootstrap reported "✓ agent/commands + agent/scripts already present — skipping download" but the post-install verification showed **0 command files and 0 script files**.

Root cause: Step 1 creates empty `agent/commands/` and `agent/scripts/` directories. Step 7 checks only `[ -d "agent/commands" ]` (directory exists) instead of checking file counts. The empty directories pass the check, the download is skipped, and the install is silently broken.

Two additional issues: OpenCode command generation is incorrectly gated behind `GENERATE_PROMPTS`, and the post-install verification reports failure but doesn't auto-repair or provide a fix command.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `scripts/acp-bootstrap.sh` | script | Primary subject — contains all 3 bugs |
| `scripts/acp-bootstrap.sh:1337` | bug location | Step 7 directory check (root cause) |
| `scripts/acp-bootstrap.sh:701` | bug location | Step 6 opencode gating |
| `scripts/acp-bootstrap.sh:1420-1445` | verification | Post-install verify (detects but doesn't fix) |
| `scripts/acp-bootstrap.sh:85-100` | reference | Pre-flight check (correctly uses file counts) |

---

## Key Findings

| ID | Severity | Finding | Location | Fix |
|----|----------|---------|----------|-----|
| BUG-045-01 | **CRITICAL** | Step 7 checks `-d agent/commands && -d agent/scripts` (directory existence) instead of file count. Step 1 creates these as empty dirs, causing step 7 to always skip the download on fresh installs. | `acp-bootstrap.sh:1337` | Replace `[ -d "agent/commands" ] && [ -d "agent/scripts" ]` with file count check: `CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" \| wc -l); if [ "$CMD_COUNT" -ge 40 ]...` — same pattern already used correctly in the pre-flight check at line 89. |
| BUG-045-02 | **HIGH** | OpenCode command generation (step 6b) is nested inside `if [ "$GENERATE_PROMPTS" = "true" ]` block. When prompts are skipped (`--generate-prompts` not passed), opencode commands are also skipped even though `GENERATE_OPENCODE="true"` by default. This causes `.opencode/commands/` and `.cursor/commands/` to be missing. | `acp-bootstrap.sh:701` | Extract opencode generation (lines 1301-1330) from inside the `GENERATE_PROMPTS` block into a separate `if [ "$GENERATE_OPENCODE" = "true" ]` block that runs independently. |
| BUG-045-03 | **MEDIUM** | Post-install verification correctly detects 0 files (❌) but bootstrap exits 0 (success). No auto-repair, no fix command suggested, no non-zero exit code. User sees the failure in output but bootstrap declares "Done. ACP Enhanced is ready." | `acp-bootstrap.sh:1425-1445` | After verification failures, output a clear message: "Install incomplete — run: curl .../acp-bootstrap.sh | bash" or trigger auto-repair. Set non-zero exit code if verification fails. |
| OBS-045-04 | **LOW** | `.cursor/commands/` directory is created during step 6b (inside the opencode generation block at line 1320). When prompts are skipped, no `.cursor/commands/` is created. The post-install verification correctly warns about this, but the root cause is the same as BUG-045-02. | `acp-bootstrap.sh:1320` | Resolved by BUG-045-02 fix (extract opencode/cursor generation). |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `acp-bootstrap.sh:1337` | **BUG**: `if [ -d "agent/commands" ] && [ -d "agent/scripts" ]` — directory check instead of file count |
| `acp-bootstrap.sh:85-100` | **REFERENCE (correct)**: Pre-flight check uses `find ... -name "acp.*.md" \| wc -l` — same pattern should be used in step 7 |
| `acp-bootstrap.sh:701` | **BUG**: `if [ "$GENERATE_PROMPTS" = "true" ]` — opencode generation (lines 1301-1330) incorrectly nested inside |
| `acp-bootstrap.sh:160` | **CONFIG**: `Scaffold: opencode=${GENERATE_OPENCODE}` — variable is true but never independently checked |
| `acp-bootstrap.sh:1425-1445` | **VERIFICATION**: Post-install check — detects 0 files but doesn't exit non-zero or offer fix |

---

## Execution Trace (User's Session)

```
[1/8] Creating directory structure (small)...    ← Creates empty agent/commands/, agent/scripts/
[2/8] Creating AGENTS.md...                       ← OK
[3/8] Creating core layer files...                ← OK
[4/8] Creating memory and wiki stubs...           ← OK
[5/8] Creating routing layer...                   ← OK
[6/8] Skipping prompt files...                    ← Also skips opencode! (BUG-045-02)
[7/8] Installing ACP commands...                  ← Sees empty dirs → SKIPS (BUG-045-01)
✓ agent/commands + agent/scripts already present — skipping download
[8/8] Installing pre-commit hook...               ← OK

Post-Install Verification:
  ❌ agent/commands/: 0 files (expected 40+)
  ❌ agent/scripts/: 0 files (expected 20+)
  ⚠️ .opencode/commands/: missing                 ← Caused by BUG-045-02
  ⚠️ .cursor/commands/: missing                   ← Caused by BUG-045-02
```

---

## Recommendations

### Immediate (fix before next release)

1. **Fix BUG-045-01 (CRITICAL)**: Change step 7's check from directory existence to file count. Use the same `find ... | wc -l` pattern already proven in the pre-flight check (lines 89-92). This is a 2-line change.

2. **Fix BUG-045-02 (HIGH)**: Extract opencode/cursor generation from the `GENERATE_PROMPTS` block. Add a separate `if [ "$GENERATE_OPENCODE" = "true" ]` check. This decouples prompt generation from opencode command generation.

3. **Fix BUG-045-03 (MEDIUM)**: After verification failures, exit with code 1 and print a clear remediation message. Optionally trigger auto-repair by re-running the download step.

### Testing

4. **Add E2E test**: Create a test that runs bootstrap in a temp directory and verifies `agent/commands/` has 40+ files and `agent/scripts/` has 20+ files after bootstrap completes. This would have caught BUG-045-01.

### Workaround (for affected users)

```
# Manual fix for broken installs:
cd /path/to/project
curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh | bash
```

---

## Verdict

**CRITICAL — blocks all fresh installs via curl-pipe-bash.** The bootstrap is the primary install path for new ACP Enhanced users. Every fresh install since the step-1 directory creation was introduced will silently produce a broken install with 0 command files and 0 script files. The post-install verification correctly detects the problem but doesn't prevent it.

**Fix priority**: P0 — should be patched before any new users attempt installation.

---

**Audit type**: Bug investigation — install failure  
**Generated by**: ACP `/acp-audit` #045
