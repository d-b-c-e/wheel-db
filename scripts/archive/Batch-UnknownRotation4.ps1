Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$removedCount = 0
$setCount = 0

# =============================================================================
# PHASE 1: Remove entries missed in batch 3 due to slug mismatches
# =============================================================================
Write-Host "=== Phase 1: Remove entries missed due to slug mismatch ==="

$toRemove = @(
    @('grudge_match_v0090_italy_location_test', 'wrestling game, not driving'),
    @('night_stocker_10686', 'Bally/Sente light gun/driving hybrid, not wheel game'),
    @('pit__run__f1_race', 'Taito action platformer, joystick'),
    @('rescue_raider_51187_noncartridge', 'Bally Midway helicopter game'),
    @('river_patrol', 'Orca boat patrol, joystick'),
    @('tank_battle_prototype_rev_42192', 'Microprose tank sim prototype'),
    @('turbo_sub_prototype_rev_tsca', 'Entertainment Sciences submarine game'),
    @('tugboat', 'Enter-Tech boat game, joystick'),
    @('the_bounty', 'Orca scrolling shooter'),
    @('porky', 'Shinkai Pac-Man conversion, maze game'),
    @('rally_bike__dash_yarou', 'Toaplan/Taito overhead motorcycle, joystick'),
    @('metal_maniax_prototype', 'Atari Games vehicular combat prototype'),
    @('road_riots_revenge_prototype_sep_06_1994', 'Atari Games vehicular combat prototype'),
    @('hydra', 'Atari Games boat/vehicle shooter'),
    @('thrash_rally_alm003__alh003', 'Alpha Denshi Neo Geo rally, joystick')
)

$toRemove | ForEach-Object {
    $slug = $_[0]; $reason = $_[1]
    if ($db.games.PSObject.Properties[$slug]) {
        $db.games.PSObject.Properties.Remove($slug)
        Write-Host "  Removed: $slug ($reason)"
        $script:removedCount++
    } else {
        Write-Host "  SKIP (not found): $slug"
    }
}

# =============================================================================
# PHASE 2: Fix rotation values missed in batch 3 due to slug mismatch
# =============================================================================
Write-Host ""
Write-Host "=== Phase 2: Fix slug mismatches for rotation values ==="

$toSet = @(
    @('atv_track', 270, 'low', 'Gaelco 2002 ATV racing'),
    @('go_by_rc_v203o_19990525_1331', 270, 'low', 'Taito 1999 RC car racing'),
    @('f1_super_battle', 270, 'low', 'Jaleco 1994 F1 racing with steering wheel'),
    @('tokyo_bus_guide', 360, 'low', 'Fortyfive 1999 bus driving sim, likely 360deg for bus'),
    @('driving_force_pacman_conversion', 270, 'low', 'Shinkai 1984 driving game on Pac-Man hardware')
)

$toSet | ForEach-Object {
    $slug = $_[0]; $deg = $_[1]; $conf = $_[2]; $desc = $_[3]
    $g = $db.games.$slug
    if ($g) {
        $g.rotation_degrees = $deg
        $g.confidence = $conf
        $g.rotation_type = 'mechanical_stop'
        $existingSources = @($g.sources)
        $newSrc = [PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        }
        $g.sources = $existingSources + @($newSrc)
        Write-Host "  Set: $slug = ${deg}deg ($conf)"
        $script:setCount++
    } else {
        Write-Host "  SKIP (not found): $slug"
    }
}

# =============================================================================
# PHASE 3: Set Konami watercraft/specialty
# =============================================================================
Write-Host ""
Write-Host "=== Phase 3: Set Konami specialty ==="

$g = $db.games.'jetwave'
if ($g -and $null -eq $g.rotation_degrees) {
    $g.rotation_degrees = 270
    $g.confidence = 'low'
    $g.rotation_type = 'mechanical_stop'
    $g.sources = @($g.sources) + @([PSCustomObject]@{
        type = 'inference'
        description = 'Konami 1996 jet ski game with handlebar controls'
        url = $null
        date_accessed = '2026-02-17'
    })
    Write-Host "  Set: jetwave = 270deg (low)"
    $setCount++
}

$g = $db.games.'xtrial_racing'
if ($g -and $null -eq $g.rotation_degrees) {
    $g.rotation_degrees = 270
    $g.confidence = 'low'
    $g.rotation_type = 'mechanical_stop'
    $g.sources = @($g.sources) + @([PSCustomObject]@{
        type = 'inference'
        description = 'Konami 2002 motorcycle trials game'
        url = $null
        date_accessed = '2026-02-17'
    })
    Write-Host "  Set: xtrial_racing = 270deg (low)"
    $setCount++
}

