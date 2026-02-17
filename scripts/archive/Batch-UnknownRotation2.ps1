Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$removals = 0
$updates = 0
$today = '2026-02-17'

function Set-Rotation {
    param([string]$Slug, [int]$Degrees, [string]$RotationType = 'mechanical_stop',
          [string]$Confidence = 'medium', [PSCustomObject[]]$Sources, [string]$Notes)
    $g = $db.games.$Slug
    if (-not $g) { Write-Warning "Not found: $Slug"; return }
    if ($null -ne $g.rotation_degrees) { Write-Warning "$Slug already has rotation=$($g.rotation_degrees)"; return }
    $g.rotation_degrees = $Degrees
    if (-not $g.rotation_type) { $g.rotation_type = $RotationType }
    if ($Confidence -ne 'unknown') { $g.confidence = $Confidence }
    if ($Sources) { $g.sources = $Sources }
    if ($Notes) { $g.notes = $Notes }
    $script:updates++
    Write-Output "  Set: $Slug = ${Degrees}deg ($Confidence)"
}

function Remove-Entry {
    param([string]$Slug, [string]$Reason)
    if ($db.games.PSObject.Properties[$Slug]) {
        $db.games.PSObject.Properties.Remove($Slug)
        $script:removals++
    }
}

# =====================================================================
Write-Output "=== Phase 1: Remove MAME clone entries (null manufacturer) ==="
Write-Output ""

# These are MAME clones imported with romname-as-slug and no metadata.
# Parent entries have clones_inherit=true so clones don't need separate entries.
$cloneCount = 0
$db.games.PSObject.Properties | Where-Object {
    $g = $_.Value
    $null -eq $g.manufacturer -and
    $null -eq $g.rotation_degrees -and
    $g.platforms.PSObject.Properties['mame'] -and
    @($g.platforms.PSObject.Properties).Count -eq 1  # MAME-only
} | ForEach-Object {
    $slug = $_.Name
    Remove-Entry -Slug $slug -Reason 'MAME clone with no metadata'
    $cloneCount++
}
Write-Output "  Removed $cloneCount MAME clone entries"

# =====================================================================
Write-Output ""
Write-Output "=== Phase 2: Remove non-driving/non-wheel games ==="
Write-Output ""

