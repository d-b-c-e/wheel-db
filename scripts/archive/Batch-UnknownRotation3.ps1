Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

function Remove-Entry {
    param([string]$slug, [string]$reason)
    if ($db.games.PSObject.Properties[$slug]) {
        $db.games.PSObject.Properties.Remove($slug)
        Write-Output "  Removed: $slug ($reason)"
        return 1
    } else {
        Write-Output "  SKIP (not found): $slug"
        return 0
    }
}

function Set-Rotation {
    param([string]$slug, [int]$degrees, [string]$confidence, [string]$rotationType,
          [string]$sourceType, [string]$sourceDesc)
    $g = $db.games.$slug
    if (-not $g) { Write-Output "  SKIP (not found): $slug"; return 0 }
    $g.rotation_degrees = $degrees
    $g.confidence = $confidence
    if ($rotationType) { $g.rotation_type = $rotationType }
    if ($sourceType -and $sourceDesc) {
        $newSrc = [PSCustomObject]@{
            type = $sourceType
            description = $sourceDesc
            url = $null
            date_accessed = '2026-02-17'
        }
        $existingSources = @($g.sources)
        $g.sources = $existingSources + @($newSrc)
    }
    Write-Output "  Set: $slug = ${degrees}deg ($confidence)"
    return 1
}

$removed = 0
$rotSet = 0

# =============================================================================
# PHASE 1: Remove tank/military games (NOT wheel/handlebar)
# =============================================================================
Write-Output "=== Phase 1: Remove tank/military games ==="
$removed += Remove-Entry 'battle_zone' 'dual-joystick tank game'
$removed += Remove-Entry 'bradley_trainer' 'military trainer, periscope controls'
$removed += Remove-Entry 'vindicators' 'dual-joystick tank game'
$removed += Remove-Entry 'vindicators_part_ii' 'dual-joystick tank game'
$removed += Remove-Entry 'desert_tank' 'tank sim, joystick'
$removed += Remove-Entry 'tank_battle_prototype' 'tank sim prototype'
$removed += Remove-Entry 'tnk_iii' 'vertical scrolling tank, joystick'
Write-Output ""

# =============================================================================
# PHASE 2: Remove shooters/scrolling action (NOT driving games)
# =============================================================================
Write-Output "=== Phase 2: Remove shooters/scrolling action ==="
$removed += Remove-Entry 'moon_patrol' 'side-scrolling vehicle shooter, joystick'
$removed += Remove-Entry 'the_battleroad' 'Irem action game, joystick'
$removed += Remove-Entry 'horizon_irem' 'Irem scrolling shooter'
$removed += Remove-Entry 'strategy_x' 'Konami scrolling shooter'
$removed += Remove-Entry 'mega_zone_program_code_l' 'Konami scrolling shooter'
$removed += Remove-Entry 'polygonet_commanders' 'Konami 3D shooter, joystick'
$removed += Remove-Entry 'thundercade__twin_formation' 'Seta vertical shooter'
$removed += Remove-Entry 'battle_lane_vol_5' 'Technos scrolling shooter'
$removed += Remove-Entry 'last_duel' 'Capcom scrolling shooter'
$removed += Remove-Entry 'mad_gear' 'Capcom action game'
$removed += Remove-Entry 'the_speed_rumbler' 'Capcom overhead action, joystick'
$removed += Remove-Entry 'shot_rider' 'Seibu motorcycle shooter'
$removed += Remove-Entry 'mad_alien' 'Data East shooter'
$removed += Remove-Entry 'mad_crasher' 'SNK action game'
$removed += Remove-Entry 'galactic_storm' 'Taito 3D space shooter'
$removed += Remove-Entry 'enforce' 'Taito 3D chase shooter, joystick'
$removed += Remove-Entry 'aqua_jack' 'Taito watercraft shooter, joystick'
$removed += Remove-Entry 'maze_of_flott' 'Taito maze game, paddle not wheel'
$removed += Remove-Entry 'pitnrun' 'Taito action platformer'
$removed += Remove-Entry 'time_tunnel' 'Taito, not a driving game'
$removed += Remove-Entry 'return_of_the_jedi' 'Atari scrolling shooter'
$removed += Remove-Entry 'crater_raider' 'Bally Midway scrolling shooter'
$removed += Remove-Entry 'rescue_raider' 'Bally Midway helicopter game'
$removed += Remove-Entry 'minefield' 'Stern maze/action game'
$removed += Remove-Entry 'radical_radial' 'Nichibutsu paddle game, not driving'
$removed += Remove-Entry 'break_thru' 'Data East run and gun'
$removed += Remove-Entry 'bandit' 'Data East action game'
Write-Output ""

