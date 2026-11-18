<#
    ODTools.psm1 - Built-in tools: Dashboard, Disk Cleanup, Bloatware Remover,
    Startup Manager, Scheduled Task Manager.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- Dashboard

function Show-ODDashboard {
    Show-ODBanner
    Write-ODTitle "  SYSTEM DASHBOARD"
    Write-Host ""
    try {
        $os  = Get-CimInstance Win32_OperatingSystem
        $cs  = Get-CimInstance Win32_ComputerSystem
        $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1)
        $gpus = @(Get-CimInstance Win32_VideoController | Select-Object -Expand Name)
        $sys = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $up  = (Get-Date) - $os.LastBootUpTime
        $ramGB  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
        $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $diskFree = [math]::Round($sys.FreeSpace / 1GB, 1)
        $diskTot  = [math]::Round($sys.Size / 1GB, 1)
        $plan = (& powercfg.exe /getactivescheme) -join ' '

        function Row($k, $v) { Write-Host ("   {0,-20} " -f $k) -NoNewline -ForegroundColor Gray; Write-Host $v -ForegroundColor White }
        Row "OS"          ("{0} (build {1})" -f $os.Caption, $os.BuildNumber)
        Row "Computer"    ("{0}  [{1}]" -f $cs.Name, $cs.Manufacturer)
        Row "CPU"         $cpu.Name.Trim()
        Row "RAM"         ("{0} GB total, {1} GB free" -f $ramGB, $freeGB)
        Row "GPU"         ($gpus -join ', ')
        Row "Disk C:"     ("{0} GB free of {1} GB" -f $diskFree, $diskTot)
        Row "Uptime"      ("{0}d {1}h {2}m" -f $up.Days, $up.Hours, $up.Minutes)
        Row "Power plan"  ($plan -replace '^.*:\s*','')
        Row "Elevated"    (Test-ODAdmin)
    } catch {
        Write-ODError ("  Could not read system info: {0}" -f $_.Exception.Message)
    }
    Invoke-ODPause
}

# ---------------------------------------------------------------- Disk Cleanup

function Invoke-ODDiskCleanup {
    Show-ODBanner
    Write-ODTitle "  DISK CLEANUP"
    Write-Host ""
    $targets = @(
        @{ Name='User temp';            Path=$env:TEMP }
        @{ Name='Windows temp';         Path=(Join-Path $env:WINDIR 'Temp') }
        @{ Name='Windows Update cache'; Path=(Join-Path $env:WINDIR 'SoftwareDistribution\Download') }
        @{ Name='Prefetch';             Path=(Join-Path $env:WINDIR 'Prefetch') }
    )
    foreach ($t in $targets) { Write-Host ("   - {0}  ({1})" -f $t.Name, $t.Path) -ForegroundColor Gray }
    Write-Host "   - Recycle Bin (all drives)" -ForegroundColor Gray
    Write-Host ""
    if (Test-ODDryRun) { Write-ODWarn "  (DRY-RUN on - nothing will be deleted.)" }
    if (-not (Confirm-ODAction "  Delete the above temporary files?")) { Write-ODInfo "  Cancelled."; Invoke-ODPause; return }

    $freed = 0
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Path)) { continue }
        try {
            $before = (Get-ChildItem -LiteralPath $t.Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not (Test-ODDryRun)) {
                Get-ChildItem -LiteralPath $t.Path -Force -ErrorAction SilentlyContinue |
                    ForEach-Object { try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop } catch {} }
            }
            if ($before) { $freed += $before }
            Write-ODOk ("   cleaned {0}" -f $t.Name)
        } catch { Write-ODWarn ("   partial {0}: {1}" -f $t.Name, $_.Exception.Message) }
    }
    try {
        if (-not (Test-ODDryRun)) { Clear-RecycleBin -Force -ErrorAction SilentlyContinue }
        Write-ODOk "   emptied Recycle Bin"
    } catch {}
    Write-Host ""
    Write-Host ("  Approx reclaimed: {0:N1} MB" -f ($freed / 1MB)) -ForegroundColor Cyan
    Invoke-ODPause
}

