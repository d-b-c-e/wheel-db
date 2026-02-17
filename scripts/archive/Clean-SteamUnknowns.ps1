Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$removedCount = 0
$setCount = 0

# =============================================================================
# PHASE 1: Remove motorcycle games (no wheel support, handlebar/lean controls)
# =============================================================================
Write-Host "=== Phase 1: Remove motorcycle games ==="

$motorcycleGames = @(
    'mx_bikes', 'ride_4', 'ride', 'ride_3', 'ride_2',
    'mxgp_the_official_motocross_videogame', 'mxgp_pro', 'mxgp3',
    'motogp_20', 'tt_isle_of_man_ride_on_the_edge', 'tt_isle_of_man_ride_on_the_edge_2',
    'moto_racer_4', 'mx_vs_atv_all_out', 'mx_vs_atv_reflex',
    'road_redemption', 'trials_rising', 'trials_evolution_gold_edition', 'trials_fusion'
)

$motorcycleGames | ForEach-Object {
    if ($db.games.PSObject.Properties[$_]) {
        $title = $db.games.$_.title
        $db.games.PSObject.Properties.Remove($_)
        Write-Host "  Removed: $_ ($title)"
        $script:removedCount++
    }
}

# =============================================================================
# PHASE 2: Remove open world / vehicular combat (not racing-focused)
# =============================================================================
Write-Host ""
Write-Host "=== Phase 2: Remove open world / vehicular combat ==="

$openWorldGames = @(
    'sleeping_dogs_definitive_edition', 'sleeping_dogs',
    'grand_theft_auto_iii', 'crossout'
)

$openWorldGames | ForEach-Object {
    if ($db.games.PSObject.Properties[$_]) {
        $title = $db.games.$_.title
        $db.games.PSObject.Properties.Remove($_)
        Write-Host "  Removed: $_ ($title)"
        $script:removedCount++
    }
}

# =============================================================================
# PHASE 3: Remove other non-wheel games
# =============================================================================
Write-Host ""
Write-Host "=== Phase 3: Remove other non-wheel games ==="

$otherRemove = @(
    @('jet_racing_extreme', 'jet boat racing, no wheel support'),
    @('racing_classics_drag_race_simulator', 'drag racing, no steering involved'),
    @('cube_racer', 'novelty cube game, no wheel support'),
    @('crashmetal_cyberpunk', 'low-quality vehicular combat, ws=none'),
    @('madout2_bigcityonline', 'open world driving, ws=none'),
    @('ocean_city_racing', 'low-quality open world, ws=none'),
    @('redout_enhanced_edition', 'anti-gravity racer (WipEout-style), no wheel support')
)

$otherRemove | ForEach-Object {
    $slug = $_[0]; $reason = $_[1]
    if ($db.games.PSObject.Properties[$slug]) {
        $db.games.PSObject.Properties.Remove($slug)
        Write-Host "  Removed: $slug ($reason)"
        $script:removedCount++
    }
}

# =============================================================================
# PHASE 4: Set kart racer rotation values
# Kart racers with tight tracks and quick turning = 180deg
# Kart racers with wider tracks = 270deg
# =============================================================================
Write-Host ""
Write-Host "=== Phase 4: Set kart racer rotation values ==="

# 180deg kart racers (tight tracks, quick steering)
$kart180 = @(
    @('kartrider_drift', 'KartRider: Drift - tight kart racing, 180deg recommended for quick turns'),
    @('beach_buggy_racing_2', 'Beach Buggy Racing 2 - mobile-style kart racer, 180deg for responsive steering'),
    @('table_top_racing_world_tour', 'Table Top Racing - micro machines style, 180deg for tight tracks'),
    @('toybox_turbos', 'Toybox Turbos - micro machines style, 180deg for miniature tracks'),
    @('circuit_superstars', 'Circuit Superstars - top-down racer, 180deg for quick directional changes')
)

$kart180 | ForEach-Object {
    $slug = $_[0]; $desc = $_[1]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = 180
        $g.confidence = 'low'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = 180deg (low)"
        $script:setCount++
    }
}