# =============================================================================
# PHASE 3: Remove flight sims (yoke controls, not wheel)
# =============================================================================
Write-Output "=== Phase 3: Remove flight sims ==="
$removed += Remove-Entry 'top_landing' 'Taito flight sim, yoke controls'
$removed += Remove-Entry 'midnight_landing_germany' 'Taito flight landing sim'
$removed += Remove-Entry 'landing_gear' 'Taito flight landing sim'
$removed += Remove-Entry 'landing_high_japan' 'Taito flight landing sim'
$removed += Remove-Entry 'lunar_lander' 'Atari descent game, thrust control'
Write-Output ""

# =============================================================================
# PHASE 4: Remove console ports on arcade hardware (joystick/d-pad)
# =============================================================================
Write-Output "=== Phase 4: Remove console ports on arcade hardware ==="
$removed += Remove-Entry 'vs_excitebike' 'NES game on VS System, d-pad'
$removed += Remove-Entry 'excite_bike_playchoice10' 'NES PlayChoice-10, d-pad'
$removed += Remove-Entry 'fzero_nintendo_super_system' 'SNES on NSS, d-pad'
$removed += Remove-Entry 'rad_racer_playchoice10' 'NES PlayChoice-10, d-pad'
$removed += Remove-Entry 'rad_racer_ii_playchoice10' 'NES PlayChoice-10, d-pad'
$removed += Remove-Entry 'rc_proam_playchoice10' 'NES PlayChoice-10, d-pad'
Write-Output ""

# =============================================================================
# PHASE 5: Remove Neo Geo / joystick-only racers (no wheel hardware)
# =============================================================================
Write-Output "=== Phase 5: Remove joystick-only racers ==="
$removed += Remove-Entry 'riding_hero_ngm006__ngh006' 'Neo Geo motorcycle, joystick'
$removed += Remove-Entry 'thrash_rally' 'Neo Geo rally, joystick'
$removed += Remove-Entry 'drift_out_94__the_hard_order' 'Neo Geo rally, joystick'
$removed += Remove-Entry 'neo_drift_out__new_technology' 'Neo Geo drift racing, joystick'
$removed += Remove-Entry 'over_top' 'Neo Geo racing, joystick'
$removed += Remove-Entry 'joyful_road' 'SNK overhead, joystick'
$removed += Remove-Entry 'jumping_cross' 'SNK action, joystick'
$removed += Remove-Entry 'safari_rally' 'SNK/Taito overhead, joystick'
$removed += Remove-Entry 'f1_dream' 'Capcom overhead F1, joystick'
$removed += Remove-Entry 'rally_x_32k_ver' 'Namco overhead maze racer, joystick'
$removed += Remove-Entry 'new_rally_x' 'Namco overhead maze racer, joystick'
$removed += Remove-Entry 'tail_to_nose__great_championship' 'V-System overhead F1, joystick'
$removed += Remove-Entry 'masked_riders_club_battle_race' 'Banpresto overhead, joystick'
$removed += Remove-Entry 'traverse_usa__zippy_race' 'Irem overhead, joystick'
$removed += Remove-Entry 'upn_down_3155030' 'Sega jumping car action, joystick'
$removed += Remove-Entry 'route_16_sun_electronics' 'Sun Electronics overhead maze, joystick'
$removed += Remove-Entry 'car_jamboree' 'Omori overhead, joystick'
$removed += Remove-Entry 'led_storm_rally_2011' 'Capcom motorcycle action, joystick'
$removed += Remove-Entry 'clashroad' 'Woodplace overhead, joystick'
$removed += Remove-Entry 'super_cross_ii' 'GM Shoji motorcycle, joystick'
$removed += Remove-Entry 'road_blaster_data_east_ld' 'Data East laserdisc, joystick controls'
$removed += Remove-Entry 'head_on_irem_m15_hardware' 'Irem Head On clone, joystick'
$removed += Remove-Entry 'head_on_2_players' 'Gremlin Head On variant, joystick'
Write-Output ""