# ---------------------------------------------------------------- Bloatware

function Invoke-ODBloatwareRemover {
    Show-ODBanner
    Write-ODTitle "  BLOATWARE REMOVER"
    Write-Host "  Lists installed Store (AppX) apps. Removing is per-user and reversible by reinstalling from the Store." -ForegroundColor DarkGray
    Write-Host ""
    $apps = @(Get-AppxPackage | Where-Object { -not $_.IsFramework -and $_.NonRemovable -ne $true } | Sort-Object Name)
    if (-not $apps) { Write-ODInfo "  No removable AppX packages found."; Invoke-ODPause; return }

    $n = 0; $map = @{}
    foreach ($a in $apps) {
        $n++; $map[$n] = $a
        Write-Host ("   {0,3}. {1}" -f $n, $a.Name) -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  Enter numbers to REMOVE (e.g. 2,5,9), or 0 to go back." -ForegroundColor DarkGray
    $sel = Read-ODLine "  Selection: "
    if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }

    $picks = Expand-ODSelection -Text $sel -Max $n
    if (-not $picks) { return }
    $targets = @($picks | ForEach-Object { $map[$_] })

    Write-Host ""
    foreach ($t in $targets) { Write-Host ("   - {0}" -f $t.Name) -ForegroundColor Yellow }
    if (Test-ODDryRun) { Write-ODWarn "  (DRY-RUN on - nothing will be removed.)" }
    if (-not (Confirm-ODAction ("  Remove {0} app(s) for the current user?" -f $targets.Count))) { Write-ODInfo "  Cancelled."; Invoke-ODPause; return }

    foreach ($t in $targets) {
        try {
            if (-not (Test-ODDryRun)) { Remove-AppxPackage -Package $t.PackageFullName -ErrorAction Stop }
            Write-ODOk ("   removed {0}" -f $t.Name)
        } catch { Write-ODError ("   failed {0}: {1}" -f $t.Name, $_.Exception.Message) }
    }
    Invoke-ODPause
}

# ---------------------------------------------------------------- Startup Manager

