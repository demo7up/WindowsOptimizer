<#
    WindowsOptimizer bootstrap - download the latest source and launch it.

    One-line usage (in PowerShell):
        irm https://raw.githubusercontent.com/demo7up/WindowsOptimizer/main/boot.ps1 | iex

    Security: this elevates FIRST, then downloads and runs as administrator into
    a fresh, random, admin-only temp directory, and resolves the exact entry-script
    path (no recursive search). That avoids any window where a non-admin process
    could tamper with code that is about to run elevated (TOCTOU).
    Licensed GPL-3.0. See LICENSE.
#>

$ErrorActionPreference = 'Stop'
$oneLiner = 'irm https://raw.githubusercontent.com/demo7up/WindowsOptimizer/main/boot.ps1 | iex'

# --- Elevate first -----------------------------------------------------------
$id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = (New-Object System.Security.Principal.WindowsPrincipal($id)).IsInRole(
    [System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Requesting administrator rights...' -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $oneLiner
    } catch {
        Write-Host 'Elevation was cancelled. Nothing was downloaded or run.' -ForegroundColor Red
    }
    return
}

# --- Download + run (now elevated) ------------------------------------------
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$repo = 'demo7up/WindowsOptimizer'
$branch = 'main'

# Fresh, unpredictable directory; lock it to Administrators + SYSTEM only.
$root = Join-Path $env:TEMP ('WindowsOptimizer-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root -Force | Out-Null
try { & icacls "$root" /inheritance:r /grant:r '*S-1-5-32-544:(OI)(CI)F' '*S-1-5-18:(OI)(CI)F' | Out-Null } catch {}

$zip = Join-Path $root 'src.zip'
Write-Host 'Downloading WindowsOptimizer...' -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/$repo/archive/refs/heads/$branch.zip" -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $root -Force
Remove-Item $zip -Force -ErrorAction SilentlyContinue

# Resolve the exact expected path (never a recursive search).
$entry = Join-Path $root ("WindowsOptimizer-$branch\WindowsOptimizer.ps1")
if (-not (Test-Path -LiteralPath $entry)) { throw "Entry script not found at expected path: $entry" }

Write-Host 'Launching WindowsOptimizer...' -ForegroundColor Green
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $entry