$nonDriving = @(
    # Shooters/action games with paddle/dial controls but no steering wheel
    'paperboy',             # Bicycle newspaper delivery (handlebars, unique control)
    'jackal',               # Konami jeep with joystick
    'vindictr',             # Atari tank with twin sticks
    'vindctr2',             # Atari tank with twin sticks
    'bzone',                # Atari tank with twin sticks
    'bradley',              # Military tank trainer
    'jedi',                 # Star Wars space shooter
    'llander',              # Lunar Lander
    'mpatrol',              # Moon Patrol side-scroller
    'lastduel',             # Capcom vertical shooter
    'madgear',              # Capcom scrolling shooter
    'srumbler',             # Speed Rumbler vertical shooter
    'plygonet',             # Polygonet Commanders mech combat
    'stratgyx',             # Strategy X maze game
    'megazone',             # Mega Zone scrolling shooter
    'valtric',              # Side-scrolling shooter
    'tndrcade',             # Thundercade vertical shooter
    'battlane',             # Battle Lane vertical shooter
    'madcrash',             # Mad Crasher vertical action
    'tnk3',                 # TNK III tank game
    'ridhero',              # Riding Hero Neo Geo (joystick, not wheel)
    'seicross',             # Side-scrolling motorcycle action
    'overtop',              # Over Top Neo Geo (joystick, not wheel)
    'progress',             # Scrolling shooter
    'jcross',               # Jumping Cross action
    'joyfulr',              # Joyful Road scrolling action
    'minefld',              # Minefield overhead action
    'galastrm',             # Galactic Storm space shooter
    'mofflott',             # Maze of Flott maze game
    'pitnrun',              # Pit & Run platformer
    'road_fighter',         # Konami Road Fighter (joystick, not wheel)
    'fast_lane',            # Konami Fast Lane (trackball game)
    'battroad',             # Irem Battle-Road (joystick)
    'horizon',              # Irem Horizon (joystick)
    'radrad',               # Radical Radial (dial/spinner game, not driving)
    'shtrider',             # Shot Rider (joystick shooter)
    'clshroad',             # Clash-Road (joystick)
    'carjmbre',             # Car Jamboree (joystick)
    'rpatrol',              # River Patrol (joystick)
    'bounty',               # The Bounty (joystick)
    'dodgem',               # Dodgem (joystick)
    'ar_rdwr',              # RoadWars Arcadia (joystick)
    'strtheat',             # Street Heat (joystick)
    'flagrall',             # 96 Flag Rally (joystick)
    'blmbycar',             # Blomby Car (joystick)
    'warpsped',             # Warp Speed (joystick)
    'ppcar',                # Pang Pang Car (kiddie ride)
    'chamrx1',              # Chameleon RX-1 (joystick)
    'sprcros2',             # Super Cross II (joystick)
    'gekisou',              # Gekisou (joystick)
    'f1dream',              # F-1 Dream (joystick)
    'kamenrid',             # Masked Riders Club (joystick)
    'rallybik',             # Rally Bike / Dash Yarou (joystick)

    # Flight sims (yoke/joystick, not steering wheel)
    'airline_pilots',
    'airline_pilots_mame',
    'topland',              # Top Landing flight sim
    'mlanding',             # Midnight Landing flight sim
    'landgear',             # Landing Gear flight sim
    'landhigh',             # Landing High flight sim
    'air_race_prototype',   # Atari Air Race

    # Train sims (throttle/brake only, no steering)
    'densha_de_go',
    'densha_de_go_2_kousokuhen',
    'densha_de_go_3_tsukinhen_v203j',
    'gobyrc',               # Go By RC (RC train)

    # Fitness equipment (not games)
    'sltpcycl',             # Salter Fitness Bike
    'sltpstep',             # Salter Fitness Stepper

    # Kiddie rides / toys
    'waku_waku_sonic_patrol_car',  # Sonic kiddie ride
    'hashire_patrol_car_j_990326_v1000',  # Patrol Car kiddie ride
    'aplarail',             # Attack Pla Rail toy train

    # Console ports on generic hardware (no dedicated wheel)
    'out_run_megatech_sms_based',
    'super_hangon_megatech',
    'super_monaco_gp_megatech',
    'turbo_outrun_megatech',
    'excitebk',             # VS Excitebike (NES on VS System)
    'nss_fzer',             # F-Zero on Nintendo Super System
    'pc_ebike',             # Excite Bike PlayChoice-10
    'pc_radr2',             # Rad Racer II PlayChoice-10
    'pc_radrc',             # Rad Racer PlayChoice-10
    'pc_rcpam',             # R.C. Pro-Am PlayChoice-10

    # Misc non-wheel
    'vcombat',              # Virtual Combat (VR mech game)
    'spcpostn',             # Space Position (space game)
    'aurail',               # Aurail (side-scrolling shooter)
    'nstocker',             # Night Stocker (gun game with steering)
    'desert',               # Desert Tank (military sim)
    'tankbatl',             # Tank Battle (military sim)
    'ucytokyu'              # Uchuu Tokkyuu Medalian (medal game)
)

$removedCount = 0
$nonDriving | ForEach-Object {
    if ($db.games.PSObject.Properties[$_]) {
        Remove-Entry -Slug $_ -Reason 'Not a wheel/driving game'
        $removedCount++
    }
}
Write-Output "  Removed $removedCount non-driving/non-wheel entries"

# =====================================================================
Write-Output ""
Write-Output "=== Phase 3: Merge duplicate Sega entries ==="
Write-Output ""

# Airline Pilots duplicates already removed above
# Crazy Taxi High Roller -> set value (Sega Chihiro, same as Crazy Taxi)
if ($db.games.PSObject.Properties['crazy_taxi_high_roller']) {
    Set-Rotation -Slug 'crazy_taxi_high_roller' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
        type = 'parts'
        description = 'SuzoHapp 5K potentiometer (220-5373) lists Crazy Taxi as compatible. High Roller uses same Chihiro hardware and cabinet.'
        url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
        date_accessed = $today
    }) -Notes 'Sega Chihiro hardware. Sequel to Crazy Taxi using same cabinet.'
}

# NASCAR Racing (Sega/EA, Chihiro)
if ($db.games.PSObject.Properties['nascar_racing']) {
    Set-Rotation -Slug 'nascar_racing' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
        type = 'parts'
        description = 'SuzoHapp 5K potentiometer (220-5373) lists NASCAR as compatible. Standard Sega driving cabinet.'
        url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
        date_accessed = $today
    }) -Notes 'Sega Chihiro hardware. EA NASCAR license.'
}

