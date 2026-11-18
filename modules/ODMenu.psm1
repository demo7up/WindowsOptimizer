<#
    ODMenu.psm1 - Console menu UI: main menu, optimize, customize, revert.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Show-ODBanner {
    Clear-Host
    $art = @'
__        ___           _
\ \      / (_)_ __   __| | _____      _____
 \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / / __|
  \ V  V / | | | | | (_| | (_) \ V  V /\__ \
   \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/ |___/
  ___        _   _           _
 / _ \ _ __ | |_(_)_ __ ___ (_)_______ ___
| | | | '_ \| __| | '_ ` _ \| |_  / _ \ '__|
| |_| | |_) | |_| | | | | | | |/ /  __/ |
 \___/| .__/ \__|_|_| |_| |_|_/___\___|_|
      |_|
'@
    Write-Host ""
    foreach ($line in ($art -split "`n")) { Write-Host ("  " + $line.TrimEnd()) -ForegroundColor Yellow }
    Write-Host "  PowerShell Edition   By: Firemax" -ForegroundColor DarkYellow
    $mode = if (Test-ODDryRun) { "DRY-RUN (no changes written)" } else { "LIVE" }
    $modeColor = if (Test-ODDryRun) { 'Cyan' } else { 'Green' }
    Write-Host "  Mode: " -NoNewline -ForegroundColor Gray; Write-Host $mode -ForegroundColor $modeColor
    Write-Host ("  " + ("-" * 62)) -ForegroundColor DarkGray
}

function Read-ODLine {
    param([string]$Prompt)
    Write-Host $Prompt -NoNewline -ForegroundColor White
    return (Read-Host)
}

function Confirm-ODAction {
    param([string]$Prompt)
    $ans = Read-ODLine "$Prompt [y/N]: "
    return ($ans -match '^(y|yes)$')
}

function Invoke-ODPause {
    Write-Host ""
    Read-ODLine "Press Enter to continue..." | Out-Null
}

# Parse selection text ("1,3,5-7" or "all") into a list of 1-based indices.
function Expand-ODSelection {
    param([string]$Text, [int]$Max)
    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }
    if ($Text.Trim() -match '^(all|\*)$') { return (1..$Max) }
    $result = New-Object System.Collections.Generic.List[int]
    foreach ($tok in ($Text -split ',')) {
        $t = $tok.Trim()
        if ($t -match '^(\d+)\s*-\s*(\d+)$') {
            $a = [int]$Matches[1]; $b = [int]$Matches[2]
            if ($a -gt $b) { $tmp = $a; $a = $b; $b = $tmp }
            for ($i = $a; $i -le $b; $i++) { if ($i -ge 1 -and $i -le $Max) { $result.Add($i) } }
        } elseif ($t -match '^\d+$') {
            $i = [int]$t; if ($i -ge 1 -and $i -le $Max) { $result.Add($i) }
        }
    }
    return ($result | Select-Object -Unique)
}

# Print an indented, word-wrapped dimmed description under a menu item.
function Write-ODItemDesc {
    param([string]$Desc, [string]$Indent = '        ', [int]$Width = 70)
    if ([string]::IsNullOrWhiteSpace($Desc)) { return }
    $line = ''
    foreach ($w in ($Desc -split '\s+')) {
        if (($line.Length + $w.Length + 1) -gt $Width) {
            Write-Host ($Indent + $line) -ForegroundColor DarkGray
            $line = $w
        } elseif ($line) { $line += ' ' + $w } else { $line = $w }
    }
    if ($line) { Write-Host ($Indent + $line) -ForegroundColor DarkGray }
}

# ------------------------------------------------------------------ Optimize

