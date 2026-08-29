# acp.exec-host.windows-prepare.ps1 — generic Windows prepare (M91 / D10)
# No product paths. Prefer a git bundle over cloning GitHub (404 without a bundle).
param(
    [string]$BundleFile = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BundleFile)) {
    Write-Error "Pass -BundleFile <path> from git bundle create. A GitHub clone that 404s is expected without a bundle — do not treat that as success."
    exit 1
}

if (-not (Test-Path -LiteralPath $BundleFile)) {
    Write-Error "Bundle file missing: $BundleFile. Create it on the editor with: git bundle create acp-exec-host.bundle HEAD"
    exit 1
}

Write-Host "[acp.exec-host] prepare: bundle present (not cloning GitHub as the source of truth)"
exit 0
