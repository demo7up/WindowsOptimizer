<#
    ODService.psm1 - Change Windows service startup type via sc.exe (works on
    PowerShell 5.1 and handles delayed-auto), with prior-state capture.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Read a service's current startup type from the registry.
# Returns one of Automatic|AutomaticDelayedStart|Manual|Disabled|Boot|System, or $null if the service is absent.
function Get-ODServiceStartup {
    param([Parameter(Mandatory)][string]$Name)
    $path = "HKLM\SYSTEM\CurrentControlSet\Services\$Name"
    if (-not (Test-ODRegistryKey -Path $path)) { return $null }
    $start = Get-ODRegistryValue -Path $path -Name 'Start'
    if (-not $start.Exists) { return $null }
    switch ([int]$start.Value) {
        0 { return 'Boot' }
        1 { return 'System' }
        2 {
            $delayed = Get-ODRegistryValue -Path $path -Name 'DelayedAutostart'
            if ($delayed.Exists -and [int]$delayed.Value -eq 1) { return 'AutomaticDelayedStart' }
            return 'Automatic'
        }
        3 { return 'Manual' }
        4 { return 'Disabled' }
        default { return 'Unknown' }
    }
}

function Get-ODScStartArg {
    param([string]$Startup)
    switch ($Startup) {
        'Automatic'             { 'auto' }
        'AutomaticDelayedStart' { 'delayed-auto' }
        'Manual'                { 'demand' }
        'Disabled'              { 'disabled' }
        'Boot'                  { 'boot' }
        'System'                { 'system' }
        default                 { throw "Unknown startup type: $Startup" }
    }
}

# Change startup type. Returns a revert descriptor, or $null when skipped
# (service absent or already in desired state).
function Set-ODServiceStartup {
    param([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][string]$Startup)

    $current = Get-ODServiceStartup -Name $Name
    if ($null -eq $current) {
        Write-ODLog "Service '$Name' not present (skipped)" 'SKIP'
        return $null
    }
    if ($current -eq $Startup) {
        Write-ODLog "Service '$Name' already $Startup (skipped)" 'SKIP'
        return $null
    }

    $revert = @{ Kind = 'Service'; Name = $Name; PriorStartup = $current }
    if (Test-ODDryRun) { return $revert }

    $arg = Get-ODScStartArg -Startup $Startup
    $out = & sc.exe config "$Name" start= $arg 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "sc.exe config '$Name' start= $arg failed ($LASTEXITCODE): $out"
    }
    return $revert
}

Export-ModuleMember -Function *
