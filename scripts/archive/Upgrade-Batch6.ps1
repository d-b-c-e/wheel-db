Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-20'
$added = 0
$skipped = 0

function Add-SteamGame {
    param($slug, $title, $developer, $publisher, $year, $appid, $rotation,
          $wheelSupport, $forceFeedback, $controllerSupport, $confidence,
          $sourceType, $sourceDesc, $notes, $pcgwUrl, $tags)

    if ($db.games.PSObject.Properties[$slug]) {
        Write-Host "  SKIP: $slug already exists"
        $script:skipped++
        return
    }

    $steamPlatform = [PSCustomObject]@{
        appid            = $appid
        tags             = $tags
        store_url        = "https://store.steampowered.com/app/$appid"
        pcgamingwiki_url = $pcgwUrl
        popularity_rank  = $null
        owners_estimate  = $null
    }

    $pcObj = [PSCustomObject]@{
        wheel_support      = $wheelSupport
        force_feedback     = $forceFeedback
        controller_support = $controllerSupport
    }

    $entry = [PSCustomObject]@{
        title            = $title
        manufacturer     = $null
        developer        = $developer
        publisher        = $publisher
        year             = $year
        rotation_degrees = $rotation
        rotation_type    = $null
        confidence       = $confidence
        sources          = @([PSCustomObject]@{
            type          = $sourceType
            description   = $sourceDesc
            url           = $null
            date_accessed = $today
        })
        notes            = $notes
        pc               = $pcObj
        platforms        = [PSCustomObject]@{
            steam = $steamPlatform
        }
    }

    $db.games | Add-Member -MemberType NoteProperty -Name $slug -Value $entry
    Write-Host "  ADDED: $slug ($title)"
    $script:added++
}

# ============================================================
# PART 1: DRIFT / STREET RACING (5 games)
# ============================================================

Write-Host "=== Part 1: Drift / Street Racing ==="

Add-SteamGame -slug 'drift_reign' -title 'Drift Reign' `
    -developer 'Midnight Games' -publisher 'PublishMe Agency Limited' `
    -year '2023' -appid 2368220 -rotation 540 `
    -wheelSupport 'partial' -forceFeedback 'unknown' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Steam store page confirms Logitech and Thrustmaster wheel support via G HUB only. No FFB info found. Community reports compatibility issues.' `
    -notes 'Drift career game. Wheel support requires Logitech G HUB software. Early Access.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Drift', 'Early Access')

Add-SteamGame -slug 'clutch_drift_simulation' -title 'Clutch: The Drift Simulation' `
    -developer 'Yoshi Jeffery' -publisher 'Yoshi Jeffery' `
    -year '2025' -appid 3411570 -rotation 540 `
    -wheelSupport 'partial' -forceFeedback 'partial' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Developer wiki confirms steering wheel support with beta Force Feedback. USB wheel support and FFB device detection implemented. VR support included.' `
    -notes 'Dedicated drift sim. Wheel and FFB in beta. Free-to-play. Early Access.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Drift', 'Simulation', 'Early Access')

Add-SteamGame -slug 'drift_tafheet' -title 'Drift' `
    -developer 'AmbratorGames' -publisher 'AmbratorGames' `
    -year '2026' -appid 4110410 -rotation 540 `
    -wheelSupport 'native' -forceFeedback 'partial' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Steam store page advertises full racing wheel and force feedback support. Community reports suggest FFB implementation is inconsistent across wheel models.' `
    -notes 'Open-world drift game. Arabic developer. 30+ cars with customization.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Drift', 'Open World')

Add-SteamGame -slug 'underground_garage' -title 'Underground Garage' `
    -developer 'BeardedBrothers.games' -publisher 'astragon Entertainment' `
    -year '2024' -appid 1452250 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Multiple Steam community threads confirm no steering wheel support. G29 and similar wheels not recognized. No wheel binding option in-game.' `
    -notes 'Car mechanic/tuning game with street racing. No wheel support.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Simulation', 'Automobile Sim')