# Wild Riders (Sega, NAOMI 2)
if ($db.games.PSObject.Properties['wild_riders']) {
    Set-Rotation -Slug 'wild_riders' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
        type = 'parts'
        description = 'SuzoHapp 5K potentiometer (220-5373) lists Wild Riders as compatible.'
        url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
        date_accessed = $today
    }) -Notes 'Sega NAOMI 2 hardware. Motorcycle game but with steering wheel controls.'
}

# Wave Runner GP (Sega, NAOMI 2)
if ($db.games.PSObject.Properties['wave_runner_gp']) {
    Set-Rotation -Slug 'wave_runner_gp' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
        type = 'inference'
        description = 'Sega NAOMI 2 hardware. Jet ski sequel to Wave Runner. Inference from Sega platform standard.'
        url = $null
        date_accessed = $today
    }) -Notes 'Sega NAOMI 2 hardware. Jet ski racing.'
}

# Choro Q Hyper Racing 5 (Sega/Takara, NAOMI)
if ($db.games.PSObject.Properties['choro_q_hyper_racing_5_j_981230_v1000']) {
    Set-Rotation -Slug 'choro_q_hyper_racing_5_j_981230_v1000' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
        type = 'inference'
        description = 'Sega NAOMI hardware. Inference from standard Sega driving cabinet.'
        url = $null
        date_accessed = $today
    }) -Notes 'Sega NAOMI hardware. Choro Q toy car racing.'
}

# Sega NetMerc (unknown game, 1993)
# Heavy Metal (1985) - Sega hang glider game, not a driving game
if ($db.games.PSObject.Properties['heavy_metal_3155135']) {
    Remove-Entry -Slug 'heavy_metal_3155135' -Reason 'Hang glider game, not driving'
    $removedCount++
    Write-Output "  Removed: heavy_metal_3155135 (hang glider game)"
}

# =====================================================================
Write-Output ""
Write-Output "=== Phase 4: Set Konami Racing Games ==="
Write-Output ""

# Chase H.Q. (Taito Japan, 1988) - 270 from Taito standard
Set-Rotation -Slug 'chase_hq' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito Z-System hardware. Standard arcade racing cabinet with 270-degree steering.'
    url = $null; date_accessed = $today
}) -Notes 'Taito Z-System hardware. Police chase racing.'

# SCI Special Criminal Investigation (Taito, 1989)
Set-Rotation -Slug 'special_criminal_investigation' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito Z-System hardware. Sequel to Chase H.Q., same cabinet design.'
    url = $null; date_accessed = $today
}) -Notes 'Taito Z-System hardware. Chase H.Q. sequel.'

# Super Chase Criminal Termination (Taito, 1992)
Set-Rotation -Slug 'super_chase__criminal_termination' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito hardware. Third in Chase H.Q. series, same cabinet lineage.'
    url = $null; date_accessed = $today
}) -Notes 'Taito hardware. Chase H.Q. series third entry.'

# Ground Effects / Super Ground Effects (Taito, 1992)
Set-Rotation -Slug 'ground_effects__super_ground_effects' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito hardware. Standard 270-degree arcade racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Taito hardware. F1-style racing.'

# World Grand Prix (Taito, 1989)
Set-Rotation -Slug 'world_grand_prix' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito Z-System hardware. Standard Taito racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Taito Z-System hardware. Formula racing.'

# Racing Beat (Taito, 1991)
Set-Rotation -Slug 'racing_beat' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito hardware. Standard racing cabinet. Limited documentation available.'
    url = $null; date_accessed = $today
}) -Notes 'Taito hardware.'

# GTI Club (Konami, 1996)
Set-Rotation -Slug 'gti_club' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami racing cabinet. Standard 270-degree steering assembly.'
    url = $null; date_accessed = $today
}) -Notes 'Konami GV System hardware.'

# GTI Club Corso Italiano (Konami, 2001)
Set-Rotation -Slug 'gti_club_corso_italiano' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami Viper hardware. Same GTI Club cabinet lineage.'
    url = $null; date_accessed = $today
}) -Notes 'Konami Viper hardware. GTI Club sequel.'

# Winding Heat (Konami, 1996)
Set-Rotation -Slug 'winding_heat_eaa_euro_v211' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami GV System hardware. Standard Konami 270-degree racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Konami GV System hardware.'