function Invoke-ODOptimizeMenu {
    while ($true) {
        $all = Get-ODOptimizations
        Show-ODBanner
        Write-ODTitle "  OPTIMIZATIONS"
        Write-Host "  Select numbers to APPLY (e.g. 1,4,7 or 2-6 or all). Unavailable items are dimmed." -ForegroundColor DarkGray
        Write-Host ""

        $indexMap = @{}
        $n = 0
        $lastCat = ''
        foreach ($o in $all) {
            if ($o.Category -ne $lastCat) {
                Write-Host ""
                Write-Host ("  == {0} ==" -f $o.Category) -ForegroundColor Cyan
                $lastCat = $o.Category
            }
            if (-not $o.Available) {
                Write-Host ("      --  {0}  ({1})" -f $o.Name, $o.Reason) -ForegroundColor DarkGray
                continue
            }
            $n++
            $indexMap[$n] = $o
            $mark = if ($o.Applied) { '[*]' } else { '[ ]' }
            $markColor = if ($o.Applied) { 'Green' } else { 'Gray' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host "$mark " -NoNewline -ForegroundColor $markColor
            Write-Host ("{0,-42}" -f $o.Name) -NoNewline -ForegroundColor White
            Write-Host (" {0}" -f $o.Risk) -ForegroundColor (Get-ODRiskColor $o.Risk)
            Write-ODItemDesc $o.Desc
        }
        Write-Host ""
        Write-Host "  [*] = already applied.  Enter numbers to apply, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }

        $picks = Expand-ODSelection -Text $sel -Max $n
        if (-not $picks) { Write-ODWarn "  Nothing selected."; Invoke-ODPause; continue }

        $chosen = @($picks | ForEach-Object { $indexMap[$_] })
        Invoke-ODApplyOptimizations -Chosen $chosen
    }
}

function Invoke-ODApplyOptimizations {
    param([object[]]$Chosen)
    Show-ODBanner
    Write-ODTitle "  REVIEW - the following will be applied:"
    Write-Host ""
    $risky = $false
    foreach ($o in $Chosen) {
        $flag = if ($o.Applied) { ' (already applied - will skip)' } else { '' }
        Write-Host ("   - {0,-44}" -f $o.Name) -NoNewline -ForegroundColor White
        Write-Host ("{0}" -f $o.Risk) -NoNewline -ForegroundColor (Get-ODRiskColor $o.Risk)
        Write-Host $flag -ForegroundColor DarkGray
        Write-ODItemDesc $o.Desc -Indent '       '
        if ($o.Risk -eq 'Risky') { $risky = $true }
    }
    Write-Host ""
    if ($risky) { Write-ODWarn "  WARNING: selection includes RISKY tweaks. Each is individually revertible." }
    if (Test-ODDryRun) { Write-Host "  (DRY-RUN: nothing will actually be written.)" -ForegroundColor Cyan }

    if (-not (Confirm-ODAction "  Proceed?")) { Write-ODInfo "  Cancelled."; Invoke-ODPause; return }

    Write-Host ""
    $applied = 0; $skipped = 0; $failed = 0
    foreach ($o in $Chosen) {
        if ($o.Applied -and -not (Test-ODDryRun)) {
            Write-ODInfo ("   skip  {0} (already applied)" -f $o.Name); $skipped++; continue
        }
        try {
            $r = Invoke-ODOperations -Id $o.Id -Name $o.Name -Operations $o.Operations
            if ($r.Success) {
                Write-ODOk ("   ok    {0}  ({1} change(s))" -f $o.Name, $r.ChangeCount); $applied++
            } else {
                Write-ODError ("   FAIL  {0}  ({1} error(s))" -f $o.Name, $r.Errors.Count); $failed++
            }
        } catch {
            Write-ODError ("   FAIL  {0}: {1}" -f $o.Name, $_.Exception.Message); $failed++
        }
    }
    Write-Host ""
    Write-Host ("  Done. Applied={0}  Skipped={1}  Failed={2}" -f $applied, $skipped, $failed) -ForegroundColor Cyan
    Write-Host "  (A restart or sign-out may be needed for some changes to take effect.)" -ForegroundColor DarkGray
    Invoke-ODPause
}

# ------------------------------------------------------------------ Customize

function Invoke-ODCustomizeMenu {
    while ($true) {
        $all = Get-ODSettings
        Show-ODBanner
        Write-ODTitle "  CUSTOMIZE SETTINGS"
        Write-Host "  Pick a setting number to change it. Unavailable items are dimmed." -ForegroundColor DarkGray
        Write-Host ""

        $indexMap = @{}
        $n = 0
        $lastCat = ''
        foreach ($s in $all) {
            if ($s.Category -ne $lastCat) {
                Write-Host ""
                Write-Host ("  == {0} ==" -f $s.Category) -ForegroundColor Cyan
                $lastCat = $s.Category
            }
            if (-not $s.Available) {
                Write-Host ("      --  {0}  ({1})" -f $s.Name, $s.Reason) -ForegroundColor DarkGray
                continue
            }
            $n++
            $indexMap[$n] = $s
            $mark = if ($s.Applied) { '[*]' } else { '[ ]' }
            $markColor = if ($s.Applied) { 'Green' } else { 'Gray' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host "$mark " -NoNewline -ForegroundColor $markColor
            Write-Host ("{0,-44}" -f $s.Name) -NoNewline -ForegroundColor White
            Write-Host (" [{0}]" -f $s.Kind) -ForegroundColor DarkGray
            Write-ODItemDesc $s.Desc
        }
        Write-Host ""
        Write-Host "  Enter a number to change it, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }
        if ($sel -notmatch '^\d+$') { continue }
        $i = [int]$sel
        if (-not $indexMap.ContainsKey($i)) { continue }
        Invoke-ODApplySetting -Setting $indexMap[$i]
    }
}

function Invoke-ODApplySetting {
    param($Setting)
    Show-ODBanner
    Write-ODTitle ("  SETTING: {0}  ({1})" -f $Setting.Name, $Setting.Category)
    if ($Setting.Desc) { Write-Host ("  {0}" -f $Setting.Desc) -ForegroundColor Gray }
    Write-Host ""

    $ops = $null; $label = $null
    if ($Setting.Kind -eq 'Toggle') {
        Write-Host "   1. On / Enable" -ForegroundColor Green
        Write-Host "   2. Off / Disable" -ForegroundColor Yellow
        Write-Host "   0. Back" -ForegroundColor DarkGray
        $c = Read-ODLine "  Choose: "
        switch ($c.Trim()) {
            '1' { $ops = $Setting.On;  $label = 'On' }
            '2' { $ops = $Setting.Off; $label = 'Off' }
            default { return }
        }
    } else {
        $n = 0; $map = @{}
        foreach ($ch in $Setting.Choices) { $n++; $map[$n] = $ch; Write-Host ("   {0}. {1}" -f $n, $ch.Label) -ForegroundColor White }
        Write-Host "   0. Back" -ForegroundColor DarkGray
        $c = Read-ODLine "  Choose: "
        if ($c.Trim() -notmatch '^\d+$' -or -not $map.ContainsKey([int]$c)) { return }
        $choice = $map[[int]$c]
        $ops = $choice.Ops; $label = $choice.Label
    }

    if (-not $ops) { return }
    if (Test-ODDryRun) { Write-Host "  (DRY-RUN: nothing will actually be written.)" -ForegroundColor Cyan }
    if (-not (Confirm-ODAction ("  Apply '{0}' = {1}?" -f $Setting.Name, $label))) { return }

    $skipSave = (Test-ODApplied -Id $Setting.Id)   # keep the original snapshot
    try {
        $r = Invoke-ODOperations -Id $Setting.Id -Name ("{0} = {1}" -f $Setting.Name, $label) -Operations $ops -SkipRevertSave:$skipSave
        if ($r.Success) { Write-ODOk ("  Applied ({0} change(s))." -f $r.ChangeCount) }
        else { Write-ODError ("  Completed with {0} error(s)." -f $r.Errors.Count) }
    } catch { Write-ODError ("  Failed: {0}" -f $_.Exception.Message) }
    Invoke-ODPause
}

# ------------------------------------------------------------------ Revert

function Invoke-ODRevertMenu {
    while ($true) {
        $entries = @(Get-ODRevertEntries | Sort-Object AppliedAt)
        Show-ODBanner
        Write-ODTitle "  REVERT APPLIED CHANGES"
        Write-Host ""
        if (-not $entries) { Write-ODInfo "  Nothing has been applied yet - nothing to revert."; Invoke-ODPause; return }

        $n = 0; $map = @{}
        foreach ($e in $entries) {
            $n++; $map[$n] = $e
            Write-Host ("   {0,3}. {1,-46} {2}" -f $n, $e.Name, $e.AppliedAt) -ForegroundColor White
        }
        Write-Host ""
        Write-Host "  Enter numbers to revert (e.g. 1,3), 'all' to revert everything, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }

        $picks = Expand-ODSelection -Text $sel -Max $n
        if (-not $picks) { continue }
        $targets = @($picks | ForEach-Object { $map[$_] })

        if (Test-ODDryRun) { Write-ODWarn "  (DRY-RUN is on - turn it off to actually revert.)" }
        if (-not (Confirm-ODAction ("  Revert {0} item(s)?" -f $targets.Count))) { continue }

        foreach ($t in $targets) {
            try {
                if (Test-ODDryRun) { Write-ODInfo ("   (dry-run) would revert {0}" -f $t.Name) }
                else { Invoke-ODRevert -Id $t.Id; Write-ODOk ("   reverted {0}" -f $t.Name) }
            } catch { Write-ODError ("   failed to revert {0}: {1}" -f $t.Name, $_.Exception.Message) }
        }
        Invoke-ODPause
    }
}

# ------------------------------------------------------------------ Search / All features

# Build a combined index of every available feature across all three domains.
function Get-ODFeatureIndex {
    $index = New-Object System.Collections.Generic.List[object]
    foreach ($o in (Get-ODOptimizations)) {
        if (-not $o.Available) { continue }
        $index.Add([pscustomobject]@{ Domain='OPT'; Cat=$o.Cat; Name=$o.Name; Desc=$o.Desc; Applied=$o.Applied; Obj=$o; Action=$null })
    }
    foreach ($s in (Get-ODSettings)) {
        if (-not $s.Available) { continue }
        $index.Add([pscustomobject]@{ Domain='SET'; Cat=$s.Cat; Name=$s.Name; Desc=$s.Desc; Applied=$s.Applied; Obj=$s; Action=$null })
    }
    foreach ($g in (Get-ODToolbox)) {
        foreach ($t in $g.Tasks) {
            $index.Add([pscustomobject]@{ Domain='TBX'; Cat=(Get-ODItemCategory -Id $t.Id); Name=$t.Title; Desc=$t.Desc; Applied=$false; Obj=$t; Action=$null })
        }
    }
    $tools = @(
        @{ Id='tool-dashboard';   Name='System Dashboard';      Desc='CPU, RAM, GPU, storage, uptime and active power plan at a glance.'; Act={ Show-ODDashboard } }
        @{ Id='tool-diskcleanup'; Name='Disk Cleanup';          Desc='Clear temp, Windows temp, Update cache, prefetch and the Recycle Bin.'; Act={ Invoke-ODDiskCleanup } }
        @{ Id='tool-bloatware';   Name='Bloatware Remover';      Desc='List and remove installed Store (AppX) apps.'; Act={ Invoke-ODBloatwareRemover } }
        @{ Id='tool-startup';     Name='Startup Manager';        Desc='See and toggle Run-key startup entries.'; Act={ Invoke-ODStartupManager } }
        @{ Id='tool-tasks';       Name='Scheduled Task Manager'; Desc='Browse, enable and disable Windows scheduled tasks.'; Act={ Invoke-ODTaskManager } }
    )
    foreach ($tool in $tools) {
        $index.Add([pscustomobject]@{ Domain='TOOL'; Cat=(Get-ODItemCategory -Id $tool.Id); Name=$tool.Name; Desc=$tool.Desc; Applied=$false; Obj=$null; Action=$tool.Act })
    }
    return $index
}

# One category: list its mixed items (tweaks, settings, tasks, tools) and act on the pick.
function Invoke-ODCategoryView {
    param([Parameter(Mandatory)][string]$Category)
    while ($true) {
        $items = @(Get-ODFeatureIndex | Where-Object { $_.Cat -eq $Category })
        Show-ODBanner
        Write-ODTitle ("  {0}" -f $Category)
        Write-Host "  [*]=applied   [OPT] tweak   [SET] setting   [TBX] task   [TOOL] tool" -ForegroundColor DarkGray
        Write-Host ""
        $n = 0; $map = @{}
        foreach ($m in $items) {
            $n++; $map[$n] = $m
            $tagColor = switch ($m.Domain) { 'OPT' {'Cyan'} 'SET' {'Magenta'} 'TBX' {'Yellow'} 'TOOL' {'Green'} default {'Gray'} }
            $applied = if ($m.Applied) { '*' } else { ' ' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host ("[{0}]{1} " -f $m.Domain, $applied) -NoNewline -ForegroundColor $tagColor
            Write-Host $m.Name -ForegroundColor White
            Write-ODItemDesc $m.Desc
        }
        Write-Host ""
        Write-Host "  Enter a number to open it, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }
        if ($sel -notmatch '^\d+$' -or -not $map.ContainsKey([int]$sel)) { continue }
        $pick = $map[[int]$sel]
        switch ($pick.Domain) {
            'OPT'  { Invoke-ODApplyOptimizations -Chosen @($pick.Obj) }
            'SET'  { Invoke-ODApplySetting -Setting $pick.Obj }
            'TBX'  { Invoke-ODToolboxTask -Task $pick.Obj }
            'TOOL' { & $pick.Action }
        }
    }
}

function Invoke-ODAllFeaturesMenu {
    while ($true) {
        Show-ODBanner
        Write-ODTitle "  SEARCH / ALL FEATURES"
        Write-Host "  Filters across Optimizations, Customize and Toolbox at once." -ForegroundColor DarkGray
        Write-Host "  Type a keyword, leave blank to list everything, or 0 to go back." -ForegroundColor DarkGray
        $kw = Read-ODLine "  Search: "
        if ($kw.Trim() -eq '0') { return }
        $term = $kw.Trim()

        $index = Get-ODFeatureIndex
        $results = if ([string]::IsNullOrWhiteSpace($term)) { $index } else {
            $index | Where-Object { "$($_.Name) $($_.Desc) $($_.Cat)" -match [regex]::Escape($term) }
        }
        $results = @($results)
        if (-not $results) { Write-ODWarn "  No matches for '$term'."; Invoke-ODPause; continue }

        Show-ODBanner
        $label = if ($term) { "RESULTS for '$term'" } else { "ALL FEATURES" }
        Write-ODTitle ("  {0}  ({1} match(es))" -f $label, $results.Count)
        Write-Host ""
        $n = 0; $map = @{}
        foreach ($m in ($results | Select-Object -First 60)) {
            $n++; $map[$n] = $m
            $tagColor = switch ($m.Domain) { 'OPT' {'Cyan'} 'SET' {'Magenta'} 'TBX' {'Yellow'} default {'Gray'} }
            $applied = if ($m.Applied) { '*' } else { ' ' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host ("[{0}]{1} " -f $m.Domain, $applied) -NoNewline -ForegroundColor $tagColor
            Write-Host ("{0,-40}" -f $m.Name) -NoNewline -ForegroundColor White
            Write-Host (" {0}" -f $m.Cat) -ForegroundColor DarkGray
            Write-ODItemDesc $m.Desc
        }
        if ($results.Count -gt 60) { Write-Host ("  ... and {0} more - refine your search." -f ($results.Count - 60)) -ForegroundColor DarkGray }
        Write-Host ""
        Write-Host "  [OPT] optimization   [SET] setting   [TBX] toolbox   (* = applied). Enter a number, or 0 to search again." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { continue }
        if ($sel -notmatch '^\d+$' -or -not $map.ContainsKey([int]$sel)) { continue }
        $pick = $map[[int]$sel]
        switch ($pick.Domain) {
            'OPT'  { Invoke-ODApplyOptimizations -Chosen @($pick.Obj) }
            'SET'  { Invoke-ODApplySetting -Setting $pick.Obj }
            'TBX'  { Invoke-ODToolboxTask -Task $pick.Obj }
            'TOOL' { & $pick.Action }
        }
    }
}

# ------------------------------------------------------------------ Unified categories

# Build the single ordered list of all 25 categories across optimizations,
# customize settings and repair/maintenance tasks.
function Get-ODUnifiedCategories {
    $cats = New-Object System.Collections.Generic.List[object]
    $opts = Get-ODOptimizations
    $seen = New-Object System.Collections.Generic.List[string]
    foreach ($o in $opts) {
        if (-not $seen.Contains($o.Category)) {
            $seen.Add($o.Category) | Out-Null
            $cats.Add([pscustomobject]@{ Section='OPTIMIZE'; Name=$o.Category; Kind='opt'; Count=@($opts | Where-Object { $_.Category -eq $o.Category }).Count; Group=$null })
        }
    }
    $sets = Get-ODSettings
    $seen2 = New-Object System.Collections.Generic.List[string]
    foreach ($s in $sets) {
        if (-not $seen2.Contains($s.Category)) {
            $seen2.Add($s.Category) | Out-Null
            $cats.Add([pscustomobject]@{ Section='CUSTOMIZE'; Name=$s.Category; Kind='set'; Count=@($sets | Where-Object { $_.Category -eq $s.Category }).Count; Group=$null })
        }
    }
    foreach ($g in (Get-ODToolbox)) {
        $cats.Add([pscustomobject]@{ Section='REPAIR & TOOLS'; Name=$g.Name; Kind='task'; Count=$g.Tasks.Count; Group=$g })
    }
    return $cats
}

# One optimization category: multi-select apply.
function Invoke-ODOptCategory {
    param([Parameter(Mandatory)][string]$Category)
    while ($true) {
        $all = @(Get-ODOptimizations | Where-Object { $_.Category -eq $Category -and $_.Available })
        Show-ODBanner
        Write-ODTitle ("  {0}" -f $Category)
        Write-Host "  Select numbers to APPLY (e.g. 1,3 or all). [*] = already applied." -ForegroundColor DarkGray
        Write-Host ""
        $n = 0; $map = @{}
        foreach ($o in $all) {
            $n++; $map[$n] = $o
            $mark = if ($o.Applied) { '[*]' } else { '[ ]' }
            $mc = if ($o.Applied) { 'Green' } else { 'Gray' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host "$mark " -NoNewline -ForegroundColor $mc
            Write-Host ("{0,-42}" -f $o.Name) -NoNewline -ForegroundColor White
            Write-Host (" {0}" -f $o.Risk) -ForegroundColor (Get-ODRiskColor $o.Risk)
            Write-ODItemDesc $o.Desc
        }
        Write-Host ""
        Write-Host "  Enter numbers to apply, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }
        $picks = Expand-ODSelection -Text $sel -Max $n
        if (-not $picks) { continue }
        Invoke-ODApplyOptimizations -Chosen @($picks | ForEach-Object { $map[$_] })
    }
}

# One customize category: pick a setting and change it.
function Invoke-ODSetCategory {
    param([Parameter(Mandatory)][string]$Category)
    while ($true) {
        $all = @(Get-ODSettings | Where-Object { $_.Category -eq $Category -and $_.Available })
        Show-ODBanner
        Write-ODTitle ("  {0}" -f $Category)
        Write-Host "  Pick a setting number to change it. [*] = changed from default." -ForegroundColor DarkGray
        Write-Host ""
        $n = 0; $map = @{}
        foreach ($s in $all) {
            $n++; $map[$n] = $s
            $mark = if ($s.Applied) { '[*]' } else { '[ ]' }
            $mc = if ($s.Applied) { 'Green' } else { 'Gray' }
            Write-Host ("   {0,3}. " -f $n) -NoNewline -ForegroundColor White
            Write-Host "$mark " -NoNewline -ForegroundColor $mc
            Write-Host ("{0,-44}" -f $s.Name) -NoNewline -ForegroundColor White
            Write-Host (" [{0}]" -f $s.Kind) -ForegroundColor DarkGray
            Write-ODItemDesc $s.Desc
        }
        Write-Host ""
        Write-Host "  Enter a number to change it, or 0 to go back." -ForegroundColor DarkGray
        $sel = Read-ODLine "  Selection: "
        if ($sel.Trim() -eq '0' -or [string]::IsNullOrWhiteSpace($sel)) { return }
        if ($sel -notmatch '^\d+$' -or -not $map.ContainsKey([int]$sel)) { continue }
        Invoke-ODApplySetting -Setting $map[[int]$sel]
    }
}

Export-ModuleMember -Function *
