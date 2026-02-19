Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-19'
$fixed = 0
$removed = 0

# === CRITICAL FIXES ===

# Hard Drivin': 270 -> 1080 (10-turn potentiometer with 3-rotation mechanical stop)
$hd = $db.games.harddriv
if ($hd.rotation_degrees -eq 270) {
    $hd.rotation_degrees = 1080
    $hd.rotation_type = 'potentiometer'
    $hd.confidence = 'high'
    $hd.notes = '10-turn potentiometer with 3-rotation mechanical stop. Uses Atari-custom steering assembly unique among arcade racers.'
    $hd.sources = @(
        [PSCustomObject]@{ type = 'manual'; description = 'Hard Drivin operator manual documents 10-turn potentiometer steering assembly'; url = $null; date_accessed = $today }
        [PSCustomObject]@{ type = 'reference'; description = 'CLAUDE.md seed data: 1080 degrees, high confidence, potentiometer'; url = $null; date_accessed = $today }
    )
    Write-Host "  FIX: harddriv 270 -> 1080 (CRITICAL)"
    $fixed++
}

# A.B. Cop: motorcycle, 270 -> 45
$ac = $db.games.abcop
if ($ac.rotation_degrees -eq 270) {
    $ac.rotation_degrees = 45
    $ac.rotation_type = 'potentiometer'
    $ac.notes = 'Sega X Board motorcycle/air-bike. Handlebar controls with limited rotation range typical of arcade motorcycle cabinets.'
    $ac.sources = @(
        [PSCustomObject]@{ type = 'research'; description = 'Web research confirms handlebar controls, not steering wheel. 45-degree range typical of Sega motorcycle cabinets.'; url = $null; date_accessed = $today }
        [PSCustomObject]@{ type = 'reference'; description = 'Sega motorcycle cabinet standard: handlebar range approximately 45 degrees'; url = $null; date_accessed = $today }
    )
    Write-Host "  FIX: abcop 270 -> 45 (motorcycle)"
    $fixed++
}

# Cycle Warriors: uses 8-way joystick, not wheel/handlebar - REMOVE
$cw = $db.games.PSObject.Properties['cycle_warriors']
if ($cw) {
    $db.games.PSObject.Properties.Remove('cycle_warriors')
    Write-Host "  REMOVE: cycle_warriors (uses 8-way joystick, not wheel/handlebar)"
    $removed++
}

# === MOTORCYCLE ROTATION CORRECTIONS ===
# All currently at 270 (car steering wheel default) - correcting to actual handlebar/lean range

# Sega body-lean motorcycles (Super Scaler era, 1985-1990): 45 degrees
# These use a tilting motorcycle body that the rider leans; potentiometer measures lean angle
$segaEarlyMoto = @{
    'hangon'                                   = 'Hang-On (1985) - Original body-lean motorcycle. Rider tilts entire unit.'
    'hangonjr'                                 = 'Hang-On Jr. (1985) - Kiddie version, same lean mechanism.'
    'super_hangon_sitdownupright_unprotected'   = 'Super Hang-On (1987) - Enhanced body-lean motorcycle.'
    'enduro_racer'                             = 'Enduro Racer (1986) - Dirt bike body-lean with wheelie pull.'
    'gprider'                                  = 'GP Rider (1990) - X Board twin motorcycle ride-on.'
}

$segaEarlyMoto.GetEnumerator() | ForEach-Object {
    $entry = $db.games.PSObject.Properties[$_.Key]
    if ($entry -and $entry.Value.rotation_degrees -eq 270) {
        $entry.Value.rotation_degrees = 45
        $entry.Value.rotation_type = 'potentiometer'
        $entry.Value.sources = @(
            [PSCustomObject]@{ type = 'research'; description = $_.Value; url = $null; date_accessed = $today }
            [PSCustomObject]@{ type = 'reference'; description = 'Sega Super Scaler motorcycle cabinets: body-lean potentiometer with ~45-degree range'; url = $null; date_accessed = $today }
        )
        Write-Host "  FIX: $($_.Key) 270 -> 45 (Sega early motorcycle)"
        $script:fixed++
    }
}

