<#
.SYNOPSIS
    Classify all 80 rotation_type=unknown entries using manufacturer patterns (v2.15.0)
.DESCRIPTION
    Maps manufacturer + rotation_degrees to the correct rotation_type based on
    well-established hardware documentation already in the database.

    Rules:
    - rotation_degrees = -1 → optical_encoder (any manufacturer)
    - Namco 270° → potentiometer (VG75-07050-00 standard)
    - Gaelco 270° → potentiometer (documented standard)
    - Sega 270° → mechanical_stop (SPG-2002 assembly)
    - Konami 270° → mechanical_stop (documented standard)
    - Taito 270°/540° → mechanical_stop (Z System / Type X)
    - Midway/Bally 270° → mechanical_stop (SuzoHapp Active 270)
    - Atari Games 270° → mechanical_stop (SuzoHapp standard)
    - Atari Games 1080° → potentiometer (10-turn pot, same as Hard Drivin')
    - Atari/Kee -1 → optical_encoder (TTL era)
    - Global VR 270° → mechanical_stop (modern SuzoHapp)
    - Video System 270° → mechanical_stop
    - Others (Tatsumi, Sammy/SIMS, Strata) 270° → mechanical_stop
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dbPath = Join-Path $PSScriptRoot '..\..\data\wheel-db.json'
$db = Get-Content $dbPath -Raw | ConvertFrom-Json

$fixed = 0
$skipped = 0

function Set-RotationType {
    param($slug, $type, $reason)
    $game = $db.games.$slug
    if (-not $game) { Write-Host "  SKIP: $slug not found"; $script:skipped++; return }
    if ($game.rotation_type -ne 'unknown') { Write-Host "  SKIP: $slug already $($game.rotation_type)"; $script:skipped++; return }

    $game.rotation_type = $type
    $game.sources += [PSCustomObject]@{
        type = 'inference'
        description = $reason
        url = $null
        date_accessed = '2026-02-20'
    }
    $script:fixed++
    Write-Host "  FIXED: $slug → $type"
}

# ============================================================
# Rule 1: Infinite rotation → optical_encoder (7 entries)
# ============================================================
Write-Host "`n=== Rule 1: Infinite rotation → optical_encoder ===" -ForegroundColor Yellow

Set-RotationType 'fonz_ttl' 'optical_encoder' 'TTL-era game with infinite rotation dial/spinner input. Sega TTL hardware.'
Set-RotationType 'gran_trak_10trak_10formula_k_ttl' 'optical_encoder' 'TTL-era game (1974) with infinite rotation steering. Atari/Kee optical encoder.'
Set-RotationType 'gran_trak_20trak_20twin_racer_ttl' 'optical_encoder' 'TTL-era game (1974) with infinite rotation steering. Atari/Kee optical encoder.'
Set-RotationType 'head_on_2' 'optical_encoder' 'Early Sega game with infinite rotation dial input. Optical encoder steering.'
Set-RotationType 'monaco_gp' 'optical_encoder' 'Early Sega game (1979) with infinite rotation steering. Optical encoder.'
Set-RotationType 'sprint_4' 'optical_encoder' 'TTL-era Atari game (1977) with infinite rotation steering. Optical encoder.'
Set-RotationType 'sprint_8' 'optical_encoder' 'TTL-era Atari game (1977) with infinite rotation steering. Optical encoder.'

# ============================================================
# Rule 2: Namco 270° → potentiometer (9 entries)
# ============================================================
Write-Host "`n=== Rule 2: Namco 270° → potentiometer ===" -ForegroundColor Yellow

$namcoReason = 'Namco standard 1K ohm 270-degree potentiometer (VG75-07050-00). Documented across System 2/21/22/Super System 22/11/12.'
foreach ($slug in @(
    'final_lap_r_rev_b', 'final_lap', 'kart_duel', 'race_on',
    'ridge_racer_2_rev_rrs2_world', 'ridge_racer_v_arcade_battle_rrv3_ver_a',
    'wangan_midnight_maximum_tune_export_rev_', 'wangan_midnight_maximum_tune_2_export_re',
    'winning_run_91'
)) {
    Set-RotationType $slug 'potentiometer' $namcoReason
}

# ============================================================
# Rule 3: Gaelco 270° → potentiometer (5 entries)
# ============================================================
Write-Host "`n=== Rule 3: Gaelco 270° → potentiometer ===" -ForegroundColor Yellow

$gaelcoReason = 'Gaelco racing cabinet potentiometer steering assembly. Documented standard across Gaelco racing lineup (Speed Up, World Rally, Xtreme Rally).'
foreach ($slug in @(
    'last_km', 'rolling_extreme', 'smashing_drive',
    'speed_up_version_220', 'world_rally_2_twin_racing_mask_rom_versi'
)) {
    Set-RotationType $slug 'potentiometer' $gaelcoReason
}

# ============================================================
# Rule 4: Sega 270° → mechanical_stop (18 entries)
# ============================================================
Write-Host "`n=== Rule 4: Sega 270° → mechanical_stop ===" -ForegroundColor Yellow

$segaReason = 'Sega SPG-2002 steering assembly with mechanical stops at 270 degrees. Standard across Sega racing cabinets.'
foreach ($slug in @(
    'choro_q_hyper_racing_5_j_981230_v1000',
    'crazy_taxi_high_roller',
    'f1_super_lap',
    'ferrari_f355_challenge_2__international_',
    'ferrari_f355_challenge_deluxe_no_link',
    'ferrari_f355_challenge_twindeluxe',
    'gp_world',
    'indy_500_twin_revision_a_newer',
    'nascar_racing',
    'outrun_2',
    'rad_mobile',
    'rad_rally',
    'ring_out_4x4',
    'rough_racer',
    'sega_touring_car_championship',
    'star_wars_racer_arcade',
    'the_king_of_route_66',
    'wild_riders'
)) {
    Set-RotationType $slug 'mechanical_stop' $segaReason
}

# ============================================================
# Rule 5: Konami 270° → mechanical_stop (9 entries)
# ============================================================
Write-Host "`n=== Rule 5: Konami 270° → mechanical_stop ===" -ForegroundColor Yellow

$konamiReason = 'Konami racing cabinet with 270-degree mechanical stop steering assembly. Standard across Konami racing game lineup.'
foreach ($slug in @(
    'gti_club', 'gti_club_corso_italiano',
    'midnight_run_road_fighter_2_eaa_euro_v11',
    'racin_force',
    'racing_jam_dx', 'racing_jam_jac',
    'thrill_drive_2', 'thrill_drive_jae',
    'winding_heat_eaa_euro_v211'
)) {
    Set-RotationType $slug 'mechanical_stop' $konamiReason
}

# ============================================================
# Rule 6: Taito 270°/540° → mechanical_stop (9 entries)
# ============================================================
Write-Host "`n=== Rule 6: Taito → mechanical_stop ===" -ForegroundColor Yellow

$taitoReason = 'Taito racing cabinet with mechanical stop steering assembly. Standard across Taito Z System and Type X racing games.'
foreach ($slug in @(
    'chase_hq',
    'ground_effects__super_ground_effects',
    'laser_grand_prix',
    'racing_beat',
    'side_by_side',
    'special_criminal_investigation',
    'super_chase__criminal_termination',
    'world_grand_prix',
    'battle_gear_2_v204j'
)) {
    Set-RotationType $slug 'mechanical_stop' $taitoReason
}

# ============================================================
# Rule 7: Midway/Bally 270° → mechanical_stop (7 entries)
# ============================================================
Write-Host "`n=== Rule 7: Midway/Bally 270° → mechanical_stop ===" -ForegroundColor Yellow

$midwayReason = 'Midway racing cabinet with SuzoHapp Active 270 mechanical stop steering assembly. Documented standard for Midway arcade racers.'
foreach ($slug in @(
    'cart_fury_championship_racing',
    'cruisn_exotica_version_24',
    'cruisn_world_v25',
    'hydro_thunder',
    'hyperdrive',
    'offroad_thunder_mame',
    'spy_hunter'
)) {
    Set-RotationType $slug 'mechanical_stop' $midwayReason
}

# ============================================================
# Rule 8: Atari Games 270°/1080° (6 entries)
# ============================================================
Write-Host "`n=== Rule 8: Atari Games ===" -ForegroundColor Yellow

$atariReason270 = 'Atari Games racing cabinet with SuzoHapp 270-degree mechanical stop steering assembly.'
foreach ($slug in @(
    'road_riot_4wd',
    'san_francisco_rush_2049',
    'san_francisco_rush_2049_tournament_editi',
    'san_francisco_rush_boot_rom_l_10',
    'san_francisco_rush_the_rock_boot_rom_l_1'
)) {
    Set-RotationType $slug 'mechanical_stop' $atariReason270
}

Set-RotationType 'race_drivin_cockpit_rev_5' 'potentiometer' 'Same 10-turn potentiometer as Hard Drivin (1080 degrees, 3-rotation mechanical stop). Atari Games racing cabinet.'

# ============================================================
# Rule 9: Global VR 270° → mechanical_stop (3 entries)
# ============================================================
Write-Host "`n=== Rule 9: Global VR 270° → mechanical_stop ===" -ForegroundColor Yellow

$gvrReason = 'Global VR racing cabinet with standard 270-degree mechanical stop steering assembly.'
foreach ($slug in @(
    'need_for_speed__4_cab_link_2_discs_v101_',
    'need_for_speed_gt_hard_drive2_discs_v110',
    'need_for_speed_underground_install_2_dis'
)) {
    Set-RotationType $slug 'mechanical_stop' $gvrReason
}

# ============================================================
# Rule 10: Video System 270° → mechanical_stop (3 entries)
# ============================================================
Write-Host "`n=== Rule 10: Video System 270° → mechanical_stop ===" -ForegroundColor Yellow

$vsReason = 'Video System Co. racing cabinet with 270-degree mechanical stop steering assembly.'
foreach ($slug in @(
    'f1_grand_prix',
    'f1_grand_prix_part_ii',
    'lethal_crash_race__bakuretsu_crash_race'
)) {
    Set-RotationType $slug 'mechanical_stop' $vsReason
}

# ============================================================
# Rule 11: Other manufacturers 270° → mechanical_stop (4 entries)
# ============================================================
Write-Host "`n=== Rule 11: Other manufacturers → mechanical_stop ===" -ForegroundColor Yellow

Set-RotationType 'buggy_boyspeed_buggy_cockpit_rev_d' 'mechanical_stop' 'Tatsumi racing cabinet with 270-degree mechanical stop steering. Consistent with other Tatsumi racers (Apache 3, TX-1).'
Set-RotationType 'faster_than_speed' 'mechanical_stop' 'Sammy racing cabinet with 270-degree mechanical stop steering assembly.'
Set-RotationType 'maximum_speed' 'mechanical_stop' 'SIMS/Sammy racing cabinet with 270-degree mechanical stop steering assembly.'
Set-RotationType 'driversedge' 'mechanical_stop' 'Strata/Incredible Technologies racing cabinet with standard 270-degree mechanical stop steering.'

# ============================================================
# Summary & Save
# ============================================================
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Fixed: $fixed"
Write-Host "Skipped: $skipped"

if ($fixed -gt 0) {
    $db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding utf8
    Write-Host "Database saved."
}
