<#
    ODCommon.psm1 - Shared helpers: paths, logging, elevation, host output.
    Part of WindowsOptimizer - a PowerShell port of optimizerDuck (GPLv3, (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Paths -------------------------------------------------------------------

function Get-ODRoot {
    # The repo root (parent of /modules).
    return (Split-Path -Parent $PSScriptRoot)
}

function Get-ODDataDir {
    return (Join-Path (Get-ODRoot) 'data')
}

function Get-ODAppDataDir {
    $dir = Join-Path $env:LOCALAPPDATA 'WindowsOptimizer'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    return $dir
}

function Get-ODRevertDir {
    $dir = Join-Path (Get-ODAppDataDir) 'Revert'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    return $dir
}

function Get-ODLogDir {
    $dir = Join-Path (Get-ODAppDataDir) 'Logs'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    return $dir
}

# --- Dry-run state -----------------------------------------------------------

$script:ODDryRun = $false
function Set-ODDryRun { param([bool]$Enabled) $script:ODDryRun = $Enabled }
function Test-ODDryRun { return $script:ODDryRun }

# --- Logging -----------------------------------------------------------------

$script:ODLogFile = $null
function Initialize-ODLog {
    $script:ODLogFile = Join-Path (Get-ODLogDir) ("session-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Write-ODLog "WindowsOptimizer session started" 'INFO'
}

function Write-ODLog {
    param([string]$Message, [ValidateSet('INFO','WARN','ERROR','CHANGE','SKIP')][string]$Level = 'INFO')
    $line = "{0} [{1}] {2}" -f (Get-Date -Format 'HH:mm:ss'), $Level, $Message
    if ($script:ODLogFile) {
        try { Add-Content -Path $script:ODLogFile -Value $line -Encoding UTF8 } catch {}
    }
}

function Get-ODLogFile { return $script:ODLogFile }

# --- Console output ----------------------------------------------------------

function Write-ODInfo    { param([string]$Text) Write-Host $Text -ForegroundColor Gray }
function Write-ODOk      { param([string]$Text) Write-Host $Text -ForegroundColor Green }
function Write-ODWarn    { param([string]$Text) Write-Host $Text -ForegroundColor Yellow }
function Write-ODError   { param([string]$Text) Write-Host $Text -ForegroundColor Red }
function Write-ODTitle   { param([string]$Text) Write-Host $Text -ForegroundColor Cyan }

function Get-ODRiskColor {
    param([string]$Risk)
    switch ($Risk) {
        'Safe'     { 'Green' }
        'Moderate' { 'Yellow' }
        'Risky'    { 'Red' }
        default    { 'Gray' }
    }
}

# --- Elevation ---------------------------------------------------------------

function Test-ODAdmin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

Export-ModuleMember -Function *