Add-SteamGame -slug 'night_runners_prologue' -title 'NIGHT-RUNNERS Prologue' `
    -developer 'PLANET JEM' -publisher 'PLANET JEM' `
    -year '2024' -appid 2707900 -rotation 270 `
    -wheelSupport 'partial' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'PCGamingWiki and Steam community confirm wheel recognition via G HUB but no force feedback. Developer stated full wheel support planned for full game launch.' `
    -notes 'Japanese street racing 1990-2009. Free prologue. Wheels detected but no FFB. 95% positive reviews.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Night-Runners_Prologue' `
    -tags @('Racing', 'Open World', 'Indie')

# ============================================================
# PART 2: MOTORCYCLE RACING - RIDE SERIES (3 games)
# ============================================================

Write-Host "`n=== Part 2: RIDE series ==="

Add-SteamGame -slug 'ride_4' -title 'RIDE 4' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2020' -appid 1259980 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle game with controller-only support. No steering wheel.' `
    -notes 'Motorcycle racing. Hundreds of bikes, dozens of tracks. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Ride_4' `
    -tags @('Racing', 'Motorcycle', 'Simulation')

Add-SteamGame -slug 'ride_3' -title 'RIDE 3' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2019' -appid 759740 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle game with controller-only support. No steering wheel.' `
    -notes 'Motorcycle racing. 230+ bikes, 30 tracks. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Ride_3' `
    -tags @('Racing', 'Motorcycle', 'Simulation')

Add-SteamGame -slug 'ride_2' -title 'RIDE 2' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2016' -appid 477770 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle game with controller-only support. No steering wheel.' `
    -notes 'Motorcycle racing. Part of RIDE series. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Ride_2' `
    -tags @('Racing', 'Motorcycle', 'Simulation')

# ============================================================
# PART 3: MOTORCYCLE RACING - MotoGP (1 game)
# ============================================================

Write-Host "`n=== Part 3: MotoGP ==="

Add-SteamGame -slug 'motogp_25' -title 'MotoGP 25' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2025' -appid 3077390 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle game. Controller only, no steering wheel support.' `
    -notes 'Official MotoGP game. Controller only, no wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MotoGP_25' `
    -tags @('Racing', 'Motorcycle', 'Sports')

# ============================================================
# PART 4: MOTORCYCLE RACING - MXGP SERIES (7 games)
# ============================================================

Write-Host "`n=== Part 4: MXGP series ==="

Add-SteamGame -slug 'mxgp_24' -title 'MXGP 24: The Official Game' `
    -developer 'Kylotonn Games' -publisher 'Nacon' `
    -year '2024' -appid 2603040 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only, no steering wheel support.' `
    -notes 'Official MXGP motocross game. 20 tracks, 50+ riders. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP_24' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'mxgp_pro' -title 'MXGP PRO' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2018' -appid 798290 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only.' `
    -notes 'Official MXGP motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP_Pro' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'mxgp_2019' -title 'MXGP 2019' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2019' -appid 1018160 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only.' `
    -notes 'Official MXGP motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP_2019' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'mxgp_2020' -title 'MXGP 2020' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2020' -appid 1259800 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only.' `
    -notes 'Official MXGP motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP_2020' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'mxgp3' -title 'MXGP3' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2017' -appid 561600 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only.' `
    -notes 'Official MXGP motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP3_-_The_Official_Motocross_Videogame' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'mxgp2' -title 'MXGP2' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2016' -appid 400800 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only.' `
    -notes 'Official MXGP motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP2_-_The_Official_Motocross_Videogame' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'mxgp' -title 'MXGP' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2014' -appid 256370 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only.' `
    -notes 'First official MXGP motocross game on PC. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MXGP' `
    -tags @('Racing', 'Motorcycle', 'Sports')

# ============================================================
# PART 5: MOTORCYCLE - TT ISLE OF MAN (2 games)
# ============================================================

Write-Host "`n=== Part 5: TT Isle of Man ==="

