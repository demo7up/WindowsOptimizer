<#
    ODConditions.psm1 - System gates (OS version, GPU vendor) that decide
    whether a given tweak is available, plus GPU class-key index resolution.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ODGpuClassRoot = 'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'

function Get-ODOsBuild {
    return [int][System.Environment]::OSVersion.Version.Build
}

function Test-ODWindows11 { return (Get-ODOsBuild) -ge 22000 }
function Test-ODWindows10 { $b = Get-ODOsBuild; return ($b -ge 10240 -and $b -lt 22000) }
function Test-ODWindows11_24H2 { return (Get-ODOsBuild) -ge 26100 }

# Cache video controllers once per session.
$script:ODVideoControllers = $null
function Get-ODVideoControllers {
    if ($null -eq $script:ODVideoControllers) {
        try { $script:ODVideoControllers = @(Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop) }
        catch { $script:ODVideoControllers = @() }
    }
    return $script:ODVideoControllers
}

function Test-ODGpuVendor {
    param([ValidateSet('Amd','Nvidia','Intel')][string]$Vendor)
    $pattern = switch ($Vendor) {
        'Amd'    { 'AMD|Advanced Micro|ATI|Radeon' }
        'Nvidia' { 'NVIDIA|GeForce|Quadro' }
        'Intel'  { 'Intel' }
    }
    foreach ($vc in (Get-ODVideoControllers)) {
        $hay = "$($vc.Name) $($vc.AdapterCompatibility)"
        if ($hay -match $pattern) { return $true }
    }
    return $false
}

# Resolve the Class\{...}\NNNN subkeys whose driver matches the vendor.
function Get-ODGpuClassKeys {
    param([ValidateSet('Amd','Nvidia','Intel')][string]$Vendor)
    $pattern = switch ($Vendor) {
        'Amd'    { 'AMD|Advanced Micro|ATI|Radeon' }
        'Nvidia' { 'NVIDIA|GeForce|Quadro' }
        'Intel'  { 'Intel' }
    }
    $keys = @()
    for ($i = 0; $i -le 50; $i++) {
        $idx = '{0:D4}' -f $i
        $full = "$script:ODGpuClassRoot\$idx"
        if (-not (Test-ODRegistryKey -Path $full)) { continue }
        $desc = (Get-ODRegistryValue -Path $full -Name 'DriverDesc').Value
        $prov = (Get-ODRegistryValue -Path $full -Name 'ProviderName').Value
        $match = (Get-ODRegistryValue -Path $full -Name 'MatchingDeviceId').Value
        $hay = "$desc $prov $match"
        if ($hay -match $pattern) { $keys += $full }
    }
    return $keys
}

# Evaluate a named condition. Returns @{ Available=$bool; Reason='...' }.
function Test-ODCondition {
    param([string]$Condition)
    if ([string]::IsNullOrEmpty($Condition) -or $Condition -eq 'none') {
        return @{ Available = $true; Reason = '' }
    }
    switch ($Condition) {
        'Windows10Condition' {
            if (Test-ODWindows10) { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'Windows 10 only' }
        }
        'Windows11Condition' {
            if (Test-ODWindows11) { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'Windows 11 only' }
        }
        'Windows11_24H2OrGreaterCondition' {
            if (Test-ODWindows11_24H2) { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'Windows 11 24H2+ only' }
        }
        'RecallInstalledCondition' {
            if (Test-ODWindows11_24H2) { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'Recall (Win11 24H2+) not present' }
        }
        'AmdGpuCondition' {
            if (Test-ODGpuVendor 'Amd') { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'No AMD GPU detected' }
        }
        'NvidiaGpuCondition' {
            if (Test-ODGpuVendor 'Nvidia') { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'No NVIDIA GPU detected' }
        }
        'IntelGpuCondition' {
            if (Test-ODGpuVendor 'Intel') { return @{ Available = $true; Reason = '' } }
            return @{ Available = $false; Reason = 'No Intel GPU detected' }
        }
        default { return @{ Available = $true; Reason = '' } }
    }
}

Export-ModuleMember -Function *