# 270deg kart racers (wider tracks, arcade-style)
$kart270 = @(
    @('sonic_and_allstars_racing_transformed', 'Sonic All-Stars Racing Transformed - arcade kart racer, wider tracks, 270deg'),
    @('team_sonic_racing', 'Team Sonic Racing - arcade kart racer, 270deg like classic arcade racers'),
    @('hot_wheels_unleashed', 'Hot Wheels Unleashed - arcade toy car racing, 270deg')
)

$kart270 | ForEach-Object {
    $slug = $_[0]; $desc = $_[1]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = 270
        $g.confidence = 'low'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = 270deg (low)"
        $script:setCount++
    }
}

# =============================================================================
# PHASE 5: Set arcade-style racer rotation values
# Retro arcade racers inspired by Daytona/OutRun = 270deg
# Top-down racers = 180deg
# =============================================================================
Write-Host ""
Write-Host "=== Phase 5: Set arcade-style racer rotation values ==="

# 270deg arcade-style (inspired by classic arcade racers)
$arcade270 = @(
    @('hotshot_racing', 'Hotshot Racing - retro arcade racer (Daytona/Virtua Racing style), 270deg'),
    @('horizon_chase_turbo', 'Horizon Chase Turbo - retro arcade racer (OutRun style), 270deg'),
    @('grip_combat_racing', 'GRIP: Combat Racing - futuristic combat racer, 270deg'),
    @('slipstream_ansdor', 'Slipstream - retro arcade racer (OutRun homage), 270deg'),
    @('new_star_gp', 'New Star GP - retro F1 racer with partial wheel support, 270deg'),
    @('parking_garage_rally_circuit', 'Parking Garage Rally Circuit - retro rally racer, partial wheel support, 270deg')
)

$arcade270 | ForEach-Object {
    $slug = $_[0]; $desc = $_[1]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = 270
        $g.confidence = 'low'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = 270deg (low)"
        $script:setCount++
    }
}

# 180deg top-down/isometric racers
$arcade180 = @(
    @('death_rally_classic', 'Death Rally (Classic) - top-down racer, 180deg for quick turns'),
    @('death_rally', 'Death Rally (2012) - top-down/isometric racer, 180deg')
)

$arcade180 | ForEach-Object {
    $slug = $_[0]; $desc = $_[1]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = 180
        $g.confidence = 'low'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = 180deg (low)"
        $script:setCount++
    }
}

# =============================================================================
# PHASE 6: Set remaining misc driving games where possible
# =============================================================================
Write-Host ""
Write-Host "=== Phase 6: Set misc driving games ==="

$misc = @(
    @('carmageddon_max_damage', 270, 'Carmageddon: Max Damage - vehicular combat racer, 270deg'),
    @('jalopy', 270, 'Jalopy - road trip driving sim, 270deg for casual driving'),
    @('pacific_drive', 270, 'Pacific Drive - first-person survival driving, 270deg'),
    @('heading_out', 270, 'Heading Out - narrative driving game, 270deg'),
    @('trail_out', 270, 'TRAIL OUT - destruction derby/racing, 270deg'),
    @('kanjozoku_game', 270, 'Kanjozoku Game - street racing/drifting, 270deg'),
    @('drift_over_drive', 270, 'Drift (Over) Drive - drift racing, 270deg'),
    @('drift86', 270, 'Drift86 - drift racing, 270deg'),
    @('drifto_infinite_touge', 270, 'Drifto: Infinite Touge - touge drifting, 270deg'),
    @('drive_beyond_horizons', 270, 'Drive Beyond Horizons - driving game, 270deg'),
    @('offroad_mania', 270, 'Offroad Mania - off-road driving, 270deg')
)

$misc | ForEach-Object {
    $slug = $_[0]; $deg = $_[1]; $desc = $_[2]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = $deg
        $g.confidence = 'low'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = ${deg}deg (low)"
        $script:setCount++
    }
}

# =============================================================================
# Save
# =============================================================================
Write-Host ""
$totalGames = @($db.games.PSObject.Properties).Count
$withRotation = @($db.games.PSObject.Properties | Where-Object { $null -ne $_.Value.rotation_degrees }).Count
$unknown = $totalGames - $withRotation

Write-Host "=== Final Summary ==="
Write-Host "Removals: $removedCount"
Write-Host "Rotation values set: $setCount"
Write-Host "Total games now: $totalGames"
Write-Host "With rotation: $withRotation"
Write-Host "Unknown: $unknown"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
