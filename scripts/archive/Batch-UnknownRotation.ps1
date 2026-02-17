Set-StrictMode -Version Latest

# Batch resolve unknown rotation values for well-known arcade games
# Phase 1: Merge duplicates, Phase 2: Set known rotation values

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$merges = 0
$updates = 0
$today = '2026-02-17'

function Merge-IntoExisting {
    param(
        [string]$DuplicateSlug,
        [string]$TargetSlug,
        [string]$MameRomname
    )
    $dup = $db.games.$DuplicateSlug
    $target = $db.games.$TargetSlug
    if (-not $dup) { Write-Warning "Duplicate not found: $DuplicateSlug"; return }
    if (-not $target) { Write-Warning "Target not found: $TargetSlug"; return }

    # Add MAME platform to target if not already present
    if (-not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = $MameRomname
            clones_inherit = $true
        })
    } else {
        # Target already has MAME - add romname to romnames array
        $mame = $target.platforms.mame
        if ($mame.PSObject.Properties['romnames']) {
            # Already an array, add if not present
            if ($mame.romnames -notcontains $MameRomname) {
                $mame.romnames = @($mame.romnames) + $MameRomname
            }
        } elseif ($mame.PSObject.Properties['romname']) {
            if ($mame.romname -ne $MameRomname) {
                # Convert to romnames array
                $existingRom = $mame.romname
                $mame.PSObject.Properties.Remove('romname')
                $mame | Add-Member -NotePropertyName 'romnames' -NotePropertyValue @($existingRom, $MameRomname)
            }
        } else {
            $mame | Add-Member -NotePropertyName 'romname' -NotePropertyValue $MameRomname
        }
    }

    # Remove the duplicate entry
    $db.games.PSObject.Properties.Remove($DuplicateSlug)
    $script:merges++
    Write-Output "  Merged: $DuplicateSlug ($MameRomname) -> $TargetSlug"
}

function Set-Rotation {
    param(
        [string]$Slug,
        [int]$Degrees,
        [string]$RotationType = 'mechanical_stop',
        [string]$Confidence = 'medium',
        [PSCustomObject[]]$Sources,
        [string]$Notes
    )
    $g = $db.games.$Slug
    if (-not $g) { Write-Warning "Entry not found: $Slug"; return }
    if ($null -ne $g.rotation_degrees) { Write-Warning "$Slug already has rotation=$($g.rotation_degrees)"; return }

    $g.rotation_degrees = $Degrees
    if (-not $g.rotation_type) { $g.rotation_type = $RotationType }
    if ($Confidence -ne 'unknown') { $g.confidence = $Confidence }
    if ($Sources) { $g.sources = $Sources }
    if ($Notes) { $g.notes = $Notes }

    $script:updates++
    Write-Output "  Set: $Slug = ${Degrees}deg ($Confidence)"
}

# =====================================================================
Write-Output "=== Phase 1: Merge Duplicates ==="
Write-Output ""

# Hummer Extreme MAME -> hummer_extreme (TP entry)
Merge-IntoExisting -DuplicateSlug 'hummer_extreme_mame' -TargetSlug 'hummer_extreme' -MameRomname 'hummerxt'

# Sega Race-TV Export -> sega_race_tv (TP entry)
Merge-IntoExisting -DuplicateSlug 'sega_racetv_export' -TargetSlug 'sega_race_tv' -MameRomname 'segartv'

# Wangan Midnight MAME -> wangan_midnight (existing 270 high)
Merge-IntoExisting -DuplicateSlug 'wangan_midnight_wmn1_ver_a' -TargetSlug 'wangan_midnight' -MameRomname 'wanganmd'

# Wangan Midnight R MAME -> wangan_midnight_r (existing 270 high)
Merge-IntoExisting -DuplicateSlug 'wangan_midnight_r_wmr1_ver_a' -TargetSlug 'wangan_midnight_r' -MameRomname 'wanganmr'

# OutRun 2 Special Tours MAME -> outrun2_sp_sdx (existing 270 verified)
Merge-IntoExisting -DuplicateSlug 'outrun_2_special_tours' -TargetSlug 'outrun2_sp_sdx' -MameRomname 'outr2st'