Add-SteamGame -slug 'tt_isle_of_man' -title 'TT Isle of Man: Ride on the Edge' `
    -developer 'Kylotonn Racing Games' -publisher 'Nacon' `
    -year '2018' -appid 626610 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle racing game. Controller only, no wheel support.' `
    -notes 'TT racing simulation. Motorcycle-only, no wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/TT_Isle_of_Man' `
    -tags @('Racing', 'Motorcycle', 'Simulation')

Add-SteamGame -slug 'tt_isle_of_man_2' -title 'TT Isle of Man: Ride on the Edge 2' `
    -developer 'Kylotonn Racing Games' -publisher 'Nacon' `
    -year '2020' -appid 1082180 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle racing game. Controller only, no wheel support.' `
    -notes 'TT racing simulation sequel. Motorcycle-only, no wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/TT_Isle_of_Man:_Ride_on_the_Edge_2' `
    -tags @('Racing', 'Motorcycle', 'Simulation')

# ============================================================
# PART 6: MOTORCYCLE - OTHER (1 game)
# ============================================================

Write-Host "`n=== Part 6: RiMS Racing ==="

Add-SteamGame -slug 'rims_racing' -title 'RiMS Racing' `
    -developer 'Nacon Studio Milan' -publisher 'Nacon' `
    -year '2021' -appid 1346010 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motorcycle game. No native wheel support, community workarounds via x360ce.' `
    -notes 'Motorcycle simulation with mechanical focus. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/RiMS_Racing' `
    -tags @('Racing', 'Motorcycle', 'Simulation')

# ============================================================
# PART 7: OFF-ROAD / MX VS ATV (3 games)
# ============================================================

Write-Host "`n=== Part 7: MX vs ATV series ==="

Add-SteamGame -slug 'mx_vs_atv_all_out' -title 'MX vs ATV All Out' `
    -developer 'Rainbow Studios' -publisher 'THQ Nordic' `
    -year '2018' -appid 520940 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community confirms no native wheel support. Dual-stick controls required for independent rider/vehicle control. Third-party mapping needed.' `
    -notes 'Off-road motorcycle/ATV/UTV racing. Dual-stick design incompatible with wheels.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MX_vs._ATV_All_Out' `
    -tags @('Racing', 'Off-Road', 'Sports')

Add-SteamGame -slug 'mx_vs_atv_reflex' -title 'MX vs ATV Reflex' `
    -developer 'Rainbow Studios' -publisher 'THQ Nordic' `
    -year '2009' -appid 55140 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community confirms no wheel support. Rider Reflex dual-control system requires two analog sticks. Fundamentally incompatible with single-axis wheel.' `
    -notes 'Off-road racing with Rider Reflex system. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MX_vs._ATV_Reflex' `
    -tags @('Racing', 'Off-Road', 'Sports')

Add-SteamGame -slug 'mx_vs_atv_unleashed' -title 'MX vs ATV Unleashed' `
    -developer 'Rainbow Studios' -publisher 'THQ Nordic' `
    -year '2005' -appid 359220 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community thread asking about Thrustmaster T300RS support received zero responses. No evidence of wheel support.' `
    -notes 'Off-road motorcycle/ATV racing. 2005 game re-released on Steam. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/MX_vs._ATV_Unleashed' `
    -tags @('Racing', 'Off-Road', 'Sports')

# ============================================================
# PART 8: MONSTER ENERGY SUPERCROSS (4 games)
# ============================================================

Write-Host "`n=== Part 8: Monster Energy Supercross ==="

Add-SteamGame -slug 'monster_energy_supercross' -title 'Monster Energy Supercross' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2018' -appid 711750 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only, no wheel support.' `
    -notes 'Official Monster Energy Supercross motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Monster_Energy_Supercross' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'monster_energy_supercross_2' -title 'Monster Energy Supercross 2' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2019' -appid 882020 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only, no wheel support.' `
    -notes 'Official Monster Energy Supercross motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Monster_Energy_Supercross_2' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'monster_energy_supercross_3' -title 'Monster Energy Supercross 3' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2020' -appid 1089830 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only, no wheel support.' `
    -notes 'Official Monster Energy Supercross motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Monster_Energy_Supercross_3' `
    -tags @('Racing', 'Motorcycle', 'Sports')