# Midnight Run Road Fighter 2 (Konami, 1995)
Set-Rotation -Slug 'midnight_run_road_fighter_2_eaa_euro_v11' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami GX hardware. Standard racing cabinet with 270-degree steering.'
    url = $null; date_accessed = $today
}) -Notes 'Konami GX hardware.'

# Racin Force (Konami, 1994)
Set-Rotation -Slug 'racin_force' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami GX hardware. Standard Konami racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Konami GX hardware.'

# Thrill Drive (Konami, 1998)
Set-Rotation -Slug 'thrill_drive_jae' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami Hornet hardware. Standard 270-degree racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Konami Hornet hardware.'

# Thrill Drive 2 (Konami, 2001)
Set-Rotation -Slug 'thrill_drive_2' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami Viper hardware. Same Thrill Drive cabinet lineage.'
    url = $null; date_accessed = $today
}) -Notes 'Konami Viper hardware.'

# Racing Jam (Konami, 1998)
Set-Rotation -Slug 'racing_jam_jac' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami NWK-TR hardware. Standard Konami 270-degree racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Konami NWK-TR hardware.'

# Racing Jam DX (Konami, 1997)
Set-Rotation -Slug 'racing_jam_dx' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Konami NWK-TR hardware. Deluxe version of Racing Jam, same steering.'
    url = $null; date_accessed = $today
}) -Notes 'Konami NWK-TR hardware.'

# =====================================================================
Write-Output ""
Write-Output "=== Phase 5: Set Atari/Midway Racing Games ==="
Write-Output ""

# San Francisco Rush series (Atari Games, 270 from SuzoHapp Active 270)
$rushSource = @([PSCustomObject]@{
    type = 'parts'
    description = 'Atari Games racing cabinets use SuzoHapp Active 270 steering assembly. Confirmed by parts catalogs.'
    url = 'https://na.suzohapp.com/products/driving_controls/50-4041-90'
    date_accessed = $today
})
Set-Rotation -Slug 'san_francisco_rush_boot_rom_l_10' -Degrees 270 -Confidence 'high' -Sources $rushSource -Notes 'Atari Games hardware. SuzoHapp Active 270 steering.'
Set-Rotation -Slug 'san_francisco_rush_the_rock_boot_rom_l_1' -Degrees 270 -Confidence 'high' -Sources $rushSource -Notes 'Atari Games hardware. Rush The Rock, same cabinet.'
Set-Rotation -Slug 'san_francisco_rush_2049' -Degrees 270 -Confidence 'high' -Sources $rushSource -Notes 'Atari Games hardware. Rush 2049, same cabinet family.'
Set-Rotation -Slug 'san_francisco_rush_2049_tournament_editi' -Degrees 270 -Confidence 'high' -Sources $rushSource -Notes 'Atari Games hardware. Rush 2049 Tournament Edition.'

# Race Drivin (Atari, 1990) - same as Hard Drivin (1080 degrees)
Set-Rotation -Slug 'race_drivin_cockpit_rev_5' -Degrees 1080 -Confidence 'high' -Sources @([PSCustomObject]@{
    type = 'reference'
    description = 'Sequel to Hard Drivin using identical 1080-degree (3-rotation) steering assembly with 10-turn potentiometer.'
    url = $null; date_accessed = $today
}) -Notes 'Atari hardware. Same 1080-degree steering as Hard Drivin.'

# Cruis''n Exotica (Midway, 1999)
Set-Rotation -Slug 'cruisn_exotica_version_24' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
    type = 'parts'
    description = "Midway Cruis'n series uses SuzoHapp Active 270 steering assembly."
    url = 'https://na.suzohapp.com/products/driving_controls/50-4041-90'
    date_accessed = $today
}) -Notes "Midway Zeus 2 hardware. Cruis'n series."

# Cruis''n World (Midway, 1996)
Set-Rotation -Slug 'cruisn_world_v25' -Degrees 270 -Confidence 'high' -Sources @([PSCustomObject]@{
    type = 'parts'
    description = "Midway Cruis'n series uses SuzoHapp Active 270 steering assembly."
    url = 'https://na.suzohapp.com/products/driving_controls/50-4041-90'
    date_accessed = $today
}) -Notes "Midway hardware. Cruis'n series."

