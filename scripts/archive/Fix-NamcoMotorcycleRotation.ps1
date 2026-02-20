<#
.SYNOPSIS
    Fix Namco motorcycle MAME entries: 45→60 degrees + update Screamer (v2.14.0)
.DESCRIPTION
    Part A: Correct 7 Namco motorcycle MAME entries from 45 to 60 degrees.
    The Namco motorcycle handlebar potentiometer is VG75-03824-00 (1K ohm, 60-degree),
    confirmed by SuzoHapp parts catalog and Cybercycles handle assembly.
    The original 45-degree value was an inference that predated the parts discovery.

    Part B: Update Screamer (2026) from ws=unknown to ws=none based on twin-stick
    architecture that is fundamentally incompatible with steering wheels.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dbPath = Join-Path $PSScriptRoot '..\..\data\wheel-db.json'
$db = Get-Content $dbPath -Raw | ConvertFrom-Json

$rotFixed = 0
$otherFixed = 0

# ============================================================
# PART A: Namco motorcycle 45→60 correction
# ============================================================
Write-Host "`n=== PART A: Namco motorcycle rotation 45→60 ==="

$namcoMotorcycles = @(
    '500_gp',
    'cyber_cycles_rev_cb2_verc_world',
    'downhill_bikers',
    'moto_gp_mgp1004nab',
    'motocross_go',
    'suzuka_8_hours',
    'suzuka_8_hours_2'
)

foreach ($slug in $namcoMotorcycles) {
    $game = $db.games.$slug
    if (-not $game) { Write-Host "  SKIP: $slug not found"; continue }
    if ($game.rotation_degrees -ne 45) { Write-Host "  SKIP: $slug rotation is $($game.rotation_degrees), not 45"; continue }

    $game.rotation_degrees = 60

    # Replace the old ~45-degree reference sources with the correct 60-degree parts source
    $newSources = @()
    foreach ($src in $game.sources) {
        if ($src.description -match '~45-degree') {
            # Skip old inaccurate sources
        } else {
            $newSources += $src
        }
    }
    $newSources += [PSCustomObject]@{
        type = 'parts'
        description = 'Namco motorcycle handlebar potentiometer VG75-03824-00 (1K ohm, 60-degree rotation). Confirmed in Cybercycles (System 22) handle and pivot assembly. Standard across Namco motorcycle/body-lean cabinets.'
        url = 'https://na.suzohapp.com/products/driving_controls/VG75-03824-00'
        date_accessed = '2026-02-20'
    }
    $game.sources = $newSources

    $rotFixed++
    Write-Host "  FIXED: $slug ($($game.title)) 45→60 degrees"
}

# ============================================================
# PART B: Screamer (2026) twin-stick → ws=none
# ============================================================
Write-Host "`n=== PART B: Screamer twin-stick correction ==="

$game = $db.games.screamer_2026
if ($game) {
    $game.pc.wheel_support = 'none'
    $game.pc.force_feedback = 'none'
    $game.rotation_degrees = $null
    $game.confidence = 'high'
    $game.notes = 'Twin-stick arcade racer. Steer with left stick, drift with right stick. Multi-axis control fundamentally incompatible with single-axis steering wheel. Unreleased (March 2026).'
    $game.sources = @(
        [PSCustomObject]@{
            type = 'developer'
            description = 'Milestone official page and multiple preview articles describe Twin Stick control system: "Steer with the left stick, drift with the right, and blend both for smooth turns or aggressive slides." XInput and PlayStation controllers confirmed, including DualSense Adaptive Triggers.'
            url = 'https://milestone.it/games/screamer/'
            date_accessed = '2026-02-20'
        },
        [PSCustomObject]@{
            type = 'research'
            description = 'RacingGames.gg, Game Informer, The Gamer, PowerUp! previews all discuss twin-stick system with no mention of wheel support. Screamer Wiki notes partial support for USB controllers but no wheel mention. Community member noted game "misses the wheel support."'
            url = 'https://racinggames.gg/article/screamer-preview-hands-on-impressions'
            date_accessed = '2026-02-20'
        }
    )
    $otherFixed++
    Write-Host "  FIXED: screamer_2026 → ws=none, ffb=none, rotation=null, confidence=high (twin-stick architecture)"
}

# ============================================================
# Summary & Save
# ============================================================
Write-Host "`n=== SUMMARY ==="
Write-Host "Namco motorcycle rotation fixes: $rotFixed"
Write-Host "Other corrections: $otherFixed"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding utf8
Write-Host "Database saved."