Add-SteamGame -slug 'monster_energy_supercross_6' -title 'Monster Energy Supercross 6' `
    -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' `
    -year '2023' -appid 2058750 -rotation 270 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'pcgamingwiki' `
    -sourceDesc 'PCGamingWiki confirms motocross game. Controller only, no wheel support.' `
    -notes 'Official Monster Energy Supercross motocross game. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Monster_Energy_Supercross_6' `
    -tags @('Racing', 'Motorcycle', 'Sports')

# ============================================================
# PART 9: DRAG RACING (2 games)
# ============================================================

Write-Host "`n=== Part 9: Drag Racing ==="

Add-SteamGame -slug 'nhra_speed_for_all' -title 'NHRA Championship Drag Racing: Speed For All' `
    -developer 'Team6 Game Studios' -publisher 'GameMill Entertainment' `
    -year '2022' -appid 1681880 -rotation $null `
    -wheelSupport 'partial' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Steam community reports Xbox-compatible wheels partially recognized. No input remapping or FFB. Drag racing has minimal steering. Traxion review criticizes lack of customizable controls.' `
    -notes 'Official NHRA drag racing game. Xbox wheels partially work. No FFB, no control customization.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/NHRA:_Speed_for_All' `
    -tags @('Racing', 'Sports')

Add-SteamGame -slug 'street_outlaws_the_list' -title 'Street Outlaws: The List' `
    -developer 'Team6 Game Studios' -publisher 'GameMill Entertainment' `
    -year '2019' -appid 987330 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'high' -sourceType 'developer' `
    -sourceDesc 'Developer confirmed in Steam community: "Street Outlaws: The List does not support wheels and pedals." No plans announced.' `
    -notes 'Drag racing game based on Discovery TV show. Developer confirmed no wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Street_Outlaws:_The_List' `
    -tags @('Racing', 'Sports')

# ============================================================
# PART 10: RALLY (1 game)
# ============================================================

Write-Host "`n=== Part 10: Rally ==="

Add-SteamGame -slug 'rally_evolution_2025' -title 'Rally Evolution 2025' `
    -developer 'Petr Simůnek' -publisher 'Petr Simůnek' `
    -year '2025' -appid 3273700 -rotation 270 `
    -wheelSupport 'unknown' -forceFeedback 'unknown' -controllerSupport 'partial' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Indie MMO rally game. Partial controller support listed on Steam. No wheel support documentation found. Very small playerbase.' `
    -notes 'Free-to-play indie MMO rally. Up to 40 players. Wheel support status unknown.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Rally', 'MMO')

# ============================================================
# PART 11: ANTI-GRAVITY RACING (6 games)
# ============================================================

Write-Host "`n=== Part 11: Anti-Gravity Racing ==="