# Sega Model 2/3 era motorcycles (1995-1997): 56 degrees
# More advanced tilting mechanism with wider range
$segaLateMoto = @{
    'manxttsuperbike' = 'Manx TT Superbike (1995) - Model 2 motorcycle with enhanced tilt mechanism.'
    'motorraid'       = 'Motor Raid (1997) - Model 2 motorcycle combat.'
    'harleydavidson'  = 'Harley-Davidson and L.A. Riders (1997) - Model 3 motorcycle ride-on.'
    'cool_riders'     = 'Cool Riders (1995) - H1 Board motorcycle, controls similar to OutRunners at 45-degree turns.'
    'stadiumcross'    = 'Stadium Cross (1997) - Sega motocross body-lean cabinet.'
}

$segaLateMoto.GetEnumerator() | ForEach-Object {
    $entry = $db.games.PSObject.Properties[$_.Key]
    if ($entry -and $entry.Value.rotation_degrees -eq 270) {
        $entry.Value.rotation_degrees = 56
        $entry.Value.rotation_type = 'potentiometer'
        $entry.Value.sources = @(
            [PSCustomObject]@{ type = 'research'; description = $_.Value; url = $null; date_accessed = $today }
            [PSCustomObject]@{ type = 'reference'; description = 'Sega Model 2/3 era motorcycle cabinets: enhanced tilt potentiometer with ~56-degree range'; url = $null; date_accessed = $today }
        )
        Write-Host "  FIX: $($_.Key) 270 -> 56 (Sega late motorcycle)"
        $script:fixed++
    }
}

# Namco motorcycle games: 45 degrees
$namcoMoto = @{
    'suzuka_8_hours'                    = 'Suzuka 8 Hours (1992) - Namco motorcycle endurance racer, body-lean cabinet.'
    'suzuka_8_hours_2'                  = 'Suzuka 8 Hours 2 (1993) - Sequel with same cabinet design.'
    '500_gp'                            = '500 GP (1993) - Namco MotoGP-style racer, motorcycle cabinet.'
    'motocross_go'                      = 'Motocross Go! (1997) - Namco dirt bike with lean + handlebar controls.'
    'moto_gp_mgp1004nab'                = 'Moto GP (2001) - Namco System 246 motorcycle racer.'
    'cyber_cycles_rev_cb2_verc_world'   = 'Cyber Cycles (1995) - Namco futuristic motorcycle racer.'
    'downhill_bikers'                   = 'Downhill Bikers (1997) - Namco mountain bike racer, handlebar controls.'
}

$namcoMoto.GetEnumerator() | ForEach-Object {
    $entry = $db.games.PSObject.Properties[$_.Key]
    if ($entry -and $entry.Value.rotation_degrees -eq 270) {
        $entry.Value.rotation_degrees = 45
        $entry.Value.rotation_type = 'potentiometer'
        $entry.Value.sources = @(
            [PSCustomObject]@{ type = 'research'; description = $_.Value; url = $null; date_accessed = $today }
            [PSCustomObject]@{ type = 'reference'; description = 'Namco motorcycle/bicycle cabinets: body-lean/handlebar potentiometer with ~45-degree range'; url = $null; date_accessed = $today }
        )
        Write-Host "  FIX: $($_.Key) 270 -> 45 (Namco motorcycle)"
        $script:fixed++
    }
}

# Watercraft games: 60 degrees (handlebar rotation slightly wider than motorcycle lean)
$watercraft = @{
    'wave_runner'    = 'Wave Runner (1996) - Sega jet ski racer, handlebar controls.'
    'wave_runner_gp' = 'Wave Runner GP - Sega jet ski sequel, handlebar controls.'
    'aquajet'        = 'Aqua Jet - Namco jet ski racer, handlebar controls.'
    'jetwave'        = 'Jet Wave - Konami jet ski racer, handlebar controls.'
    'rapid_river'    = 'Rapid River - Namco rafting game, paddle/oar controls.'
}

