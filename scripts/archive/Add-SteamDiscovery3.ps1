Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$addedCount = 0
$today = '2026-02-17'

function Add-Game {
    param(
        [string]$Slug,
        [hashtable]$Entry
    )
    if ($db.games.PSObject.Properties[$Slug]) {
        Write-Host "  SKIP (already exists): $Slug"
        return
    }
    $obj = [PSCustomObject]$Entry
    $db.games | Add-Member -NotePropertyName $Slug -NotePropertyValue $obj
    Write-Host "  Added: $Slug ($($Entry.title))"
    $script:addedCount++
}

# =============================================================================
# FIX: GTR 2 has wrong appid (44690 = GT Legends, should be 8790)
# =============================================================================
Write-Host "=== Fix: GTR 2 appid ==="
$gtr2 = $db.games.gtr_2
if ($gtr2 -and $gtr2.platforms.steam.appid -eq 44690) {
    $gtr2.platforms.steam.appid = 8790
    $gtr2.platforms.steam.store_url = 'https://store.steampowered.com/app/8790'
    Write-Host "  Fixed gtr_2 appid: 44690 -> 8790"
}

# =============================================================================
# TIER 1: Racing Sims with Strong Wheel/FFB Support
# =============================================================================
Write-Host ""
Write-Host "=== Tier 1: Racing Sims ==="

