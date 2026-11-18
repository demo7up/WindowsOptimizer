<#
    ODData.psm1 - Load the declarative optimization/customize definitions and
    enrich each with a stable id, condition availability and applied-state.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ODSlug {
    param([string]$Text)
    return (($Text -replace '[^A-Za-z0-9]+', '-').Trim('-').ToLower())
}

# --- New-taxonomy category map (data/categories.psd1) -----------------------
$script:ODCatData = $null
function Get-ODCategoryData {
    if ($null -eq $script:ODCatData) {
        $script:ODCatData = Import-PowerShellDataFile -Path (Join-Path (Get-ODDataDir) 'categories.psd1')
    }
    return $script:ODCatData
}
function Get-ODCategoryOrder { return (Get-ODCategoryData).Order }
function Get-ODItemCategory {
    param([string]$Id)
    $m = (Get-ODCategoryData).Map
    if ($m.ContainsKey($Id)) { return $m[$Id] }
    return 'System Repair'
}

function Get-ODOptimizations {
    $data = Import-PowerShellDataFile -Path (Join-Path (Get-ODDataDir) 'optimizations.psd1')
    $list = @()
    foreach ($o in $data.Optimizations) {
        $id = 'opt-' + (Get-ODSlug "$($o.Category)-$($o.Name)")
        $cond = Test-ODCondition -Condition $o.Condition
        $list += [pscustomobject]@{
            Id         = $id
            Category   = $o.Category
            Cat        = (Get-ODItemCategory -Id $id)
            Name       = $o.Name
            Risk       = $o.Risk
            Desc       = $o.Desc
            Condition  = $o.Condition
            Operations = $o.Operations
            Available  = $cond.Available
            Reason     = $cond.Reason
            Applied    = (Test-ODApplied -Id $id)
        }
    }
    return $list
}

function Get-ODToolbox {
    $data = Import-PowerShellDataFile -Path (Join-Path (Get-ODDataDir) 'toolbox.psd1')
    return $data.Groups
}

function Get-ODSettings {
    $data = Import-PowerShellDataFile -Path (Join-Path (Get-ODDataDir) 'customize.psd1')
    $list = @()
    foreach ($s in $data.Settings) {
        $id = 'set-' + (Get-ODSlug "$($s.Category)-$($s.Name)")
        $cond = Test-ODCondition -Condition $s.Condition
        $obj = [pscustomobject]@{
            Id        = $id
            Category  = $s.Category
            Cat       = (Get-ODItemCategory -Id $id)
            Name      = $s.Name
            Kind      = $s.Kind
            Desc      = if ($s.ContainsKey('Desc')) { $s.Desc } else { '' }
            Condition = $s.Condition
            Available = $cond.Available
            Reason    = $cond.Reason
            Applied   = (Test-ODApplied -Id $id)
            On        = if ($s.ContainsKey('On'))  { $s.On }  else { $null }
            Off       = if ($s.ContainsKey('Off')) { $s.Off } else { $null }
            Choices   = if ($s.ContainsKey('Choices')) { $s.Choices } else { $null }
        }
        $list += $obj
    }
    return $list
}

Export-ModuleMember -Function *