# =============================================================================
# PHASE 6: Remove other non-driving entries
# =============================================================================
Write-Output "=== Phase 6: Remove other non-driving entries ==="
$removed += Remove-Entry 'virtual_combat' 'VR8 VR combat game'
$removed += Remove-Entry 'grudge_match' 'Bally Midway wrestling game'
$removed += Remove-Entry 'night_stocker' 'Bally/Sente light gun driving hybrid'
$removed += Remove-Entry 'space_position' 'Sega/Nasco space game'
$removed += Remove-Entry 'sega_netmerc' 'Sega network test hardware'
$removed += Remove-Entry 'roadwars_arcadia_v_23' 'Arcadia scrolling vehicle, joystick'
$removed += Remove-Entry 'pro_cycle_tele_cardioline_salter_fitness' 'Salter fitness equipment'
$removed += Remove-Entry 'pro_stepper_tele_cardioline_salter_fitne' 'Salter fitness equipment'
$removed += Remove-Entry 'uchuu_tokkyuu_medalian' 'Sigma medal/redemption game'
$removed += Remove-Entry 'warp_speed_prototype' 'Meadows space game prototype'
$removed += Remove-Entry 'pang_pang_car' 'Icarus bumper car redemption'
$removed += Remove-Entry 'motogonki' 'Terminal unknown, likely joystick'
Write-Output ""

# =============================================================================
# PHASE 7: Set TTL-era games as optical encoders (-1)
# =============================================================================
Write-Output "=== Phase 7: Set TTL-era optical encoders (-1) =priorities ==="
$ttlGames = @(
    @('crash_n_scorestock_car_ttl', 'Atari 1975 TTL stock car'),
    @('le_mans_ttl', 'Atari 1976 TTL Le Mans'),
    @('stunt_cycle_ttl', 'Atari 1976 TTL motorcycle'),
    @('indy_800_ttl', 'Atari/Kee 1975 TTL Indy racing'),
    @('indy_4_ttl', 'Atari/Kee 1976 TTL Indy racing'),
    @('super_bug', 'Atari 1977 driving game'),
    @('280zzzap', 'Dave Nutting/Midway 1976 driving'),
    @('demolition_derby_ttl', 'Chicago Coin 1976 TTL'),
    @('street_burners_ttl', 'Allied Leisure 1975 TTL'),
    @('death_race_ttl', 'Exidy 1976 TTL'),
    @('destruction_derby_ttl', 'Exidy 1976 TTL'),
    @('ciscofisco_400_ttl', 'Taito 1977 TTL racing'),
    @('tt_speed_race_cl_ttl', 'Taito 1978 TTL racing'),
    @('fool_race', 'EFG Sanremo 1979 early driving'),
    @('speed_race_seletron__olympia', 'Seletron/Olympia 1980 early driving'),
    @('longbeach', 'Olympia 1979 early driving'),
    @('crash', 'Exidy 1979 driving'),
    @('18_wheeler_midway', 'Midway 1979 early driving')
)
$ttlGames | ForEach-Object {
    $rotSet += Set-Rotation $_[0] -1 'medium' 'optical_encoder' 'inference' "TTL/early era game, optical encoder steering ($_[1])"
}
Write-Output ""

# =============================================================================
# PHASE 8: Set known Taito driving games
# =============================================================================
Write-Output "=== Phase 8: Set Taito driving games ==="
$rotSet += Set-Rotation 'chase_hq_2_v206jp' 270 'medium' 'mechanical_stop' 'inference' 'Chase H.Q. sequel, same 270deg cabinet standard as original'
$rotSet += Set-Rotation 'super_dead_heat' 270 'low' 'mechanical_stop' 'inference' 'Taito 1985 racing game, standard 270deg pot likely'
$rotSet += Set-Rotation 'high_way_race' 270 'low' 'mechanical_stop' 'inference' 'Taito 1983 driving game'
$rotSet += Set-Rotation 'chase_bombers' 270 'low' 'mechanical_stop' 'inference' 'Taito 1994 vehicular chase game'
$rotSet += Set-Rotation 'go_by_rc' 270 'low' 'mechanical_stop' 'inference' 'Taito 1999 RC car racing'
Write-Output ""