Add-SteamGame -slug 'redout' -title 'Redout: Enhanced Edition' `
    -developer '34BigThings' -publisher '34BigThings' `
    -year '2016' -appid 517710 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Multiple Steam community threads confirm no wheel support. Anti-gravity racer requires 3 axes (steering, strafing, pitch) incompatible with single-axis wheel.' `
    -notes 'WipEout-inspired anti-gravity racer. Multi-axis control, no wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Redout' `
    -tags @('Racing', 'Anti-Gravity')

Add-SteamGame -slug 'redout_2' -title 'Redout 2' `
    -developer '34BigThings' -publisher 'Saber Interactive' `
    -year '2022' -appid 1799930 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Anti-gravity racer with complex multi-axis controls (steering, pitch, strafe, roll). No wheel support, no community evidence of wheel integration.' `
    -notes 'Anti-gravity racer sequel. Even more complex controls than original. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Redout_2' `
    -tags @('Racing', 'Anti-Gravity')

Add-SteamGame -slug 'ballisticng' -title 'BallisticNG' `
    -developer 'Neognosis' -publisher 'Neognosis' `
    -year '2018' -appid 473770 -rotation 180 `
    -wheelSupport 'partial' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community confirms G29 works via Rewired input system. Manual mapping of paddle shifters to air brakes needed. Recommended 180 degree wheel angle. No FFB.' `
    -notes 'WipEout tribute. Wheels recognized but require manual mapping. No FFB. Free modding tools.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/BallisticNG' `
    -tags @('Racing', 'Anti-Gravity', 'Indie')

Add-SteamGame -slug 'antigraviator' -title 'Antigraviator' `
    -developer 'Cybernetic Walrus' -publisher 'Iceberg Interactive' `
    -year '2018' -appid 621020 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Developer confirmed Xbox, PS4, and Steam Controller support only. No mention of steering wheels. Anti-gravity racer.' `
    -notes 'Anti-gravity combat racer. Controller-only, no wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Antigraviator' `
    -tags @('Racing', 'Anti-Gravity')

Add-SteamGame -slug 'pacer' -title 'Pacer' `
    -developer 'R8 Games' -publisher 'R8 Games' `
    -year '2020' -appid 389670 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Formerly Formula Fusion. WipEout-style anti-gravity racer with multi-axis controls. No wheel support evidence found.' `
    -notes 'Anti-gravity combat racer. Formerly Formula Fusion. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Formula_Fusion' `
    -tags @('Racing', 'Anti-Gravity')

Add-SteamGame -slug 'aero_gpx' -title 'Aero GPX' `
    -developer 'Aaron McDevitt' -publisher 'Aaron McDevitt' `
    -year '2024' -appid 2160360 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community discussion confirms wheel not practical due to pitch/strafe requirements. F-Zero-inspired anti-gravity racer. 97% positive reviews.' `
    -notes 'F-Zero-inspired anti-gravity racer. Multi-axis control, no wheel support. Early Access.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Aero_GPX' `
    -tags @('Racing', 'Anti-Gravity', 'Indie')

# ============================================================
# PART 12: ARCADE / KART (4 games)
# ============================================================

Write-Host "`n=== Part 12: Arcade / Kart ==="

Add-SteamGame -slug 'gt_racing_1980' -title 'GT Racing 1980' `
    -developer 'BM Studios' -publisher 'BM Studios' `
    -year '2024' -appid 3037960 -rotation $null `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Top-down arcade racer inspired by 1980s games. Top-down perspective incompatible with steering wheel controls.' `
    -notes 'Top-down retro arcade racer. No wheel support due to top-down perspective.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Arcade', 'Retro')

Add-SteamGame -slug 'nightmare_kart' -title 'Nightmare Kart' `
    -developer 'LWMedia' -publisher 'LWMedia' `
    -year '2024' -appid 2930160 -rotation 180 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community confirms G29 not recognized. No in-game wheel binding. Steam Input workaround also failed.' `
    -notes 'Gothic kart racer (formerly Bloodborne Kart). Free to play. No wheel support.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Nightmare_Kart' `
    -tags @('Racing', 'Kart', 'Indie')

Add-SteamGame -slug 'super_indie_karts' -title 'Super Indie Karts' `
    -developer 'One Legged Seagull' -publisher 'One Legged Seagull' `
    -year '2015' -appid 323670 -rotation 180 `
    -wheelSupport 'partial' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Developer added wheel calibration via Rewired input system. DeadZone slider uses 1% increments for wheel compatibility. No FFB. Steam community configs available.' `
    -notes 'Retro 16-64bit kart racer. Developer actively supports wheel calibration. No FFB. Early Access.' `
    -pcgwUrl 'https://www.pcgamingwiki.com/wiki/Super_Indie_Karts' `
    -tags @('Racing', 'Kart', 'Indie')

Add-SteamGame -slug 'karting_superstars' -title 'Karting Superstars' `
    -developer 'Original Fire Games' -publisher 'Original Fire Games' `
    -year '2023' -appid 2503220 -rotation 180 `
    -wheelSupport 'none' -forceFeedback 'none' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'steam_community' `
    -sourceDesc 'Steam community reports G920 recognized but very clunky. No FFB, poor sensitivity. Developer unresponsive. Development paused since Feb 2024.' `
    -notes 'Pure motorsport kart racer. From Circuit Superstars devs. Development paused. No proper wheel support.' `
    -pcgwUrl $null `
    -tags @('Racing', 'Kart')

# ============================================================
# SAVE
# ============================================================

Write-Host "`n=== Summary ==="
Write-Host "New games added: $added"
Write-Host "Skipped: $skipped"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
