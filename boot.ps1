<#
    WindowsOptimizer bootstrap - download the latest source and launch it.

    One-line usage (in PowerShell):
        irm https://raw.githubusercontent.com/demo7up/WindowsOptimizer/main/boot.ps1 | iex

    This downloads the repository to a temp folder and runs WindowsOptimizer.ps1,
    which elevates itself (accept the UAC prompt). It opens in DRY-RUN mode.
    Licensed GPL-3.0. See LICENSE.
#>

$ErrorActionPreference = 'Stop'
$repo   = 'demo7up/WindowsOptimizer'
$branch = 'main'
$dest   = Join-Path $env:TEMP 'WindowsOptimizer'
$zip    = Join-Path $env:TEMP 'WindowsOptimizer.zip'

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

Write-Host 'Downloading WindowsOptimizer...' -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/$repo/archive/refs/heads/$branch.zip" -OutFile $zip -UseBasicParsing

if (Test-Path $dest) { Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue }
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip -Force -ErrorAction SilentlyContinue

$entry = Get-ChildItem -Path $dest -Recurse -Filter 'WindowsOptimizer.ps1' | Select-Object -First 1
if (-not $entry) { throw 'WindowsOptimizer.ps1 was not found in the download.' }

Write-Host 'Launching WindowsOptimizer (accept the admin prompt)...' -ForegroundColor Green
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $entry.FullName
