# acp.exec-host.windows-install.ps1 — generic OpenSSH host prep (M91 / D10)
# When elevated, write BOTH admin and user authorized_keys locations.
# AVD name is $env:ACP_AVD_NAME (optional default), not a product constant.

$ErrorActionPreference = "Stop"

$avd = $env:ACP_AVD_NAME
if ([string]::IsNullOrWhiteSpace($avd)) {
    $avd = "Pixel_API_default"
}

$identity = Join-Path $env:USERPROFILE ".ssh\id_ed25519.pub"
$userKeys = Join-Path $env:USERPROFILE ".ssh\authorized_keys"
$adminKeys = Join-Path $env:ProgramData "ssh\administrators_authorized_keys"

$isAdmin = $false
try {
    $prin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = $prin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {
    $isAdmin = $false
}

Write-Host "[acp.exec-host] install: AVD name from ACP_AVD_NAME or default ($avd) — pin by name, not first emulator-*"
Write-Host "[acp.exec-host] detach emulator from the SSH job object; adb stderr must not Stop PowerShell"

if ($isAdmin) {
    Write-Host "[acp.exec-host] elevated: would update $adminKeys and $userKeys (bytes not printed)"
} else {
    Write-Host "[acp.exec-host] not elevated: would update $userKeys only"
}

if (Test-Path -LiteralPath $identity) {
    Write-Host "[acp.exec-host] public key file present (not printed)"
} else {
    Write-Host "[acp.exec-host] no id_ed25519.pub yet — generate before copying to authorized_keys"
}

exit 0
