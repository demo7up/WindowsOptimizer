<#
    ODPower.psm1 - Hibernation/Fast Startup, USB power saving, and power-plan
    import, all with prior-state capture for revert.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Hibernation + Fast Startup ---------------------------------------------

function Get-ODHibernationState {
    $he = Get-ODRegistryValue -Path 'HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled'
    $hb = Get-ODRegistryValue -Path 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled'
    return @{
        HibernateEnabled = if ($he.Exists) { [int]$he.Value } else { 1 }
        HiberbootEnabled = if ($hb.Exists) { [int]$hb.Value } else { 1 }
    }
}

# Disable hibernation and Fast Startup. Returns revert descriptor, or $null if already off.
function Disable-ODHibernation {
    $state = Get-ODHibernationState
    if ($state.HibernateEnabled -eq 0 -and $state.HiberbootEnabled -eq 0) {
        Write-ODLog "Hibernation and Fast Startup already disabled (skipped)" 'SKIP'
        return $null
    }

    $revert = @{ Kind = 'Hibernation'; PriorHibernate = $state.HibernateEnabled; PriorHiberboot = $state.HiberbootEnabled }
    if (Test-ODDryRun) { return $revert }

    $out = & powercfg.exe /hibernate off 2>&1
    if ($LASTEXITCODE -ne 0) { Write-ODLog "powercfg /hibernate off: $out" 'WARN' }
    Set-ODRegistryValue -Path 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -Kind 'DWord' | Out-Null
    return $revert
}

function Restore-ODHibernation {
    param([int]$PriorHibernate, [int]$PriorHiberboot)
    if ($PriorHibernate -eq 1) { & powercfg.exe /hibernate on 2>&1 | Out-Null }
    Set-ODRegistryValue -Path 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value $PriorHiberboot -Kind 'DWord' | Out-Null
}

# --- USB power saving (via root\wmi MSPower_DeviceEnable) --------------------

function Disable-ODUsbPowerSaving {
    $devices = $null
    try {
        $devices = Get-CimInstance -Namespace 'root\wmi' -ClassName 'MSPower_DeviceEnable' -ErrorAction Stop |
            Where-Object { $_.InstanceName -match 'USB' }
    } catch {
        Write-ODLog "MSPower_DeviceEnable WMI class unavailable: $($_.Exception.Message)" 'WARN'
        return $null
    }
    if (-not $devices) {
        Write-ODLog "No USB power-manageable devices found (skipped)" 'SKIP'
        return $null
    }

    $captured = @()
    foreach ($d in $devices) { $captured += @{ InstanceName = $d.InstanceName; PriorEnable = [bool]$d.Enable } }
    $needChange = $captured | Where-Object { $_.PriorEnable -eq $true }
    if (-not $needChange) {
        Write-ODLog "USB power saving already disabled on all devices (skipped)" 'SKIP'
        return $null
    }

    $revert = @{ Kind = 'UsbPower'; Devices = $captured }
    if (Test-ODDryRun) { return $revert }

    foreach ($d in $devices) {
        if ($d.Enable) {
            try { $d.Enable = $false; Set-CimInstance -InputObject $d -ErrorAction Stop }
            catch { Write-ODLog "Failed to disable USB power on $($d.InstanceName): $($_.Exception.Message)" 'WARN' }
        }
    }
    return $revert
}

function Restore-ODUsbPowerSaving {
    param($Devices)
    try {
        $live = Get-CimInstance -Namespace 'root\wmi' -ClassName 'MSPower_DeviceEnable' -ErrorAction Stop
    } catch { return }
    foreach ($rec in $Devices) {
        $match = $live | Where-Object { $_.InstanceName -eq $rec.InstanceName }
        if ($match) {
            try { $match.Enable = [bool]$rec.PriorEnable; Set-CimInstance -InputObject $match -ErrorAction Stop } catch {}
        }
    }
}

# --- Power plan import -------------------------------------------------------

function Get-ODActivePowerScheme {
    $out = & powercfg.exe /getactivescheme 2>&1
    if ($out -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
        return $Matches[1]
    }
    return $null
}

function Test-ODPowerSchemeExists {
    param([string]$Guid)
    $out = & powercfg.exe /list 2>&1
    return ($out -match [regex]::Escape($Guid))
}

# Import + activate the bundled power plan. Returns revert descriptor.
function Install-ODPowerPlan {
    param([Parameter(Mandatory)][string]$PowFile, [Parameter(Mandatory)][string]$Guid)

    if (-not (Test-Path $PowFile)) { throw "Power plan file not found: $PowFile" }
    $prior = Get-ODActivePowerScheme
    $revert = @{ Kind = 'PowerPlan'; PriorActiveGuid = $prior; ImportedGuid = $Guid }
    if (Test-ODDryRun) { return $revert }

    $out = & powercfg.exe /import "$PowFile" $Guid 2>&1
    if ($LASTEXITCODE -ne 0) { throw "powercfg /import failed ($LASTEXITCODE): $out" }
    $out = & powercfg.exe /setactive $Guid 2>&1
    if ($LASTEXITCODE -ne 0) { throw "powercfg /setactive failed ($LASTEXITCODE): $out" }
    return $revert
}

function Restore-ODPowerPlan {
    param([string]$PriorActiveGuid, [string]$ImportedGuid)
    if ($PriorActiveGuid) { & powercfg.exe /setactive $PriorActiveGuid 2>&1 | Out-Null }
    if ($ImportedGuid)    { & powercfg.exe /delete $ImportedGuid 2>&1 | Out-Null }
}

Export-ModuleMember -Function *