# Hydro Thunder (Midway, 1999)
Set-Rotation -Slug 'hydro_thunder' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Midway Seattle hardware. Boat racing with steering wheel. Standard 270-degree Midway racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Midway Seattle hardware. Boat racing.'

# CART Fury (Midway, 2000)
Set-Rotation -Slug 'cart_fury_championship_racing' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Midway Zeus hardware. Standard Midway 270-degree racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Midway Zeus hardware. CART open-wheel racing.'

# Hyperdrive (Midway, 1998)
Set-Rotation -Slug 'hyperdrive' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Midway Zeus hardware. Futuristic racing. Inference from Midway standard.'
    url = $null; date_accessed = $today
}) -Notes 'Midway Zeus hardware.'

# Offroad Thunder (Midway, 2000)
Set-Rotation -Slug 'offroad_thunder_mame' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Midway Zeus hardware. Off-road racing with standard 270-degree steering.'
    url = $null; date_accessed = $today
}) -Notes 'Midway Zeus hardware. Off-road racing.'

# Arctic Thunder MAME (Midway, 2001) - merge into existing arctic_thunder
if ($db.games.PSObject.Properties['arctic_thunder_v1002']) {
    $target = $db.games.arctic_thunder
    if ($target -and -not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = 'arctthnd'; clones_inherit = $true
        })
    }
    $db.games.PSObject.Properties.Remove('arctic_thunder_v1002')
    $removals++
    Write-Output "  Merged: arctic_thunder_v1002 -> arctic_thunder"
}

# Ultimate Arctic Thunder MAME -> merge
if ($db.games.PSObject.Properties['ultimate_arctic_thunder_mame']) {
    $target = $db.games.ultimate_arctic_thunder
    if ($target -and -not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = 'ultarctc'; clones_inherit = $true
        })
    }
    $db.games.PSObject.Properties.Remove('ultimate_arctic_thunder_mame')
    $removals++
    Write-Output "  Merged: ultimate_arctic_thunder_mame -> ultimate_arctic_thunder"
}

# Vapor TRX (Atari, 1998) - futuristic bike racing
Set-Rotation -Slug 'vapor_trx_guts_jul_2_1998__main_jul_18_1' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Atari Games hardware. Futuristic bike racing with handlebar controls.'
    url = $null; date_accessed = $today
}) -Notes 'Atari Games hardware. Futuristic hoverbike racing.'

# Road Riot 4WD (Atari, 1991)
Set-Rotation -Slug 'road_riot_4wd' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Atari Games hardware. Standard arcade racing cabinet with 270-degree steering.'
    url = $null; date_accessed = $today
}) -Notes 'Atari Games hardware. Off-road combat racing.'

# S.T.U.N. Runner (Atari, 1989) - cockpit with handlebar
Set-Rotation -Slug 'stun_runner' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Atari Games hardware. Futuristic tube racing. Yoke/handlebar style controls.'
    url = $null; date_accessed = $today
}) -Notes 'Atari Games hardware. Futuristic tube racing.'

# =====================================================================
Write-Output ""
Write-Output "=== Phase 6: Set Gaelco Racing Games ==="
Write-Output ""

# Speed Up (Gaelco, 1996)
Set-Rotation -Slug 'speed_up_version_220' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Gaelco hardware. Standard arcade racing cabinet with steering wheel.'
    url = $null; date_accessed = $today
}) -Notes 'Gaelco hardware.'

# World Rally 2 (Gaelco, 1995)
Set-Rotation -Slug 'world_rally_2_twin_racing_mask_rom_versi' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Gaelco hardware. Rally racing with steering wheel.'
    url = $null; date_accessed = $today
}) -Notes 'Gaelco hardware. Rally racing.'

# Smashing Drive (Gaelco for Namco, 2000)
Set-Rotation -Slug 'smashing_drive' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Gaelco hardware running on Namco hardware. Taxi racing with steering wheel.'
    url = $null; date_accessed = $today
}) -Notes 'Gaelco/Namco hardware. Taxi racing.'

# Rolling Extreme (Gaelco, 1999)
Set-Rotation -Slug 'rolling_extreme' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Gaelco hardware. Inline skating game but uses steering-type controls.'
    url = $null; date_accessed = $today
}) -Notes 'Gaelco hardware. Inline skating.'

# Last KM (Gaelco, 1995)
Set-Rotation -Slug 'last_km' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Gaelco hardware. Cycling game with handlebar controls.'
    url = $null; date_accessed = $today
}) -Notes 'Gaelco hardware. Cycling game.'

