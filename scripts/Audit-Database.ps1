<#
.SYNOPSIS
    Comprehensive data quality audit for wheel-db.json.

.DESCRIPTION
    Read-only diagnostic script that identifies quality gaps, logical inconsistencies,
    and completeness issues. Does NOT modify the database.

    Checks:
    1. rotation_type gaps (entries with "unknown" type)
    2. Cross-field consistency (arcade vs PC field expectations)
    3. Completeness gaps (missing PCGW URLs, years, notes, unknown ws/ffb)
    4. Single-source entries (weakest evidence)
    5. Summary statistics

.PARAMETER DatabasePath
    Path to wheel-db.json
#>
param(
    [string]$DatabasePath = "$PSScriptRoot\..\data\wheel-db.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== Wheel Database Quality Audit ===" -ForegroundColor Cyan

$db = Get-Content -Raw $DatabasePath | ConvertFrom-Json
$gameProps = @($db.games.PSObject.Properties)
$gameCount = $gameProps.Count

Write-Host "  Version: $($db.version) | Total games: $gameCount"
Write-Host ""

$arcadePlatforms = @('mame', 'teknoparrot', 'supermodel', 'm2emulator', 'flycast', 'dolphin')

# Helper: check if entry has any arcade platform
function Test-HasArcadePlatform($game) {
    foreach ($ap in $arcadePlatforms) {
        if ($game.platforms.PSObject.Properties[$ap]) { return $true }
    }
    return $false
}

# ============================================================
# Audit 1: rotation_type gaps
# ============================================================
Write-Host "[Audit 1] rotation_type gaps..." -ForegroundColor Yellow
$rtUnknown = @{}
$rtNull = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    $hasArcade = Test-HasArcadePlatform $g
    if ($g.PSObject.Properties['rotation_type']) {
        if ($g.rotation_type -eq 'unknown') {
            $mfr = if ($g.manufacturer) { $g.manufacturer } else { '(null)' }
            $key = "$mfr|$($g.rotation_degrees)"
            if (-not $rtUnknown.ContainsKey($key)) { $rtUnknown[$key] = @() }
            $rtUnknown[$key] += $prop.Name
        }
    } elseif ($hasArcade) {
        $rtNull += $prop.Name
    }
}

$totalRtUnknown = ($rtUnknown.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
if ($totalRtUnknown -gt 0) {
    Write-Host "  rotation_type = 'unknown': $totalRtUnknown entries" -ForegroundColor Red
    foreach ($key in ($rtUnknown.Keys | Sort-Object)) {
        $parts = $key -split '\|'
        $slugs = $rtUnknown[$key]
        $preview = if ($slugs.Count -le 3) { $slugs -join ', ' } else { ($slugs[0..2] -join ', ') + ', ...' }
        Write-Host "    $($parts[0]) @ $($parts[1])deg ($($slugs.Count)): $preview" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  No rotation_type = 'unknown' entries" -ForegroundColor Green
}

if ($rtNull.Count -gt 0) {
    Write-Host "  Arcade entries with null rotation_type: $($rtNull.Count)" -ForegroundColor DarkYellow
}
Write-Host ""

# ============================================================
# Audit 2: Cross-field consistency
# ============================================================
Write-Host "[Audit 2] Cross-field consistency..." -ForegroundColor Yellow
$issues = 0

# 2a: rotation_degrees = -1 but rotation_type != optical_encoder
$badEncoder = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if ($g.rotation_degrees -eq -1 -and $g.PSObject.Properties['rotation_type'] -and $g.rotation_type -ne 'optical_encoder') {
        $badEncoder += "$($prop.Name) (type=$($g.rotation_type))"
    }
}
if ($badEncoder.Count -gt 0) {
    Write-Host "  rotation=-1 but type != optical_encoder: $($badEncoder.Count)" -ForegroundColor Red
    foreach ($e in $badEncoder) { Write-Host "    $e" -ForegroundColor DarkYellow }
    $issues += $badEncoder.Count
}

# 2b: Steam entries without pc sub-object
$steamNoPc = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if ($g.platforms.PSObject.Properties['steam'] -and (-not $g.PSObject.Properties['pc'] -or $null -eq $g.pc)) {
        $steamNoPc += $prop.Name
    }
}
if ($steamNoPc.Count -gt 0) {
    Write-Host "  Steam entries without pc sub-object: $($steamNoPc.Count)" -ForegroundColor Red
    foreach ($e in $steamNoPc) { Write-Host "    $e" -ForegroundColor DarkYellow }
    $issues += $steamNoPc.Count
}

