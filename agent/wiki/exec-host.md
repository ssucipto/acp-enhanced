# Exec-host (Windows OpenSSH inner loop)

Load this file one section at a time. Portable rules for moving heavy device work off the editor (`ACP_EXEC_HOST`, `acp.exec-host-ssh.sh`). Do not paste product Kotlin, Expo gradle, or staging `applicationId`.

**Related scripts**: `agent/scripts/acp.exec-host-ssh.sh`, `acp.exec-host.windows-prepare.ps1`, `acp.exec-host.windows.ps1`, `acp.exec-host.windows-install.ps1`  
**Related command**: [`../commands/acp.smoke.md`](../commands/acp.smoke.md) (`--host`)

Out of scope: `/acp-ci --fast`, Maestro in core E2E, `FIFOZ_*` env names.

---

## 1. Win32-OpenSSH has no `SSH_AUTH_SOCK`

Windows OpenSSH does not provide an agent socket comparable to Unix `SSH_AUTH_SOCK`. Do not require it for clone or scp. Prefer **git bundle + scp**. Optional `ssh -A` on Darwin is unused for clone.

## 2. Admin vs user `authorized_keys`

When the installer is elevated, write **both**:

- User: `%USERPROFILE%\.ssh\authorized_keys`
- Admin: `%ProgramData%\ssh\administrators_authorized_keys`

User-only installs update the user file only. Never print key bytes.

## 3. adb stderr must not terminate PowerShell `Stop`

`adb` writes diagnostics to stderr. With `$ErrorActionPreference = "Stop"`, that can abort the session. Redirect or treat adb stderr as non-terminating. Do not use stderr as a Stop signal.

## 4. Detach the emulator from the SSH job object

An emulator started inside an SSH session dies when the session ends if it stays in the job object. Detach (CreateProcess / `Start-Process` without the SSH job) so the AVD survives disconnect.

## 5. Pin AVD by name, not first `emulator-*`

Use `ACP_AVD_NAME` (or an explicit name). Do not attach to the first `emulator-*` serial. First-device is a false-green.

## 6. SkipPull + scp for uncommitted editor files

Remote `git pull` will not see uncommitted editor work. Skip pull when using a bundle; **scp** (or equivalent) uncommitted files the host needs. Bundle is the committed snapshot.

## 7. Debug APK must not attach to a foreign packager (`:8081`)

A debug binary that talks to a packager on `:8081` (React Native example) must not attach to **someone else’s** packager on the host. Isolate ports / use a release or embedded bundle for device proof. Expo gradle is not ported here.

## 8. Git Bash: script file + SDK env

Do not `bash -lc "…"`. Write a **temp `.sh` file** and invoke Git Bash with that path. Export `ANDROID_HOME`, `JAVA_HOME`, `ANDROID_SERIAL` in that file when those tools are used. Do not put `&&` inside PowerShell 5.1 double-quoted strings.

## 9. LAN adb is `--host local`

USB/LAN adb against a device on the editor network is `--host local` only. Do not use `--host windows` or `--host github` as a synonym for local adb.

---

## Env table (`ACP_*`)

| Variable | Role |
|----------|------|
| `ACP_EXEC_HOST` | `github` \| `windows` \| `local` |
| `ACP_WINDOWS_SSH` | `user@host` for OpenSSH |
| `ACP_WINDOWS_REPO` | Remote path that receives the bundle |
| `ACP_SECRET_FILES` | Comma-separated **relative** paths; missing → exit 1; never print bytes |
| `ACP_AVD_NAME` | AVD name (optional default, not a product constant) |
| `ACP_GIT_BASH` | Optional path to `bash.exe` |

## E2E

Command E2E is **dry-run / help / doctor** only. No emulator, no `--create-avd`, no KVM.