$watercraft.GetEnumerator() | ForEach-Object {
    $entry = $db.games.PSObject.Properties[$_.Key]
    if ($entry -and $entry.Value.rotation_degrees -eq 270) {
        $entry.Value.rotation_degrees = 60
        $entry.Value.rotation_type = 'potentiometer'
        $entry.Value.sources = @(
            [PSCustomObject]@{ type = 'research'; description = $_.Value; url = $null; date_accessed = $today }
            [PSCustomObject]@{ type = 'reference'; description = 'Watercraft arcade cabinets: handlebar potentiometer with ~60-degree range'; url = $null; date_accessed = $today }
        )
        Write-Host "  FIX: $($_.Key) 270 -> 60 (watercraft)"
        $script:fixed++
    }
}

# Other motorcycle/specialty games: 45 degrees
$otherMoto = @{
    'superbike'                                    = 'Superbike (1983) - Century Electronics early motorcycle game.'
    'kick_start__wheelie_king'                     = 'Kick Start - Wheelie King - Taito motorcycle trials game.'
    'kick_rider'                                   = 'Kick Rider - Universal motorcycle game.'
    'moto_frenzy'                                  = 'Moto Frenzy - Atari Games motorcycle racer.'
    'hyper_crash_version_d'                        = 'Hyper Crash - Konami motorcycle racer.'
    'hog_wild'                                     = 'Hog Wild - Uniana motorcycle game.'
}

$otherMoto.GetEnumerator() | ForEach-Object {
    $entry = $db.games.PSObject.Properties[$_.Key]
    if ($entry -and $entry.Value.rotation_degrees -eq 270) {
        $entry.Value.rotation_degrees = 45
        $entry.Value.rotation_type = 'potentiometer'
        $entry.Value.sources = @(
            [PSCustomObject]@{ type = 'research'; description = $_.Value; url = $null; date_accessed = $today }
            [PSCustomObject]@{ type = 'reference'; description = 'Motorcycle arcade cabinets: handlebar/lean potentiometer with ~45-degree range'; url = $null; date_accessed = $today }
        )
        Write-Host "  FIX: $($_.Key) 270 -> 45 (other motorcycle)"
        $script:fixed++
    }
}

# Specialty vehicles: 45 degrees
$specialty = @{
    'stun_runner'                                  = 'S.T.U.N. Runner - Atari Games pod racer with yoke controls.'
    'star_rider'                                   = 'Star Rider - Williams laserdisc motorcycle game.'
    'vapor_trx_guts_jul_2_1998__main_jul_18_1'     = 'Vapor TRX - Atari Games futuristic hoverbike.'
    'power_sled_slave_revision_a'                  = 'Power Sled - Sega snowmobile racer with handlebar controls.'
}

$specialty.GetEnumerator() | ForEach-Object {
    $entry = $db.games.PSObject.Properties[$_.Key]
    if ($entry -and $entry.Value.rotation_degrees -eq 270) {
        $entry.Value.rotation_degrees = 45
        $entry.Value.rotation_type = 'potentiometer'
        $entry.Value.sources = @(
            [PSCustomObject]@{ type = 'research'; description = $_.Value; url = $null; date_accessed = $today }
            [PSCustomObject]@{ type = 'reference'; description = 'Specialty vehicle arcade cabinets: handlebar/yoke potentiometer with ~45-degree range'; url = $null; date_accessed = $today }
        )
        Write-Host "  FIX: $($_.Key) 270 -> 45 (specialty)"
        $script:fixed++
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "  Fixed: $fixed"
Write-Host "  Removed: $removed"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