# 2c: pc sub-object but no Steam platform
$pcNoSteam = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if ($g.PSObject.Properties['pc'] -and $null -ne $g.pc -and -not $g.platforms.PSObject.Properties['steam']) {
        $pcNoSteam += $prop.Name
    }
}
if ($pcNoSteam.Count -gt 0) {
    Write-Host "  pc metadata but no Steam platform: $($pcNoSteam.Count)" -ForegroundColor DarkYellow
    foreach ($e in $pcNoSteam) { Write-Host "    $e" -ForegroundColor DarkYellow }
    $issues += $pcNoSteam.Count
}

# 2d: PC-only entries with rotation_type set (should be null)
$pcOnlyWithRt = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    $hasArcade = Test-HasArcadePlatform $g
    if (-not $hasArcade -and $g.PSObject.Properties['rotation_type'] -and $null -ne $g.rotation_type) {
        $pcOnlyWithRt += "$($prop.Name) (type=$($g.rotation_type))"
    }
}
if ($pcOnlyWithRt.Count -gt 0) {
    Write-Host "  PC-only entries with rotation_type set: $($pcOnlyWithRt.Count)" -ForegroundColor DarkYellow
    foreach ($e in $pcOnlyWithRt[0..4]) { Write-Host "    $e" -ForegroundColor DarkYellow }
    if ($pcOnlyWithRt.Count -gt 5) { Write-Host "    ... and $($pcOnlyWithRt.Count - 5) more" -ForegroundColor DarkYellow }
    $issues += $pcOnlyWithRt.Count
}

if ($issues -eq 0) {
    Write-Host "  No cross-field consistency issues" -ForegroundColor Green
}
Write-Host ""

# ============================================================
# Audit 3: Completeness gaps
# ============================================================
Write-Host "[Audit 3] Completeness gaps..." -ForegroundColor Yellow

# 3a: Steam entries missing PCGamingWiki URL
$missingPcgw = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if ($g.platforms.PSObject.Properties['steam']) {
        $steam = $g.platforms.steam
        if (-not $steam.PSObject.Properties['pcgamingwiki_url'] -or [string]::IsNullOrWhiteSpace($steam.pcgamingwiki_url)) {
            $missingPcgw += "$($prop.Name) ($($g.title))"
        }
    }
}
$steamCount = ($gameProps | Where-Object { $_.Value.platforms.PSObject.Properties['steam'] }).Count
$pcgwPct = [math]::Round(($steamCount - $missingPcgw.Count) / $steamCount * 100, 1)
if ($missingPcgw.Count -gt 0) {
    Write-Host "  Missing PCGamingWiki URL: $($missingPcgw.Count) of $steamCount Steam entries ($pcgwPct% coverage)" -ForegroundColor DarkYellow
    foreach ($e in $missingPcgw) { Write-Host "    $e" -ForegroundColor DarkYellow }
} else {
    Write-Host "  PCGamingWiki URLs: 100% coverage ($steamCount entries)" -ForegroundColor Green
}

# 3b: Empty/missing year
$missingYear = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if (-not $g.PSObject.Properties['year'] -or [string]::IsNullOrWhiteSpace($g.year)) {
        $missingYear += $prop.Name
    }
}
if ($missingYear.Count -gt 0) {
    Write-Host "  Missing year: $($missingYear.Count) entries" -ForegroundColor DarkYellow
    foreach ($e in $missingYear) { Write-Host "    $e" -ForegroundColor DarkYellow }
} else {
    Write-Host "  Year: 100% coverage" -ForegroundColor Green
}

# 3c: Empty/missing notes
$missingNotes = 0
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if (-not $g.PSObject.Properties['notes'] -or $null -eq $g.notes -or $g.notes -eq '') {
        $missingNotes++
    }
}
$notesPct = [math]::Round(($gameCount - $missingNotes) / $gameCount * 100, 1)
Write-Host "  Missing notes: $missingNotes entries ($notesPct% have notes)" -ForegroundColor $(if ($missingNotes -gt 0) { 'DarkYellow' } else { 'Green' })