# =============================================================================
# PHASE 9: Set known Konami driving games
# =============================================================================
Write-Output "=== Phase 9: Set Konami driving games ==="
$rotSet += Set-Rotation 'hot_chase' 270 'medium' 'mechanical_stop' 'inference' 'Konami 1988 driving chase, standard Konami 270deg'
$rotSet += Set-Rotation 'city_bomber' 270 'low' 'mechanical_stop' 'inference' 'Konami 1987 motorcycle chase, handlebar controls'
$rotSet += Set-Rotation 'code_one_dispatch' 270 'low' 'mechanical_stop' 'inference' 'Konami 2000 emergency vehicle driving'
Write-Output ""

# =============================================================================
# PHASE 10: Set known Namco driving games
# =============================================================================
Write-Output "=== Phase 10: Set Namco driving games ==="
$rotSet += Set-Rotation 'lucky__wild' 270 'medium' 'mechanical_stop' 'inference' 'Namco 1992 driving/shooting game with steering wheel, Namco 270deg pot standard'
$rotSet += Set-Rotation 'armadillo_racing_rev_am1_vera_japan' 270 'low' 'mechanical_stop' 'inference' 'Namco 1997 racing game'
Write-Output ""

# =============================================================================
# PHASE 11: Set other known driving games
# =============================================================================
Write-Output "=== Phase 11: Set misc driving games ==="
$rotSet += Set-Rotation 'power_drive' 270 'low' 'mechanical_stop' 'inference' 'Bally Midway 1986 driving game'
$rotSet += Set-Rotation 'turbo_tag_prototype' 270 'low' 'mechanical_stop' 'inference' 'Bally Midway 1985 driving prototype'
$rotSet += Set-Rotation 'round_up_5__super_delta_force' 270 'medium' 'mechanical_stop' 'inference' 'Tatsumi 1989 police chase, same cabinet family as Apache 3/Cycle Warriors'
$rotSet += Set-Rotation 'tx1' 270 'medium' 'mechanical_stop' 'inference' 'Tatsumi 1983 F1 racing, steering wheel cabinet'
$rotSet += Set-Rotation 'counter_steer' 270 'low' 'mechanical_stop' 'inference' 'Data East 1985 driving game'
$rotSet += Set-Rotation 'backfire' 270 'low' 'mechanical_stop' 'inference' 'Data East 1995 racing game'
$rotSet += Set-Rotation 'super_stingray' 270 'low' 'mechanical_stop' 'inference' 'Alpha Denshi 1986 driving game'
$rotSet += Set-Rotation 'crazy_rally' 270 'low' 'mechanical_stop' 'inference' 'Tecfri 1985 rally racing'
$rotSet += Set-Rotation 'wheelsandfire' 270 'low' 'mechanical_stop' 'inference' 'TCH racing game with steering wheel'
$rotSet += Set-Rotation 'monza_gp' 270 'low' 'mechanical_stop' 'inference' 'Olympia 1981 racing game'
$rotSet += Set-Rotation 'imola_grand_prix' 270 'low' 'mechanical_stop' 'inference' 'RB Bologna 1983 racing game'
$rotSet += Set-Rotation 'blomby_car_version_1p0' 270 'low' 'mechanical_stop' 'inference' 'ABM/Gecas 1994 racing game'
$rotSet += Set-Rotation 'kamikaze_cabbie' 270 'low' 'mechanical_stop' 'inference' 'Data East 1984 taxi driving game'
$rotSet += Set-Rotation 'california_chase' 270 'low' 'mechanical_stop' 'inference' 'The Game Room 1999 driving game'
$rotSet += Set-Rotation '96_flag_rally' 270 'low' 'mechanical_stop' 'inference' 'Promat 1996 rally racing'
$rotSet += Set-Rotation 'street_heat' 270 'low' 'mechanical_stop' 'inference' 'Epos 1985 driving game'
$rotSet += Set-Rotation 'atvtrack' 270 'low' 'mechanical_stop' 'inference' 'Gaelco 2002 ATV racing'
$rotSet += Set-Rotation 'hog_wild' 270 'low' 'mechanical_stop' 'inference' 'Uniana 2003 motorcycle/ATV racing'
$rotSet += Set-Rotation 'chameleon_rx1' 270 'low' 'mechanical_stop' 'inference' 'Digital Sunnil 2003 racing game'
$rotSet += Set-Rotation 'speed_driver' 270 'low' 'mechanical_stop' 'inference' 'IGS 2004 driving game'
$rotSet += Set-Rotation 'waiwai_drive' 270 'low' 'mechanical_stop' 'inference' 'MOSS/Sammy 2005 racing game'
$rotSet += Set-Rotation 'taxi_driver' 270 'low' 'mechanical_stop' 'inference' 'Graphic Techno 1984 taxi driving game'
$rotSet += Set-Rotation 'turbo_drive_ice' 270 'low' 'mechanical_stop' 'inference' 'ICE 1988 driving game'
$rotSet += Set-Rotation 'wheels_runner' 270 'low' 'mechanical_stop' 'inference' 'International Games racing game'
$rotSet += Set-Rotation 'dangerous_curves' 270 'low' 'mechanical_stop' 'inference' 'Racing game'
Write-Output ""