function Get-ODStartupRunEntries {
    $entries = @()
    $locations = @(
        @{ Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Run'; Approved='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' }
        @{ Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'; Approved='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' }
    )
    foreach ($loc in $locations) {
        $info = ConvertFrom-ODRegPath $loc.Path
        $base = Get-ODRegBaseKey -Hive $info.Hive -Writable $false
        try {
            $key = $base.OpenSubKey($info.SubKey, $false)
            if ($null -ne $key) {
                try {
                    foreach ($vn in $key.GetValueNames()) {
                        if ([string]::IsNullOrEmpty($vn)) { continue }
                        $cmd = $key.GetValue($vn)
                        $approved = Get-ODRegistryValue -Path $loc.Approved -Name $vn
                        $enabled = $true
                        if ($approved.Exists -and $approved.Value -is [byte[]] -and $approved.Value.Length -gt 0) {
                            $enabled = -not (($approved.Value[0] -band 0x01) -eq 0x01 -or $approved.Value[0] -eq 3)
                        }
                        $entries += [pscustomobject]@{ Name=$vn; Command=$cmd; RunPath=$loc.Path; ApprovedPath=$loc.Approved; Enabled=$enabled }
                    }
                } finally { $key.Dispose() }
            }
        } finally { $base.Dispose() }
    }
    return $entries
}

function Set-ODStartupEnabled {
    param($Entry, [bool]$Enabled)
    $bytes = if ($Enabled) { [byte[]](2,0,0,0,0,0,0,0,0,0,0,0) } else { [byte[]](3,0,0,0,0,0,0,0,0,0,0,0) }
    Set-ODRegistryValue -Path $Entry.ApprovedPath -Name $Entry.Name -Value $bytes -Kind 'Binary' | Out-Null
}

function Invoke-ODStartupManager {
    while ($true) {
        $entries = @(Get-ODStartupRunEntries)
        Show-ODBanner
        Write-ODTitle "  STARTUP MANAGER (Run keys)"
        Write-Host ""
        if (-not $entries) { Write-ODInfo "  No Run-key startup entries found."; Invoke-ODPause; return }
        $n = 0; $map = @{}
        foreach ($e in $entries) {
            $n++; $map[$n] = $e
            $state = if ($e.Enabled) { 'ENABLED ' } else { 'disabled' }
            $color = if ($e.Enabled) { 'Green' } else { 'DarkGray' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host ("{0} " -f $state) -NoNewline -ForegroundColor $color
            Write-Host ("{0,-28}" -f $e.Name) -NoNewline -ForegroundColor White
            Write-Host ("  {0}" -f $e.Command) -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "  Enter a number to TOGGLE enable/disable, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }
        if ($sel -notmatch '^\d+$' -or -not $map.ContainsKey([int]$sel)) { continue }
        $e = $map[[int]$sel]
        if (Test-ODDryRun) { Write-ODWarn "  (DRY-RUN on - no change written.)"; Invoke-ODPause; continue }
        try { Set-ODStartupEnabled -Entry $e -Enabled (-not $e.Enabled); Write-ODOk ("   toggled {0}" -f $e.Name) }
        catch { Write-ODError ("   failed: {0}" -f $_.Exception.Message) }
        Start-Sleep -Milliseconds 400
    }
}

# ---------------------------------------------------------------- Scheduled Task Manager

function Invoke-ODTaskManager {
    while ($true) {
        $tasks = @(Get-ScheduledTask -ErrorAction SilentlyContinue |
            Where-Object { $_.TaskPath -like '\Microsoft\Windows\*' -or $_.TaskPath -eq '\' } |
            Sort-Object TaskPath, TaskName | Select-Object -First 60)
        Show-ODBanner
        Write-ODTitle "  SCHEDULED TASK MANAGER (first 60)"
        Write-Host ""
        if (-not $tasks) { Write-ODInfo "  No scheduled tasks enumerable."; Invoke-ODPause; return }
        $n = 0; $map = @{}
        foreach ($t in $tasks) {
            $n++; $map[$n] = $t
            $color = if ($t.State -eq 'Disabled') { 'DarkGray' } else { 'Green' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host ("{0,-9}" -f $t.State) -NoNewline -ForegroundColor $color
            Write-Host ("{0}{1}" -f $t.TaskPath, $t.TaskName) -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "  Enter a number to TOGGLE enable/disable, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }
        if ($sel -notmatch '^\d+$' -or -not $map.ContainsKey([int]$sel)) { continue }
        $t = $map[[int]$sel]
        if (Test-ODDryRun) { Write-ODWarn "  (DRY-RUN on - no change written.)"; Invoke-ODPause; continue }
        try {
            if ($t.State -eq 'Disabled') { Enable-ScheduledTask -TaskPath $t.TaskPath -TaskName $t.TaskName | Out-Null; Write-ODOk "   enabled" }
            else { Disable-ScheduledTask -TaskPath $t.TaskPath -TaskName $t.TaskName | Out-Null; Write-ODOk "   disabled" }
        } catch { Write-ODError ("   failed: {0}" -f $_.Exception.Message) }
        Start-Sleep -Milliseconds 400
    }
}

# ---------------------------------------------------------------- Tools menu

function Invoke-ODToolsMenu {
    while ($true) {
        Show-ODBanner
        Write-ODTitle "  TOOLS"
        Write-Host ""
        Write-Host "   1. System Dashboard" -ForegroundColor White
        Write-Host "   2. Disk Cleanup" -ForegroundColor White
        Write-Host "   3. Bloatware Remover" -ForegroundColor White
        Write-Host "   4. Startup Manager" -ForegroundColor White
        Write-Host "   5. Scheduled Task Manager" -ForegroundColor White
        Write-Host "   0. Back" -ForegroundColor DarkGray
        $sel = Read-ODLine "  Choose: "
        switch ($sel.Trim()) {
            '1' { Show-ODDashboard }
            '2' { Invoke-ODDiskCleanup }
            '3' { Invoke-ODBloatwareRemover }
            '4' { Invoke-ODStartupManager }
            '5' { Invoke-ODTaskManager }
            '0' { return }
            default { }
        }
    }
}

Export-ModuleMember -Function *