# 3d: Unknown wheel_support / force_feedback
$unknownWs = @()
$unknownFfb = @()
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if ($g.PSObject.Properties['pc'] -and $null -ne $g.pc) {
        if ($g.pc.wheel_support -eq 'unknown') { $unknownWs += "$($prop.Name) ($($g.title))" }
        if ($g.pc.force_feedback -eq 'unknown') { $unknownFfb += "$($prop.Name) ($($g.title))" }
    }
}
if ($unknownWs.Count -gt 0) {
    Write-Host "  Unknown wheel_support: $($unknownWs.Count)" -ForegroundColor DarkYellow
    foreach ($e in $unknownWs) { Write-Host "    $e" -ForegroundColor DarkYellow }
}
if ($unknownFfb.Count -gt 0) {
    Write-Host "  Unknown force_feedback: $($unknownFfb.Count)" -ForegroundColor DarkYellow
    foreach ($e in $unknownFfb) { Write-Host "    $e" -ForegroundColor DarkYellow }
}
if ($unknownWs.Count -eq 0 -and $unknownFfb.Count -eq 0) {
    Write-Host "  PC metadata: no unknowns" -ForegroundColor Green
}

# 3e: Null rotation_degrees (unknown rotation)
$nullRotation = 0
foreach ($prop in $gameProps) {
    if ($null -eq $prop.Value.rotation_degrees) { $nullRotation++ }
}
Write-Host "  Null rotation_degrees: $nullRotation entries" -ForegroundColor $(if ($nullRotation -gt 0) { 'DarkYellow' } else { 'Green' })
Write-Host ""

# ============================================================
# Audit 4: Single-source entries
# ============================================================
Write-Host "[Audit 4] Source coverage..." -ForegroundColor Yellow
$singleSource = 0
$twoSources = 0
$threePlus = 0
foreach ($prop in $gameProps) {
    $srcCount = @($prop.Value.sources).Count
    if ($srcCount -eq 1) { $singleSource++ }
    elseif ($srcCount -eq 2) { $twoSources++ }
    else { $threePlus++ }
}
Write-Host "  1 source: $singleSource entries ($([math]::Round($singleSource/$gameCount*100,1))%)" -ForegroundColor $(if ($singleSource -gt 100) { 'DarkYellow' } else { 'White' })
Write-Host "  2 sources: $twoSources entries ($([math]::Round($twoSources/$gameCount*100,1))%)" -ForegroundColor White
Write-Host "  3+ sources: $threePlus entries ($([math]::Round($threePlus/$gameCount*100,1))%)" -ForegroundColor White
Write-Host ""

# ============================================================
# Audit 5: Summary statistics
# ============================================================
Write-Host "[Audit 5] Summary statistics..." -ForegroundColor Yellow

# Confidence distribution
$confDist = @{}
foreach ($prop in $gameProps) {
    $c = $prop.Value.confidence
    if (-not $confDist.ContainsKey($c)) { $confDist[$c] = 0 }
    $confDist[$c]++
}
Write-Host "  Confidence: $(($confDist.GetEnumerator() | Sort-Object { switch ($_.Key) { 'verified' {0} 'high' {1} 'medium' {2} 'low' {3} default {4} } } | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')"

# rotation_type distribution (arcade only)
$rtDist = @{ 'mechanical_stop' = 0; 'potentiometer' = 0; 'optical_encoder' = 0; 'unknown' = 0; 'null' = 0 }
foreach ($prop in $gameProps) {
    $g = $prop.Value
    if ($g.PSObject.Properties['rotation_type']) {
        if ($null -eq $g.rotation_type) { $rtDist['null']++ }
        else { $rtDist[$g.rotation_type]++ }
    } else {
        $rtDist['null']++
    }
}
Write-Host "  rotation_type: $(($rtDist.GetEnumerator() | Where-Object { $_.Value -gt 0 } | Sort-Object { -$_.Value } | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')"

# Platform coverage
$platCounts = @{}
foreach ($prop in $gameProps) {
    foreach ($p in $prop.Value.platforms.PSObject.Properties.Name) {
        if (-not $platCounts.ContainsKey($p)) { $platCounts[$p] = 0 }
        $platCounts[$p]++
    }
}
Write-Host "  Platforms: $(($platCounts.GetEnumerator() | Sort-Object { -$_.Value } | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')"

Write-Host ""
Write-Host "=== Audit Complete ===" -ForegroundColor Cyan