# Gaelco Tuning Race MAME -> merge into existing
if ($db.games.PSObject.Properties['gaelco_championship_tuning_race'] -and $db.games.PSObject.Properties['gaelco_tuning_race']) {
    $target = $db.games.gaelco_tuning_race
    if ($target -and -not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = 'tuningrc'; clones_inherit = $true
        })
    }
    $db.games.PSObject.Properties.Remove('gaelco_championship_tuning_race')
    $removals++
    Write-Output "  Merged: gaelco_championship_tuning_race -> gaelco_tuning_race"
}

# Tokyo Cop MAME -> merge into existing
if ($db.games.PSObject.Properties['tokyo_cop_mame'] -and $db.games.PSObject.Properties['tokyo_cop']) {
    $target = $db.games.tokyo_cop
    if ($target -and -not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = 'tokyocop'; clones_inherit = $true
        })
    }
    $db.games.PSObject.Properties.Remove('tokyo_cop_mame')
    $removals++
    Write-Output "  Merged: tokyo_cop_mame -> tokyo_cop"
}

# Ring Riders MAME -> merge into existing
if ($db.games.PSObject.Properties['ring_riders_software_version_v22'] -and $db.games.PSObject.Properties['ring_riders']) {
    $target = $db.games.ring_riders
    if ($target -and -not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = 'rriders'; clones_inherit = $true
        })
    }
    $db.games.PSObject.Properties.Remove('ring_riders_software_version_v22')
    $removals++
    Write-Output "  Merged: ring_riders_software_version_v22 -> ring_riders"
}

# Radikal Bikers MAME -> merge into existing
if ($db.games.PSObject.Properties['radikal_bikers_version_202'] -and $db.games.PSObject.Properties['radikal_bikers']) {
    $target = $db.games.radikal_bikers
    if ($target -and -not $target.platforms.PSObject.Properties['mame']) {
        $target.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
            romname = 'radikalb'; clones_inherit = $true
        })
    }
    $db.games.PSObject.Properties.Remove('radikal_bikers_version_202')
    $removals++
    Write-Output "  Merged: radikal_bikers_version_202 -> radikal_bikers"
}

# =====================================================================
Write-Output ""
Write-Output "=== Phase 7: Set misc known games ==="
Write-Output ""

# Need for Speed arcade (Global VR, 270 from standard racing cab)
$nfsSource = @([PSCustomObject]@{
    type = 'inference'
    description = 'Global VR racing cabinet. Standard 270-degree steering assembly.'
    url = $null; date_accessed = $today
})
Set-Rotation -Slug 'need_for_speed__4_cab_link_2_discs_v101_' -Degrees 270 -Confidence 'medium' -Sources $nfsSource -Notes 'Global VR hardware.'
Set-Rotation -Slug 'need_for_speed_gt_hard_drive2_discs_v110' -Degrees 270 -Confidence 'medium' -Sources $nfsSource -Notes 'Global VR hardware.'
Set-Rotation -Slug 'need_for_speed_underground_install_2_dis' -Degrees 270 -Confidence 'medium' -Sources $nfsSource -Notes 'Global VR hardware.'

# Spy Hunter (Bally Midway, 1983) - uses steering wheel
Set-Rotation -Slug 'spy_hunter' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Bally Midway hardware. Standard arcade steering wheel of the era.'
    url = $null; date_accessed = $today
}) -Notes 'Bally Midway hardware. Driving/shooting game.'

# Buggy Boy (Tatsumi, 1985) - classic racer
Set-Rotation -Slug 'buggy_boyspeed_buggy_cockpit_rev_d' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Tatsumi hardware. Standard 270-degree arcade racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Tatsumi hardware. Off-road racing classic.'

# Side by Side (Taito, 1996)
Set-Rotation -Slug 'side_by_side' -Degrees 270 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito JC System hardware. Standard racing cabinet with 270-degree steering.'
    url = $null; date_accessed = $today
}) -Notes 'Taito JC System hardware.'

# Dangerous Curves (Taito, 1995)
Set-Rotation -Slug 'dangerous_curves' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito hardware. Standard racing cabinet.'
    url = $null; date_accessed = $today
}) -Notes 'Taito hardware.'