# Manx TT Superbike DX -> manxttsuperbike (add DX romname)
Merge-IntoExisting -DuplicateSlug 'manx_tt_superbike__dx_revision_d' -TargetSlug 'manxttsuperbike' -MameRomname 'manxtt'

# =====================================================================
Write-Output ""
Write-Output "=== Phase 2: Consolidate Club Kart variants ==="
Write-Output ""

# Collect all Club Kart MAME romnames, merge into one entry
$clubKartSlugs = @(
    'club_kart_european_session_2003_rev_a',  # clubk2k3
    'club_kart_for_cycraft',                   # clubkcyc
    'club_kart_prize_export_japan_rev_a',      # clubkprz
    'club_kart_prize_version_b_export_japan',  # clubkpzb
    'club_kart_european_session'               # clubkrt
)
# Check for clubkpzbp too
if ($db.games.PSObject.Properties['clubkpzbp']) {
    $clubKartSlugs += 'clubkpzbp'
}

# Collect romnames
$ckRoms = [System.Collections.ArrayList]::new()
$clubKartSlugs | ForEach-Object {
    $g = $db.games.$_
    if ($g -and $g.platforms.PSObject.Properties['mame']) {
        $rom = if ($g.platforms.mame.PSObject.Properties['romname']) { $g.platforms.mame.romname } else { $_ }
        if ($ckRoms -notcontains $rom) { [void]$ckRoms.Add($rom) }
    }
    # Remove duplicate entry
    if ($db.games.PSObject.Properties[$_]) {
        $db.games.PSObject.Properties.Remove($_)
        $merges++
        Write-Output "  Removed Club Kart variant: $_"
    }
}

# Create consolidated Club Kart entry
$db.games | Add-Member -NotePropertyName 'club_kart' -NotePropertyValue ([PSCustomObject]@{
    title = 'Club Kart'
    manufacturer = 'Sega'
    developer = $null
    publisher = $null
    year = '2001'
    rotation_degrees = 270
    rotation_type = 'mechanical_stop'
    confidence = 'high'
    sources = @(
        [PSCustomObject]@{
            type = 'parts'
            description = 'SuzoHapp 5K potentiometer (220-5373) explicitly lists Club Kart as compatible. Standard Sega NAOMI driving cabinet.'
            url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
            date_accessed = $today
        }
    )
    notes = 'Sega NAOMI hardware. Multiple variants: European Session, Prize, Cycraft. All share the same standard Sega 270-degree steering assembly.'
    pc = $null
    platforms = [PSCustomObject]@{
        mame = [PSCustomObject]@{
            romnames = @($ckRoms)
            clones_inherit = $true
        }
    }
})
$updates++
Write-Output "  Created: club_kart with $($ckRoms.Count) romnames = 270deg (high)"

# =====================================================================
Write-Output ""
Write-Output "=== Phase 3: Set Known Sega Rotation Values ==="
Write-Output ""

# --- F355 Challenge family (NAOMI, SuzoHapp listed) ---
$f355Source = @([PSCustomObject]@{
    type = 'parts'
    description = 'SuzoHapp 5K potentiometer (220-5373) explicitly lists F355 Challenge as compatible. Standard Sega NAOMI driving assembly.'
    url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
    date_accessed = $today
})

Set-Rotation -Slug 'ferrari_f355_challenge_deluxe_no_link' -Degrees 270 -Confidence 'high' -Sources $f355Source -Notes 'Sega NAOMI hardware. Deluxe cabinet (no network link). Same steering assembly as all Sega 270-degree racers.'
Set-Rotation -Slug 'ferrari_f355_challenge_twindeluxe' -Degrees 270 -Confidence 'high' -Sources $f355Source -Notes 'Sega NAOMI hardware. Twin/Deluxe cabinet. Same steering assembly as all Sega 270-degree racers.'
Set-Rotation -Slug 'ferrari_f355_challenge_2__international_' -Degrees 270 -Confidence 'high' -Sources $f355Source -Notes 'Sega NAOMI hardware. Challenge 2 International Course Edition. Same steering assembly.'

# --- OutRun 2 (Chihiro, separate from OutRun 2 SP) ---
Set-Rotation -Slug 'outrun_2' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
    type = 'parts'
    description = 'SuzoHapp 5K potentiometer (220-5373) lists OutRun 2 as compatible. Sega Chihiro (Xbox-based) hardware.'
    url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
    date_accessed = $today
}) -Notes 'Sega Chihiro hardware. Original OutRun 2 (not SP/Special Tours).'