# =============================================================================
# PHASE 12: Set Data East cassette driving games
# =============================================================================
Write-Output "=== Phase 12: Set Data East driving games ==="
$removed += Remove-Entry 'highway_chase_deco_cassette' 'DECO Cassette overhead, joystick controls'
$removed += Remove-Entry 'burnin_rubber_deco_cassette' 'Burnin Rubber/Bump n Jump, joystick controls'
$removed += Remove-Entry 'burnin_rubber' 'Burnin Rubber/Bump n Jump, joystick controls'
Write-Output ""

# =============================================================================
# PHASE 13: Set laserdisc racing games
# =============================================================================
Write-Output "=== Phase 13: Laserdisc racing games ==="
$rotSet += Set-Rotation 'laser_grand_prix' 270 'low' 'unknown' 'inference' 'Taito 1983 laserdisc racing game with steering wheel'
$rotSet += Set-Rotation 'gp_world' 270 'low' 'unknown' 'inference' 'Sega 1984 laserdisc racing game with steering wheel'
$rotSet += Set-Rotation 'star_rider' 270 'low' 'unknown' 'inference' 'Williams 1984 laserdisc motorcycle game'
Write-Output ""

# =============================================================================
# PHASE 14: Set Namco watercraft / specialty vehicle games
# =============================================================================
Write-Output "=== Phase 14: Namco specialty vehicle games ==="
$rotSet += Set-Rotation 'aquajet' 270 'low' 'mechanical_stop' 'inference' 'Namco 1996 jet ski game with handlebar controls'
$rotSet += Set-Rotation 'rapid_river' 270 'low' 'mechanical_stop' 'inference' 'Namco 1997 rafting game with paddle/oar controls'
$rotSet += Set-Rotation 'truck_kyosokyoku' 270 'low' 'mechanical_stop' 'inference' 'Metro/Namco 2000 truck racing with steering wheel'
$rotSet += Set-Rotation 'attack_pla_rail' 270 'low' 'mechanical_stop' 'inference' 'Namco/Tomy 1998 train-themed game'
Write-Output ""

# =============================================================================
# PHASE 15: Remove remaining misc non-driving
# =============================================================================
Write-Output "=== Phase 15: Remove remaining non-driving ==="
$removed += Remove-Entry 'super_motor_prototype' 'Duintronic prototype, unknown/unreleased'
$removed += Remove-Entry 'stunt_typhoon_plus' 'Taito jet ski stunt game - specialty controls, not wheel'
$removed += Remove-Entry 'turbosub' 'Entertainment Sciences submarine game'
Write-Output ""

# =============================================================================
# Save
# =============================================================================
$totalGames = @($db.games.PSObject.Properties).Count
$withRotation = @($db.games.PSObject.Properties | Where-Object { $null -ne $_.Value.rotation_degrees }).Count
$unknown = $totalGames - $withRotation

Write-Output "=== Final Summary ==="
Write-Output "Removals: $removed"
Write-Output "Rotation values set: $rotSet"
Write-Output "Total games now: $totalGames"
Write-Output "With rotation: $withRotation"
Write-Output "Unknown: $unknown"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Output "Database saved."