# =============================================================================
# PHASE 4: Set Namco motorcycle games
# Arcade motorcycle games typically have ±30-45deg handlebar rotation
# Setting to 270 as a default wheel mapping since MAME maps analog range
# =============================================================================
Write-Host ""
Write-Host "=== Phase 4: Set Namco motorcycle/specialty games ==="

$namcoMoto = @(
    @('suzuka_8_hours', 270, 'low', 'Namco 1992 motorcycle GP, handlebar controls'),
    @('suzuka_8_hours_2', 270, 'low', 'Namco 1993 motorcycle GP sequel, handlebar controls'),
    @('motocross_go', 270, 'low', 'Namco 1997 motocross, handlebar controls'),
    @('500_gp', 270, 'low', 'Namco 1998 motorcycle GP, handlebar controls'),
    @('moto_gp_mgp1004nab', 270, 'low', 'Namco 2007 MotoGP, handlebar controls'),
    @('downhill_bikers', 270, 'low', 'Namco 1997 bicycle downhill, handlebar controls')
)

$namcoMoto | ForEach-Object {
    $slug = $_[0]; $deg = $_[1]; $conf = $_[2]; $desc = $_[3]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = $deg
        $g.confidence = $conf
        $g.rotation_type = 'mechanical_stop'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = ${deg}deg ($conf)"
        $script:setCount++
    }
}

# =============================================================================
# PHASE 5: Set Sega motorcycle games
# These use body lean / handlebar tilt. Setting 270deg as MAME analog default.
# =============================================================================
Write-Host ""
Write-Host "=== Phase 5: Set Sega motorcycle games ==="

$segaMoto = @(
    @('hangon', 270, 'low', 'Sega 1985 motorcycle, body lean/tilt cabinet'),
    @('hangonjr', 270, 'low', 'Sega 1985 sit-down motorcycle, handlebar controls'),
    @('super_hangon_sitdownupright_unprotected', 270, 'low', 'Sega 1987 motorcycle, body lean/sit-down variants'),
    @('enduro_racer', 270, 'low', 'Sega 1986 motorcycle, body lean cabinet'),
    @('racing_hero_fd1094_3170144', 270, 'low', 'Sega 1989 motorcycle racing'),
    @('abcop', 270, 'low', 'Sega 1990 motorcycle cop chase'),
    @('gprider', 270, 'low', 'Sega 1990 motorcycle GP racing'),
    @('stadiumcross', 270, 'low', 'Sega 1992 dirt bike/motocross'),
    @('cool_riders', 270, 'low', 'Sega 1995 motorcycle racing'),
    @('manxttsuperbike', 270, 'low', 'Sega 1995 motorcycle TT racing, body lean cabinet'),
    @('harleydavidson', 270, 'low', 'Sega 1997 Harley-Davidson motorcycle, Model 3'),
    @('motorraid', 270, 'low', 'Sega 1997 motorcycle combat, Model 2')
)

$segaMoto | ForEach-Object {
    $slug = $_[0]; $deg = $_[1]; $conf = $_[2]; $desc = $_[3]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = $deg
        $g.confidence = $conf
        $g.rotation_type = 'mechanical_stop'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = ${deg}deg ($conf)"
        $script:setCount++
    }
}

# =============================================================================
# PHASE 6: Set remaining misc motorcycle/handlebar games
# =============================================================================
Write-Host ""
Write-Host "=== Phase 6: Set remaining motorcycle/misc games ==="

$miscMoto = @(
    @('hyper_crash_version_d', 270, 'low', 'Konami 1987 motorcycle racing'),
    @('cycle_warriors', 270, 'low', 'Tatsumi 1991 motorcycle combat'),
    @('moto_frenzy', 270, 'low', 'Atari Games 1992 motorcycle racing'),
    @('kick_start__wheelie_king', 270, 'low', 'Taito 1984 motorcycle wheelie game'),
    @('kick_rider', 270, 'low', 'Universal 1984 motorcycle game'),
    @('superbike', 270, 'low', 'Century Electronics 1983 motorcycle racing')
)

$miscMoto | ForEach-Object {
    $slug = $_[0]; $deg = $_[1]; $conf = $_[2]; $desc = $_[3]
    $g = $db.games.$slug
    if ($g -and $null -eq $g.rotation_degrees) {
        $g.rotation_degrees = $deg
        $g.confidence = $conf
        $g.rotation_type = 'mechanical_stop'
        $g.sources = @($g.sources) + @([PSCustomObject]@{
            type = 'inference'
            description = $desc
            url = $null
            date_accessed = '2026-02-17'
        })
        Write-Host "  Set: $slug = ${deg}deg ($conf)"
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
