<#
    ODRevert.psm1 - Persist per-tweak revert descriptors to JSON and restore
    them. One file per optimization/setting id, like the original's Revert/{id}.json.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ODRevertFile {
    param([Parameter(Mandatory)][string]$Id)
    return (Join-Path (Get-ODRevertDir) ("{0}.json" -f $Id))
}

function Test-ODApplied {
    param([Parameter(Mandatory)][string]$Id)
    return (Test-Path (Get-ODRevertFile -Id $Id))
}

# Persist the revert descriptors recorded while applying a tweak.
function Save-ODRevert {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Operations
    )
    if (Test-ODDryRun) { return }
    $ops = @($Operations | Where-Object { $_ -ne $null })
    $record = [pscustomobject]@{
        Id         = $Id
        Name       = $Name
        AppliedAt  = (Get-Date).ToString('o')
        Operations = $ops
    }
    $json = $record | ConvertTo-Json -Depth 12
    $file = Get-ODRevertFile -Id $Id
    $tmp  = "$file.tmp"
    Set-Content -Path $tmp -Value $json -Encoding UTF8
    Move-Item -Path $tmp -Destination $file -Force
}

function Get-ODRevertEntries {
    $dir = Get-ODRevertDir
    $entries = @()
    foreach ($f in (Get-ChildItem -Path $dir -Filter '*.json' -ErrorAction SilentlyContinue)) {
        try {
            $r = Get-Content -Path $f.FullName -Raw | ConvertFrom-Json
            $entries += [pscustomobject]@{ Id = $r.Id; Name = $r.Name; AppliedAt = $r.AppliedAt; File = $f.FullName }
        } catch {}
    }
    return $entries
}

# Invert a single revert descriptor.
function Invoke-ODRevertOp {
    param($Op)
    switch ($Op.Kind) {
        'Reg' {
            if ($Op.PriorExists) {
                Set-ODRegistryValue -Path $Op.Path -Name $Op.Name -Value $Op.PriorValue -Kind $Op.PriorKind | Out-Null
            } else {
                Remove-ODRegistryValue -Path $Op.Path -Name $Op.Name | Out-Null
            }
        }
        'RegKeyTree' {
            # We cannot faithfully recreate an arbitrary deleted subtree. If it
            # previously existed, recreate the (empty) key so structure returns.
            if ($Op.PriorExisted) {
                Set-ODRegistryValue -Path $Op.Path -Name '__odplaceholder' -Value 1 -Kind 'DWord' | Out-Null
                Remove-ODRegistryValue -Path $Op.Path -Name '__odplaceholder' | Out-Null
                Write-ODLog "Recreated key (contents not restorable): $($Op.Path)" 'WARN'
            }
        }
        'Service'     { Set-ODServiceStartup -Name $Op.Name -Startup $Op.PriorStartup | Out-Null }
        'SchedTask'   { if ($Op.PriorEnabled) { Enable-ODTask -FullPath $Op.Path } }
        'Hibernation' { Restore-ODHibernation -PriorHibernate ([int]$Op.PriorHibernate) -PriorHiberboot ([int]$Op.PriorHiberboot) }
        'UsbPower'    { Restore-ODUsbPowerSaving -Devices $Op.Devices }
        'PowerPlan'   { Restore-ODPowerPlan -PriorActiveGuid $Op.PriorActiveGuid -ImportedGuid $Op.ImportedGuid }
        default       { Write-ODLog "Unknown revert op kind '$($Op.Kind)' (skipped)" 'WARN' }
    }
}

# Restore everything recorded for a tweak, then remove its revert file.
function Invoke-ODRevert {
    param([Parameter(Mandatory)][string]$Id)
    $file = Get-ODRevertFile -Id $Id
    if (-not (Test-Path $file)) { throw "No revert data for id $Id" }
    $record = Get-Content -Path $file -Raw | ConvertFrom-Json

    $ops = @($record.Operations)
    [array]::Reverse($ops)
    foreach ($op in $ops) {
        try { Invoke-ODRevertOp -Op $op }
        catch { Write-ODLog "Revert op failed for $($record.Name): $($_.Exception.Message)" 'ERROR' }
    }
    Remove-Item -Path $file -Force
    Write-ODLog "Reverted: $($record.Name)" 'CHANGE'
}

Export-ModuleMember -Function *
