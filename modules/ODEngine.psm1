<#
    ODEngine.psm1 - Apply a resolved list of operations, dispatching each to the
    right primitive, collecting revert descriptors, and persisting them.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ODPowerPlanGuid = '8ae61178-2c55-43f2-afb2-f83725823657'

# Apply one operation. Appends 0+ revert descriptors to $RevertList (by ref).
function Invoke-ODOperation {
    param($Op, [System.Collections.ArrayList]$RevertList)

    switch ($Op.Type) {
        'Reg' {
            $r = Set-ODRegistryValue -Path $Op.Path -Name $Op.Name -Value $Op.Value -Kind $Op.Kind
            if ($r) { [void]$RevertList.Add($r) }
            Write-ODLog "REG $($Op.Path)\$($Op.Name) = $($Op.Value) [$($Op.Kind)]" 'CHANGE'
        }
        'RegDelete' {
            $r = Remove-ODRegistryValue -Path $Op.Path -Name $Op.Name
            if ($r) { [void]$RevertList.Add($r) }
            Write-ODLog "REG DELETE $($Op.Path)\$($Op.Name)" 'CHANGE'
        }
        'RegDeleteTree' {
            $r = Remove-ODRegistryKeyTree -Path $Op.Path
            if ($r) { [void]$RevertList.Add($r) }
            Write-ODLog "REG DELETE TREE $($Op.Path)" 'CHANGE'
        }
        'RegGpu' {
            $keys = Get-ODGpuClassKeys -Vendor $Op.Vendor
            if (-not $keys) { Write-ODLog "No $($Op.Vendor) GPU class key found for $($Op.Name) (skipped)" 'SKIP'; break }
            foreach ($k in $keys) {
                $r = Set-ODRegistryValue -Path $k -Name $Op.Name -Value $Op.Value -Kind $Op.Kind
                if ($r) { [void]$RevertList.Add($r) }
                Write-ODLog "REG(GPU $($Op.Vendor)) $k\$($Op.Name) = $($Op.Value)" 'CHANGE'
            }
        }
        'Service' {
            $r = Set-ODServiceStartup -Name $Op.Name -Startup $Op.Startup
            if ($r) { [void]$RevertList.Add($r); Write-ODLog "SERVICE $($Op.Name) -> $($Op.Startup)" 'CHANGE' }
        }
        'ServiceList' {
            $data = Import-PowerShellDataFile -Path (Join-Path (Get-ODDataDir) 'services.psd1')
            foreach ($svc in $data.Services) {
                $r = Set-ODServiceStartup -Name $svc.Name -Startup $svc.Startup
                if ($r) { [void]$RevertList.Add($r); Write-ODLog "SERVICE $($svc.Name) -> $($svc.Startup)" 'CHANGE' }
            }
        }
        'SchedTask' {
            $r = Disable-ODTask -FullPath $Op.Path
            if ($r) { [void]$RevertList.Add($r); Write-ODLog "SCHEDTASK DISABLE $($Op.Path)" 'CHANGE' }
        }
        'Hibernation' {
            $r = Disable-ODHibernation
            if ($r) { [void]$RevertList.Add($r); Write-ODLog "HIBERNATION off + Fast Startup off" 'CHANGE' }
        }
        'UsbPower' {
            $r = Disable-ODUsbPowerSaving
            if ($r) { [void]$RevertList.Add($r); Write-ODLog "USB power saving disabled" 'CHANGE' }
        }
        'PowerPlan' {
            $pow = Join-Path (Get-ODDataDir) 'highperf-powerplan.pow'
            $r = Install-ODPowerPlan -PowFile $pow -Guid $script:ODPowerPlanGuid
            if ($r) { [void]$RevertList.Add($r); Write-ODLog "Installed + activated high-performance power plan" 'CHANGE' }
        }
        'NumLock' {
            # InitialKeyboardIndicators: bit 2 (value 2) = NumLock on. Stored as REG_SZ.
            foreach ($p in @('HKCU\Control Panel\Keyboard', 'HKU\.DEFAULT\Control Panel\Keyboard')) {
                $cur = Get-ODRegistryValue -Path $p -Name 'InitialKeyboardIndicators'
                $n = 0; if ($cur.Exists) { [void][int]::TryParse([string]$cur.Value, [ref]$n) }
                if ($Op.On) { $n = $n -bor 2 } else { $n = $n -band (-bnot 2) }
                $r = Set-ODRegistryValue -Path $p -Name 'InitialKeyboardIndicators' -Value ([string]$n) -Kind 'String'
                if ($r) { [void]$RevertList.Add($r) }
            }
            Write-ODLog "NumLock on boot = $($Op.On)" 'CHANGE'
        }
        'ShortcutArrow' {
            $iconsKey = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
            if ($Op.On) {
                $r = Remove-ODRegistryValue -Path $iconsKey -Name '29'
                if ($r) { [void]$RevertList.Add($r) }
            } else {
                $blank = Join-Path (Get-ODDataDir) 'blank.ico'
                $r = Set-ODRegistryValue -Path $iconsKey -Name '29' -Value $blank -Kind 'String'
                if ($r) { [void]$RevertList.Add($r) }
            }
            Write-ODLog "Shortcut arrow shown = $($Op.On)" 'CHANGE'
        }
        'SvcHostSplit' {
            # Raise the svchost split threshold to total physical RAM (KB) so
            # services share fewer host processes.
            $kb = $null
            try { $kb = [int64]((Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory / 1024) } catch {}
            if (-not $kb -or $kb -le 0) { Write-ODLog "Could not read total RAM (skipped SvcHostSplit)" 'SKIP'; break }
            if ($kb -gt 0xFFFFFFFF) { $kb = 0xFFFFFFFF }
            $r = Set-ODRegistryValue -Path 'HKLM\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value $kb -Kind 'DWord'
            if ($r) { [void]$RevertList.Add($r) }
            Write-ODLog "SvcHostSplitThresholdInKB = $kb" 'CHANGE'
        }
        default { Write-ODLog "Unknown operation type '$($Op.Type)' (skipped)" 'WARN' }
    }
}

# Apply a resolved operation list under one id. Returns a result object.
function Invoke-ODOperations {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][object[]]$Operations,
        [switch]$SkipRevertSave
    )
    $revert = New-Object System.Collections.ArrayList
    $errors = @()
    foreach ($op in $Operations) {
        try { Invoke-ODOperation -Op $op -RevertList $revert }
        catch {
            $msg = $_.Exception.Message
            $errors += $msg
            Write-ODLog "Operation failed in '$Name': $msg" 'ERROR'
        }
    }
    # Preserve the original snapshot: only write revert data the first time a
    # subject is changed, so revert always restores the true original state.
    if (-not (Test-ODDryRun) -and -not $SkipRevertSave -and $revert.Count -gt 0) {
        Save-ODRevert -Id $Id -Name $Name -Operations $revert.ToArray()
    }
    return [pscustomobject]@{
        Success     = ($errors.Count -eq 0)
        ChangeCount = $revert.Count
        Errors      = $errors
    }
}

Export-ModuleMember -Function *