# --- Sega Touring Car Championship (Model 2) ---
Set-Rotation -Slug 'sega_touring_car_championship' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 2 hardware. All Model 2 racers share the SPG-2002 steering assembly with 270-degree range. Same hardware as Daytona USA, Sega Rally Championship.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 2 hardware.'

# --- King of Route 66 (Chihiro) ---
Set-Rotation -Slug 'the_king_of_route_66' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Chihiro hardware with standard Sega 270-degree steering assembly. Same platform and steering mechanism as OutRun 2.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Chihiro hardware. Truck racing game.'

# --- Star Wars Racer Arcade (Model 3 hardware) ---
Set-Rotation -Slug 'star_wars_racer_arcade' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 3 hardware. Uses standard Sega 270-degree steering mechanism in podracer-themed handlebar housing.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 3 Step 2.1. Podracer-themed controls.'

# --- Indy 500 Twin (Model 2) ---
Set-Rotation -Slug 'indy_500_twin_revision_a_newer' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 2 hardware with standard Sega SPG-2002 steering assembly.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 2 hardware. Indy car racing.'

# --- Ring Out 4x4 (Model 3) ---
Set-Rotation -Slug 'ring_out_4x4' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 3 hardware with standard Sega 270-degree steering assembly.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 3 hardware. Off-road SUV combat racing.'

# --- Rad Mobile (Y-Board, 1990) ---
Set-Rotation -Slug 'rad_mobile' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Y-Board hardware. Sega driving games from this era used 270-degree steering assemblies.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Y-Board hardware. Deluxe sit-down cabinet with force feedback.'

# --- Rad Rally (Y-Board, 1991) ---
Set-Rotation -Slug 'rad_rally' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Y-Board hardware. Sequel to Rad Mobile, same cabinet and steering assembly.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Y-Board hardware. Rally racing sequel to Rad Mobile.'

# --- F1 Super Lap (Model 1, 1993) ---
Set-Rotation -Slug 'f1_super_lap' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 1 hardware. Same platform as Virtua Racing (verified 270 degrees).'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 1 hardware. Formula 1 racing.'

# --- Rough Racer (System 32, 1990) ---
Set-Rotation -Slug 'rough_racer' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega System 32 hardware. Inference from Sega standard steering assembly of the era.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega System 32 hardware. Rally racing.'

# --- Power Sled (Model 2, 1996) ---
Set-Rotation -Slug 'power_sled_slave_revision_a' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 2 hardware. Snowmobile game with handlebar controls. Inference from Model 2 steering standard.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 2 hardware. Snowmobile racing with handlebars.'

# --- Wave Runner (Model 2, 1996) ---
Set-Rotation -Slug 'wave_runner' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sega Model 2 hardware. Jet ski game with handlebar controls. Inference from Model 2 platform standard.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Model 2 hardware. Jet ski racing with handlebar controls.'

# =====================================================================
Write-Output ""
Write-Output "=== Phase 4: Set Known Namco Rotation Values ==="
Write-Output ""

$namcoSource = @([PSCustomObject]@{
    type = 'parts'
    description = 'Namco standard 1K ohm 270-degree potentiometer (VG75-07050-00 / DE475-15417-00). Confirmed by Final Lap 3 operator manual.'
    url = $null
    date_accessed = $today
})

# --- Ridge Racer 2 (System 22) ---
Set-Rotation -Slug 'ridge_racer_2_rev_rrs2_world' -Degrees 270 -Confidence 'high' -Sources $namcoSource -Notes 'Namco System 22 hardware. Same steering assembly as Ridge Racer.'

# --- Ridge Racer V Arcade Battle (System 246) ---
Set-Rotation -Slug 'ridge_racer_v_arcade_battle_rrv3_ver_a' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Namco System 246 hardware. Same Namco 270-degree potentiometer standard used across System 21/22/246.'
    url = $null
    date_accessed = $today
}) -Notes 'Namco System 246 hardware.'

