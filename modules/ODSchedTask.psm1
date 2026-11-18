<#
    ODSchedTask.psm1 - Enable/disable scheduled tasks with prior-state capture.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Split a full task path like "\Microsoft\Windows\Foo\Bar" into TaskPath + TaskName.
function Split-ODTaskPath {
    param([Parameter(Mandatory)][string]$FullPath)
    $fp = $FullPath
    if (-not $fp.StartsWith('\')) { $fp = '\' + $fp }
    $idx = $fp.LastIndexOf('\')
    $name = $fp.Substring($idx + 1)
    $path = $fp.Substring(0, $idx + 1)   # keep trailing backslash
    if ([string]::IsNullOrEmpty($path)) { $path = '\' }
    return [pscustomobject]@{ TaskPath = $path; TaskName = $name }
}

function Get-ODTask {
    param([string]$FullPath)
    $parts = Split-ODTaskPath $FullPath
    try {
        return Get-ScheduledTask -TaskPath $parts.TaskPath -TaskName $parts.TaskName -ErrorAction Stop
    } catch {
        return $null
    }
}

# Disable a scheduled task. Returns revert descriptor, or $null if absent/already disabled.
function Disable-ODTask {
    param([Parameter(Mandatory)][string]$FullPath)

    $task = Get-ODTask -FullPath $FullPath
    if ($null -eq $task) {
        Write-ODLog "Scheduled task '$FullPath' not found (skipped)" 'SKIP'
        return $null
    }
    if ($task.State -eq 'Disabled') {
        Write-ODLog "Scheduled task '$FullPath' already disabled (skipped)" 'SKIP'
        return $null
    }

    $revert = @{ Kind = 'SchedTask'; Path = $FullPath; PriorEnabled = $true }
    if (Test-ODDryRun) { return $revert }

    $parts = Split-ODTaskPath $FullPath
    Disable-ScheduledTask -TaskPath $parts.TaskPath -TaskName $parts.TaskName -ErrorAction Stop | Out-Null
    return $revert
}

function Enable-ODTask {
    param([Parameter(Mandatory)][string]$FullPath)
    $parts = Split-ODTaskPath $FullPath
    Enable-ScheduledTask -TaskPath $parts.TaskPath -TaskName $parts.TaskName -ErrorAction Stop | Out-Null
}

Export-ModuleMember -Function *