Add-Game -Slug 'project_motor_racing' -Entry @{
    title = 'Project Motor Racing'
    manufacturer = $null
    developer = 'Straight4 Studios'
    publisher = 'GIANTS Software'
    year = '2025'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Racing sim by former Slightly Mad Studios lead; comprehensive FFB with per-car tuning'; url = 'https://store.steampowered.com/app/299970/Project_Motor_Racing/'; date_accessed = $today })
    notes = 'Poor reviews at launch but dedicated racing sim with extensive wheel support.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 299970; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/299970'; pcgamingwiki_url = 'https://www.pcgamingwiki.com/wiki/Project_Motor_Racing'; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'wreckfest_2' -Entry @{
    title = 'Wreckfest 2'
    manufacturer = $null
    developer = 'Bugbear Entertainment'
    publisher = 'THQ Nordic'
    year = '2025'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Demolition derby/touring car sequel; FFB comparable to DiRT Rally quality'; url = 'https://store.steampowered.com/app/1203190/Wreckfest_2/'; date_accessed = $today })
    notes = 'Early Access March 2025, full release Q1 2026. Supports Thrustmaster, Logitech, and Fanatec.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 1203190; tags = @('Racing','Destruction'); store_url = 'https://store.steampowered.com/app/1203190'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'carx_drift_racing_online_2' -Entry @{
    title = 'CarX Drift Racing Online 2'
    manufacturer = $null
    developer = 'CarX Technologies'
    publisher = 'CarX Technologies'
    year = '2026'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Drift sim sequel with realistic physics designed for steering wheel setups'; url = 'https://store.steampowered.com/app/1826420/CarX_Drift_Racing_Online_2/'; date_accessed = $today })
    notes = 'Early Access Q1 2026. Supports most steering wheels and gear shifters.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 1826420; tags = @('Racing','Drift'); store_url = 'https://store.steampowered.com/app/1826420'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'formula_legends' -Entry @{
    title = 'Formula Legends'
    manufacturer = $null
    developer = '3DClouds S.r.l.'
    publisher = '3DClouds S.r.l.'
    year = '2025'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Formula racing through decades; wheel support added in Patch 1.3 (Feb 2026)'; url = 'https://store.steampowered.com/app/3194360/Formula_Legends/'; date_accessed = $today })
    notes = 'Supports Moza, Logitech, Fanatec, and Thrustmaster wheels. 16 car models, 14 circuits.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 3194360; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/3194360'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

# =============================================================================
# TIER 2: Rally / Off-Road
# =============================================================================
Write-Host ""
Write-Host "=== Tier 2: Rally / Off-Road ==="

Add-Game -Slug 'dakar_desert_rally' -Entry @{
    title = 'Dakar Desert Rally'
    manufacturer = $null
    developer = 'Saber Porto'
    publisher = 'Saber Interactive'
    year = '2022'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Licensed Dakar rally; 540deg recommended, supports Logitech/Thrustmaster/Fanatec/Simucube'; url = 'https://www.briankoponen.com/dakar-desert-rally-logitech-g29-g920-settings/'; date_accessed = $today })
    notes = 'Has soft lock feature. Wheel angle up to 2520 degrees supported.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 1839940; tags = @('Racing','Off-Road'); store_url = 'https://store.steampowered.com/app/1839940'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'sebastien_loeb_rally_evo' -Entry @{
    title = 'Sebastien Loeb Rally EVO'
    manufacturer = $null
    developer = 'Milestone'
    publisher = 'Milestone'
    year = '2016'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Rally racer; 540deg recommended, good FFB conveying traction feel'; url = 'https://www.briankoponen.com/sebastien-loeb-rally-evo-logitech-g29-g920-settings/'; date_accessed = $today })
    notes = 'Supports G25/G27/G29/G920, Thrustmaster, and Fanatec. Wheel compatibility with newer devices can be limited.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 355060; tags = @('Racing','Rally'); store_url = 'https://store.steampowered.com/app/355060'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'v_rally_4' -Entry @{
    title = 'V-Rally 4'
    manufacturer = $null
    developer = 'Kylotonn'
    publisher = 'Bigben Interactive'
    year = '2018'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Rally racing; advanced FFB config via InputFFBConfig.cfg; wide wheel support'; url = 'https://store.steampowered.com/app/658700/VRally_4/'; date_accessed = $today })
    notes = 'Supports G25/G27/G29/G920, Thrustmaster T80-TX, Fanatec. Over 50 car models.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 658700; tags = @('Racing','Rally'); store_url = 'https://store.steampowered.com/app/658700'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

# =============================================================================
# TIER 3: Arcade / Off-Road
# =============================================================================
Write-Host ""
Write-Host "=== Tier 3: Arcade / Off-Road ==="

Add-Game -Slug 'gravel' -Entry @{
    title = 'Gravel'
    manufacturer = $null
    developer = 'Milestone'
    publisher = 'Milestone'
    year = '2018'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Off-road arcade racer; superb FFB, H-pattern shifter and clutch support'; url = 'https://www.briankoponen.com/gravel-logitech-g29-g920-settings/'; date_accessed = $today })
    notes = 'Multiple USB input devices supported simultaneously.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 558260; tags = @('Racing','Off-Road'); store_url = 'https://store.steampowered.com/app/558260'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'monster_jam_steel_titans' -Entry @{
    title = 'Monster Jam Steel Titans'
    manufacturer = $null
    developer = 'Rainbow Studios'
    publisher = 'THQ Nordic'
    year = '2019'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'low'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Monster truck racing; partial wheel support with Thrustmaster and Logitech'; url = 'https://store.steampowered.com/app/824280/Monster_Jam_Steel_Titans/'; date_accessed = $today })
    notes = 'Wheel detection requires disabling Steam Generic Gamepad Configuration Support.'
    pc = [PSCustomObject]@{ wheel_support = 'partial'; force_feedback = 'partial'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 824280; tags = @('Racing','Monster Trucks'); store_url = 'https://store.steampowered.com/app/824280'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'monster_jam_steel_titans_2' -Entry @{
    title = 'Monster Jam Steel Titans 2'
    manufacturer = $null
    developer = 'Rainbow Studios'
    publisher = 'THQ Nordic'
    year = '2021'
    rotation_degrees = 540
    rotation_type = $null
    confidence = 'low'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Monster truck sequel; wheel support similar to first game with detection issues'; url = 'https://store.steampowered.com/app/1205480/Monster_Jam_Steel_Titans_2/'; date_accessed = $today })
    notes = 'Requires specific driver versions for wheel detection.'
    pc = [PSCustomObject]@{ wheel_support = 'partial'; force_feedback = 'partial'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 1205480; tags = @('Racing','Monster Trucks'); store_url = 'https://store.steampowered.com/app/1205480'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

# =============================================================================
# TIER 4: Classic SimBin Racing Sims
# =============================================================================
Write-Host ""
Write-Host "=== Tier 4: Classic SimBin ==="

Add-Game -Slug 'gtr_fia_gt_racing_game' -Entry @{
    title = 'GTR - FIA GT Racing Game'
    manufacturer = $null
    developer = 'SimBin Studios'
    publisher = 'SimBin Studios'
    year = '2005'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Hardcore GT racing sim; FIA GT Championship 2003; full wheel/FFB support'; url = 'https://store.steampowered.com/app/44600/GTR__FIA_GT_Racing_Game/'; date_accessed = $today })
    notes = 'MOTEC telemetry analysis. Three gameplay modes from beginner to simulation professional.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 44600; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/44600'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'gt_legends' -Entry @{
    title = 'GT Legends'
    manufacturer = $null
    developer = 'SimBin Studios'
    publisher = '10tacle Studios'
    year = '2005'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Classic touring car racing sim; 1960s-1970s vintage cars'; url = 'https://store.steampowered.com/app/44690/GT_Legends/'; date_accessed = $today })
    notes = 'Part of SimBin racing sim family.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 44690; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/44690'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'gtr_evolution' -Entry @{
    title = 'GTR Evolution Expansion Pack for RACE 07'
    manufacturer = $null
    developer = 'SimBin Studios'
    publisher = 'SimBin Studios'
    year = '2008'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Standalone expansion for RACE 07; adds Nurburgring, Audi R8, Koenigsegg CCX'; url = 'https://store.steampowered.com/app/8660/GTR_Evolution_Expansion_Pack_for_RACE_07/'; date_accessed = $today })
    notes = '49 cars in 12 classes: touring, GT, formula, sports cars.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 8660; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/8660'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'race_injection' -Entry @{
    title = 'RACE Injection'
    manufacturer = $null
    developer = 'SimBin Studios'
    publisher = 'SimBin Studios'
    year = '2011'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Final chapter in RACE 07 series; 23 new cars, 9 new tracks'; url = 'https://store.steampowered.com/app/44680/RACE_Injection/'; date_accessed = $today })
    notes = 'Formula, GT Power, Retro, STCC, and WTCC 2010 classes.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 44680; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/44680'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'stcc_the_game' -Entry @{
    title = 'STCC - The Game'
    manufacturer = $null
    developer = 'SimBin Studios'
    publisher = 'SimBin Studios'
    year = '2008'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Swedish Touring Car Championship expansion for RACE 07'; url = 'https://store.steampowered.com/app/8690/STCC_The_Game/'; date_accessed = $today })
    notes = $null
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 8690; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/8690'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

# =============================================================================
# TIER 5: Simulators with Wheel Support
# =============================================================================
Write-Host ""
Write-Host "=== Tier 5: Simulators ==="

Add-Game -Slug 'farming_simulator_22' -Entry @{
    title = 'Farming Simulator 22'
    manufacturer = $null
    developer = 'GIANTS Software'
    publisher = 'GIANTS Software'
    year = '2021'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Farming sim with wheel support; no real FFB, only centering spring'; url = 'https://store.steampowered.com/app/1248130/Farming_Simulator_22/'; date_accessed = $today })
    notes = 'Over 400 vehicles from 100+ brands.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'none'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 1248130; tags = @('Simulation','Farming'); store_url = 'https://store.steampowered.com/app/1248130'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'farming_simulator_25' -Entry @{
    title = 'Farming Simulator 25'
    manufacturer = $null
    developer = 'GIANTS Software'
    publisher = 'GIANTS Software'
    year = '2024'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Latest Farming Sim; supports direct drive wheels but FFB limited to centering spring'; url = 'https://store.steampowered.com/app/2300320/Farming_Simulator_25/'; date_accessed = $today })
    notes = '400+ vehicles, new crops, weather system.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'none'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 2300320; tags = @('Simulation','Farming'); store_url = 'https://store.steampowered.com/app/2300320'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'tourist_bus_simulator' -Entry @{
    title = 'Tourist Bus Simulator'
    manufacturer = $null
    developer = 'TML-Studios'
    publisher = 'Aerosoft'
    year = '2018'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'low'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Bus driving sim; basic wheel support, recent Aerosoft Truck & Bus Wheel System update'; url = 'https://store.steampowered.com/app/953580/Tourist_Bus_Simulator/'; date_accessed = $today })
    notes = 'Set on Fuerteventura. Upgraded to UE5.3.'
    pc = [PSCustomObject]@{ wheel_support = 'partial'; force_feedback = 'unknown'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 953580; tags = @('Simulation','Driving'); store_url = 'https://store.steampowered.com/app/953580'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

Add-Game -Slug 'construction_simulator' -Entry @{
    title = 'Construction Simulator'
    manufacturer = $null
    developer = 'weltenbauer. Software Entwicklung'
    publisher = 'Aerosoft'
    year = '2022'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'low'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Construction sim with co-op; wheel support present but no FFB'; url = 'https://store.steampowered.com/app/1273400/Construction_Simulator/'; date_accessed = $today })
    notes = 'Various construction vehicles including cranes, bulldozers, and transporters.'
    pc = [PSCustomObject]@{ wheel_support = 'partial'; force_feedback = 'none'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 1273400; tags = @('Simulation','Construction'); store_url = 'https://store.steampowered.com/app/1273400'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

# =============================================================================
# TIER 6: Classic/Niche
# =============================================================================
Write-Host ""
Write-Host "=== Tier 6: Classic/Niche ==="

Add-Game -Slug 'test_drive_ferrari_racing_legends' -Entry @{
    title = 'Test Drive: Ferrari Racing Legends'
    manufacturer = $null
    developer = 'Slightly Mad Studios'
    publisher = 'Rombax Games'
    year = '2012'
    rotation_degrees = 900
    rotation_type = $null
    confidence = 'medium'
    sources = @([PSCustomObject]@{ type = 'research'; description = 'Ferrari-exclusive racer by Project CARS team; excellent FFB, 50+ cars, 36 circuits'; url = 'https://store.steampowered.com/app/211970/Test_Drive_Ferrari_Racing_Legends/'; date_accessed = $today })
    notes = 'Supports Logitech, Thrustmaster, and Fanatec.'
    pc = [PSCustomObject]@{ wheel_support = 'native'; force_feedback = 'native'; controller_support = 'full' }
    platforms = [PSCustomObject]@{ steam = [PSCustomObject]@{ appid = 211970; tags = @('Racing','Simulation'); store_url = 'https://store.steampowered.com/app/211970'; pcgamingwiki_url = $null; popularity_rank = $null; owners_estimate = $null } }
}

# =============================================================================
# Save
# =============================================================================
Write-Host ""
$totalGames = @($db.games.PSObject.Properties).Count
Write-Host "=== Summary ==="
Write-Host "Games added: $addedCount"
Write-Host "Total games now: $totalGames"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