# --- Final Lap (System 2, 1987) ---
Set-Rotation -Slug 'final_lap' -Degrees 270 -Confidence 'high' -Sources $namcoSource -Notes 'Namco System 2 hardware. First game in the Final Lap series. Same pot as Final Lap 3 (confirmed by operator manual).'

# --- Final Lap R (System FL, 1995) ---
Set-Rotation -Slug 'final_lap_r_rev_b' -Degrees 270 -Confidence 'high' -Sources $namcoSource -Notes 'Namco System FL hardware. Final installment of Final Lap series.'

# --- Winning Run 91 (System 21, 1991) ---
Set-Rotation -Slug 'winning_run_91' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Namco System 21 hardware. Uses Namco standard 270-degree potentiometer.'
    url = $null
    date_accessed = $today
}) -Notes 'Namco System 21 hardware. Early polygon racer.'

# --- Wangan Midnight Maximum Tune (GD-X / Chihiro) ---
Set-Rotation -Slug 'wangan_midnight_maximum_tune_export_rev_' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Same series as WMMT3-6RR (all verified 270 degrees from TeknoParrot metadata). First WMMT installment uses the same Namco racing cabinet.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Chihiro hardware (Namco game). First WMMT installment.'

# --- Wangan Midnight Maximum Tune 2 (GD-X) ---
Set-Rotation -Slug 'wangan_midnight_maximum_tune_2_export_re' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Same series as WMMT3-6RR (all verified 270 degrees from TeknoParrot metadata). WMMT2 uses the same Namco racing cabinet.'
    url = $null
    date_accessed = $today
}) -Notes 'Sega Chihiro hardware (Namco game). Second WMMT installment.'

# --- Cyber Cycles (System 22, motorcycle) ---
Set-Rotation -Slug 'cyber_cycles_rev_cb2_verc_world' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Namco System 22 hardware. Motorcycle racing with handlebar controls. Inference from Namco platform standard.'
    url = $null
    date_accessed = $today
}) -Notes 'Namco System 22 hardware. Futuristic motorcycle racing.'

# --- Race On! (System 23?) ---
Set-Rotation -Slug 'race_on' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Namco System 23 hardware. Inference from Namco 270-degree steering standard.'
    url = $null
    date_accessed = $today
}) -Notes 'Namco System 23 hardware.'

# --- Kart Duel ---
Set-Rotation -Slug 'kart_duel' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Namco arcade go-kart racing. Inference from Namco standard steering.'
    url = $null
    date_accessed = $today
}) -Notes 'Namco hardware. Go-kart racing.'

# =====================================================================
Write-Output ""
Write-Output "=== Phase 5: Handle junk/non-driving entries ==="
Write-Output ""

# Remove entries that are clearly not driving games with wheel/steering controls
$nonDriving = @(
    'dottori_kun_new_version',  # Simple dot game, not driving
    'borderline',              # Border patrol maze game
    'regulus_3155033_rev_a',   # Space shooter
    'spatter_3155xxx',         # Crush Roller variant (maze game)
    'super_locomotive_reva',   # Train game with throttle only
    'assault',                 # Twin-stick tank game (no steering wheel)
    'cyber_sled_cy2_world',   # Twin-stick mech combat (no steering wheel)
    'burning_force',           # Ride-on shooter (throttle + lean, no wheel)
    'blazer'                   # Vertical scrolling shooter
)

$nonDriving | ForEach-Object {
    if ($db.games.PSObject.Properties[$_]) {
        $title = $db.games.$_.title
        $db.games.PSObject.Properties.Remove($_)
        $merges++
        Write-Output "  Removed non-driving: $_ ($title)"
    }
}

# Also remove junk entries (raw romname slugs)
$junkSlugs = @('clubkpzbp', 'outrundxeha', 'outruneha')
$junkSlugs | ForEach-Object {
    if ($db.games.PSObject.Properties[$_]) {
        $db.games.PSObject.Properties.Remove($_)
        $merges++
        Write-Output "  Removed junk slug: $_"
    }
}

# =====================================================================
Write-Output ""
Write-Output "=== Summary ==="
$json = $db | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($dbPath, $json)
$totalGames = @($db.games.PSObject.Properties).Count
Write-Output "Merges/removals: $merges"
Write-Output "Rotation values set: $updates"
Write-Output "Total games now: $totalGames"
Write-Output "Saved to $dbPath"
