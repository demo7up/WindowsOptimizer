<#
    WindowsOptimizer.ps1 - Entry point for WindowsOptimizer.

    A PowerShell port of optimizerDuck (https://github.com/itsfatduck/optimizerDuck).
    optimizerDuck is Copyright (C) 2025-2026 fatDuck (itsfatduck), licensed GPLv3.
    This port is likewise licensed under the GNU General Public License v3.0.
    See LICENSE.

    Usage:
        Right-click -> Run with PowerShell, or from an elevated prompt:
            powershell -ExecutionPolicy Bypass -File .\WindowsOptimizer.ps1
    The script elevates itself automatically if not already running as admin.
#>

#requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$Live   # start in LIVE mode instead of the default dry-run
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Self-elevate ------------------------------------------------------------

function Test-IsAdmin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "WindowsOptimizer needs administrator rights. Relaunching elevated..." -ForegroundColor Yellow
    $hostExe = (Get-Process -Id $PID).Path
    if (-not $hostExe) { $hostExe = 'powershell.exe' }
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    if ($Live) { $argList += '-Live' }
    try {
        Start-Process -FilePath $hostExe -Verb RunAs -ArgumentList $argList
    } catch {
        Write-Host "Elevation was cancelled or failed. Exiting." -ForegroundColor Red
    }
    return
}

# --- Load modules ------------------------------------------------------------

$modulesDir = Join-Path $PSScriptRoot 'modules'
$moduleOrder = @(
    'ODCommon', 'ODRegistry', 'ODService', 'ODSchedTask', 'ODPower',
    'ODConditions', 'ODRevert', 'ODEngine', 'ODData', 'ODMenu', 'ODTools', 'ODToolbox'
)
foreach ($m in $moduleOrder) {
    Import-Module (Join-Path $modulesDir "$m.psm1") -Force -DisableNameChecking
}

Initialize-ODLog

# Default to DRY-RUN for safety: nothing is written until the user switches to LIVE.
Set-ODDryRun (-not $Live)

# --- Main menu ---------------------------------------------------------------

function Invoke-ODMainMenu {
    while ($true) {
        Show-ODBanner
        if (Test-ODDryRun) {
            Write-Host "  DRY-RUN mode: nothing is written until you switch to LIVE (see MORE below)." -ForegroundColor Cyan
            Write-Host ""
        }
        $index = Get-ODFeatureIndex
        $counts = @{}
        foreach ($m in $index) { if ($counts.ContainsKey($m.Cat)) { $counts[$m.Cat]++ } else { $counts[$m.Cat] = 1 } }

        $n = 0; $map = @{}
        foreach ($c in (Get-ODCategoryOrder)) {
            $n++; $map[$n] = @{ kind = 'cat'; name = $c }
            $cnt = if ($counts.ContainsKey($c)) { $counts[$c] } else { 0 }
            Write-Host ("   {0,3}. {1,-30}" -f $n, $c) -NoNewline -ForegroundColor White
            Write-Host ("  ({0})" -f $cnt) -ForegroundColor DarkGray
        }
        Write-Host "`n  == MORE ==" -ForegroundColor Cyan
        $n++; $map[$n] = @{ kind = 'fn'; fn = 'search' }; Write-Host ("   {0,3}. {1}" -f $n, 'Search / All features') -ForegroundColor White
        $n++; $map[$n] = @{ kind = 'fn'; fn = 'revert' }; Write-Host ("   {0,3}. {1}" -f $n, 'Revert (undo applied changes)') -ForegroundColor White
        $toggle = if (Test-ODDryRun) { 'Switch to LIVE mode' } else { 'Switch to DRY-RUN mode' }
        $n++; $map[$n] = @{ kind = 'fn'; fn = 'toggle' }; Write-Host ("   {0,3}. {1}" -f $n, $toggle) -ForegroundColor Magenta
        Write-Host "     0. Exit" -ForegroundColor DarkGray
        Write-Host ""
        $sel = Read-ODLine "  Choose: "
        $t = $sel.Trim()
        if ($t -eq '0') { Write-Host "  Bye!" -ForegroundColor Yellow; return }
        if ($t -notmatch '^\d+$' -or -not $map.ContainsKey([int]$t)) { continue }
        $pick = $map[[int]$t]
        if ($pick.kind -eq 'cat') { Invoke-ODCategoryView -Category $pick.name; continue }
        switch ($pick.fn) {
            'search' { Invoke-ODAllFeaturesMenu }
            'revert' { Invoke-ODRevertMenu }
            'toggle' {
                $new = -not (Test-ODDryRun)
                if ($new) { Set-ODDryRun $true; Write-ODWarn "  Switched to DRY-RUN (no changes will be written)."; Start-Sleep -Milliseconds 400 }
                else {
                    Show-ODBanner
                    Write-ODWarn "  Switching to LIVE mode. Real system changes will be written."
                    if (Confirm-ODAction "  Enable LIVE mode?") { Set-ODDryRun $false; Write-ODOk "  LIVE mode enabled." }
                    else { Set-ODDryRun $true; Write-ODInfo "  Staying in DRY-RUN." }
                    Invoke-ODPause
                }
            }
        }
    }
}

try {
    Invoke-ODMainMenu
} finally {
    Write-ODLog "Session ended" 'INFO'
    $lf = Get-ODLogFile
    if ($lf) { Write-Host ("  Log: {0}" -f $lf) -ForegroundColor DarkGray }
}
