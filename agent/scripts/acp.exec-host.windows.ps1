# acp.exec-host.windows.ps1 — generic Windows run (M91 / D10)
# Git Bash: write a temp script file (not bash -lc).
# Do not put && inside PowerShell 5.1 double-quoted strings.
# Export ANDROID_HOME / JAVA_HOME / ANDROID_SERIAL when those tools are used.

$ErrorActionPreference = "Stop"

$gitBash = $env:ACP_GIT_BASH
if ([string]::IsNullOrWhiteSpace($gitBash)) {
    $gitBash = "C:\Program Files\Git\bin\bash.exe"
}

$work = Join-Path $env:TEMP ("acp-exec-host-" + [guid]::NewGuid().ToString("N") + ".sh")
$lines = @()
$lines += "#!/usr/bin/env bash"
$lines += "set -euo pipefail"
if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) {
    $lines += "export ANDROID_HOME=`"$($env:ANDROID_HOME)`""
}
if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
    $lines += "export JAVA_HOME=`"$($env:JAVA_HOME)`""
}
if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_SERIAL)) {
    $lines += "export ANDROID_SERIAL=`"$($env:ANDROID_SERIAL)`""
}
$lines += "echo '[acp.exec-host] windows run: env exported; invoke your project runner here'"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($work, $lines, $utf8NoBom)

if (-not (Test-Path -LiteralPath $gitBash)) {
    Write-Error "Git Bash not found at $gitBash. Set ACP_GIT_BASH."
    exit 1
}

& $gitBash $work
$rc = $LASTEXITCODE
Remove-Item -LiteralPath $work -ErrorAction SilentlyContinue
exit $rc
