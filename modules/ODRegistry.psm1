<#
    ODRegistry.psm1 - Registry read/write/delete via the .NET API, with
    prior-state capture so every change can be reverted.
    Part of WindowsOptimizer (GPLv3, port of optimizerDuck (C) itsfatduck).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Map a textual registry path (HKLM\..., HKEY_CURRENT_USER\..., HKU\.DEFAULT\...)
# to a .NET RegistryHive + subkey path.
function ConvertFrom-ODRegPath {
    param([Parameter(Mandatory)][string]$Path)

    $p = $Path -replace '^Registry::', ''
    $hive = $null; $sub = $null

    if     ($p -match '^(HKLM|HKEY_LOCAL_MACHINE)\\(.*)$') { $hive = 'LocalMachine'; $sub = $Matches[2] }
    elseif ($p -match '^(HKCU|HKEY_CURRENT_USER)\\(.*)$')  { $hive = 'CurrentUser';  $sub = $Matches[2] }
    elseif ($p -match '^(HKCR|HKEY_CLASSES_ROOT)\\(.*)$')  { $hive = 'ClassesRoot';  $sub = $Matches[2] }
    elseif ($p -match '^(HKU|HKEY_USERS)\\(.*)$')          { $hive = 'Users';        $sub = $Matches[2] }
    elseif ($p -match '^(HKCC|HKEY_CURRENT_CONFIG)\\(.*)$'){ $hive = 'CurrentConfig';$sub = $Matches[2] }
    else { throw "Unrecognized registry hive in path: $Path" }

    return [pscustomobject]@{ Hive = $hive; SubKey = $sub }
}

function Get-ODRegBaseKey {
    param([string]$Hive, [bool]$Writable)
    $h = [Microsoft.Win32.RegistryHive]::$Hive
    $view = [Microsoft.Win32.RegistryView]::Default
    return [Microsoft.Win32.RegistryKey]::OpenBaseKey($h, $view)
}

# Returns @{ Exists=$bool; Value=...; Kind='DWord'|... } for a value (or key-default when Name is $null/'').
function Get-ODRegistryValue {
    param([Parameter(Mandatory)][string]$Path, [string]$Name)
    $info = ConvertFrom-ODRegPath $Path
    $base = Get-ODRegBaseKey -Hive $info.Hive -Writable $false
    try {
        $key = $base.OpenSubKey($info.SubKey, $false)
        if ($null -eq $key) { return @{ Exists = $false; Value = $null; Kind = $null } }
        try {
            $vn = if ([string]::IsNullOrEmpty($Name)) { '' } else { $Name }
            $names = $key.GetValueNames()
            $present = $false
            foreach ($n in $names) { if ($n -ceq $vn) { $present = $true; break } }
            if (-not $present) { return @{ Exists = $false; Value = $null; Kind = $null } }
            $val  = $key.GetValue($vn, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            $kind = $key.GetValueKind($vn).ToString()
            return @{ Exists = $true; Value = $val; Kind = $kind }
        } finally { $key.Dispose() }
    } finally { $base.Dispose() }
}

function Test-ODRegistryKey {
    param([Parameter(Mandatory)][string]$Path)
    $info = ConvertFrom-ODRegPath $Path
    $base = Get-ODRegBaseKey -Hive $info.Hive -Writable $false
    try {
        $key = $base.OpenSubKey($info.SubKey, $false)
        if ($null -eq $key) { return $false }
        $key.Dispose(); return $true
    } finally { $base.Dispose() }
}

# Convert a value + kind string into the object .NET SetValue expects.
function ConvertTo-ODRegNativeValue {
    param($Value, [string]$Kind)
    switch ($Kind) {
        'DWord' {
            # Accept full unsigned 32-bit range (e.g. 0xFFFFFFFF) and marshal to Int32.
            $u = [uint32]([int64]$Value -band 0xFFFFFFFF)
            $bytes = [System.BitConverter]::GetBytes($u)
            return ,([System.BitConverter]::ToInt32($bytes, 0))
        }
        'QWord'        { return [int64]$Value }
        'String'       { return [string]$Value }
        'ExpandString' { return [string]$Value }
        'MultiString'  { return [string[]]$Value }
        'Binary'       { return [byte[]]$Value }
        default        { return $Value }
    }
}

# Write a value. Returns a revert descriptor hashtable.
function Set-ODRegistryValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Name,
        [Parameter(Mandatory)]$Value,
        [string]$Kind = 'DWord'
    )

    # Capture prior state for revert.
    $prior = Get-ODRegistryValue -Path $Path -Name $Name
    $revert = @{
        Kind        = 'Reg'
        Path        = $Path
        Name        = $Name
        PriorExists = [bool]$prior.Exists
        PriorValue  = $prior.Value
        PriorKind   = $prior.Kind
    }

    if (Test-ODDryRun) { return $revert }

    $info = ConvertFrom-ODRegPath $Path
    $base = Get-ODRegBaseKey -Hive $info.Hive -Writable $true
    try {
        $key = $base.CreateSubKey($info.SubKey)
        if ($null -eq $key) { throw "Failed to create/open key: $Path" }
        try {
            $vn = if ([string]::IsNullOrEmpty($Name)) { '' } else { $Name }
            $native = ConvertTo-ODRegNativeValue -Value $Value -Kind $Kind
            $key.SetValue($vn, $native, [Microsoft.Win32.RegistryValueKind]::$Kind)
        } finally { $key.Dispose() }
    } finally { $base.Dispose() }

    return $revert
}

# Delete a single value. Returns a revert descriptor.
function Remove-ODRegistryValue {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name)

    $prior = Get-ODRegistryValue -Path $Path -Name $Name
    $revert = @{
        Kind        = 'Reg'
        Path        = $Path
        Name        = $Name
        PriorExists = [bool]$prior.Exists
        PriorValue  = $prior.Value
        PriorKind   = $prior.Kind
    }

    if (Test-ODDryRun) { return $revert }
    if (-not $prior.Exists) { return $revert }

    $info = ConvertFrom-ODRegPath $Path
    $base = Get-ODRegBaseKey -Hive $info.Hive -Writable $true
    try {
        $key = $base.OpenSubKey($info.SubKey, $true)
        if ($null -ne $key) {
            try { $key.DeleteValue($Name, $false) } finally { $key.Dispose() }
        }
    } finally { $base.Dispose() }

    return $revert
}

# Delete a whole subkey tree. Returns a revert descriptor that records the
# former existence (we cannot safely recreate arbitrary subtrees, so revert
# only notes it existed; a specific tweak may recreate the key on revert).
function Remove-ODRegistryKeyTree {
    param([Parameter(Mandatory)][string]$Path)

    $existed = Test-ODRegistryKey -Path $Path
    $revert = @{ Kind = 'RegKeyTree'; Path = $Path; PriorExisted = [bool]$existed }

    if (Test-ODDryRun) { return $revert }
    if (-not $existed) { return $revert }

    $info = ConvertFrom-ODRegPath $Path
    $base = Get-ODRegBaseKey -Hive $info.Hive -Writable $true
    try { $base.DeleteSubKeyTree($info.SubKey, $false) } finally { $base.Dispose() }
    return $revert
}

Export-ModuleMember -Function *