# Battle Gear 2 (Taito, 2000)
Set-Rotation -Slug 'battle_gear_2_v204j' -Degrees 540 -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Taito Type X hardware. Battle Gear series uses 540-degree steering (confirmed by TeknoParrot metadata for BG3/BG4).'
    url = $null; date_accessed = $today
}) -Notes 'Taito hardware. Predecessor to Battle Gear 3 (540 degrees).'

# Maximum Speed (Sammy, 2003)
Set-Rotation -Slug 'maximum_speed' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sammy Atomiswave hardware. Standard 270-degree steering assumption.'
    url = $null; date_accessed = $today
}) -Notes 'Sammy Atomiswave hardware.'

# Faster Than Speed (Sammy, 2004)
Set-Rotation -Slug 'faster_than_speed' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Sammy Atomiswave hardware. Standard 270-degree steering assumption.'
    url = $null; date_accessed = $today
}) -Notes 'Sammy Atomiswave hardware.'

# Lethal Crash Race (Video System, 1993)
Set-Rotation -Slug 'lethal_crash_race__bakuretsu_crash_race' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Video System hardware. Standard arcade racing.'
    url = $null; date_accessed = $today
}) -Notes 'Video System hardware.'

# F-1 Grand Prix (Video System, 1991)
Set-Rotation -Slug 'f1_grand_prix' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Video System hardware. F1 racing.'
    url = $null; date_accessed = $today
}) -Notes 'Video System hardware.'

# F-1 Grand Prix Part II (Video System, 1992)
Set-Rotation -Slug 'f1_grand_prix_part_ii' -Degrees 270 -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Video System hardware. F1 racing sequel.'
    url = $null; date_accessed = $today
}) -Notes 'Video System hardware.'

# =====================================================================
Write-Output ""
Write-Output "=== Phase 8: Set early/TTL game values ==="
Write-Output ""

# Early pre-1985 games with steering - many use optical encoders or simple pots
# Gran Trak 10 (Atari/Kee, 1974) - first steering wheel arcade game
Set-Rotation -Slug 'gran_trak_10trak_10formula_k_ttl' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'reference'
    description = 'One of the first arcade driving games. Uses continuous-rotation steering wheel with optical encoder.'
    url = $null; date_accessed = $today
}) -Notes 'Atari/Kee TTL hardware. First arcade driving game with steering wheel. Infinite rotation.'
Set-Rotation -Slug 'gran_trak_20trak_20twin_racer_ttl' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Twin version of Gran Trak 10. Same optical encoder steering.'
    url = $null; date_accessed = $today
}) -Notes 'Atari/Kee TTL hardware. Twin player version of Gran Trak 10.'

# Sprint 4/8 (Atari, 1977)
Set-Rotation -Slug 'sprint_4' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'reference'
    description = 'Atari Sprint series uses optical encoder steering (continuous rotation). Top-down racing.'
    url = $null; date_accessed = $today
}) -Notes 'Atari TTL hardware. Top-down sprint racing. Infinite rotation.'
Set-Rotation -Slug 'sprint_8' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Same Sprint series hardware as Sprint 4. Optical encoder steering.'
    url = $null; date_accessed = $today
}) -Notes 'Atari TTL hardware. 8-player sprint racing.'

# Monaco GP (Sega, 1980)
Set-Rotation -Slug 'monaco_gp' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'medium' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Early Sega racing game. Pre-potentiometer era, uses optical encoder for continuous steering.'
    url = $null; date_accessed = $today
}) -Notes 'Sega TTL/discrete hardware. Infinite rotation optical encoder.'

# Head On 2 (Sega, 1979)
Set-Rotation -Slug 'head_on_2' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Early Sega driving game. Likely uses optical encoder like other games of this era.'
    url = $null; date_accessed = $today
}) -Notes 'Sega hardware. Early driving/maze game.'

# Fonz (Sega, 1976)
Set-Rotation -Slug 'fonz_ttl' -Degrees -1 -RotationType 'optical_encoder' -Confidence 'low' -Sources @([PSCustomObject]@{
    type = 'inference'
    description = 'Very early Sega TTL game. Motorcycle game likely using simple analog controls.'
    url = $null; date_accessed = $today
}) -Notes 'Sega TTL hardware. Very early motorcycle game.'

# =====================================================================
$json = $db | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($dbPath, $json)
$totalGames = @($db.games.PSObject.Properties).Count
Write-Output ""
Write-Output "=== Final Summary ==="
Write-Output "Removals: $removals"
Write-Output "Rotation values set: $updates"
Write-Output "Total games now: $totalGames"
