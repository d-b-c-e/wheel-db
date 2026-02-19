Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-19'
$added = 0

function Add-SteamGame {
    param($slug, $title, $appid, $developer, $publisher, $year, $rotation, $wheelSupport, $ffb, $controllerSupport, $confidence, $sourceType, $sourceDesc, $sourceUrl, $tags, $notes, $pcgwUrl)

    if ($db.games.PSObject.Properties[$slug]) {
        Write-Host "  SKIP: $slug already exists"
        return
    }

    $steam = [ordered]@{
        appid           = $appid
        tags            = $tags
        store_url       = "https://store.steampowered.com/app/$appid"
        pcgamingwiki_url = $pcgwUrl
        popularity_rank = $null
        owners_estimate = $null
    }

    $source = [PSCustomObject]@{
        type          = $sourceType
        description   = $sourceDesc
        url           = $sourceUrl
        date_accessed = $today
    }

    $entry = [ordered]@{
        title            = $title
        manufacturer     = $null
        developer        = $developer
        publisher        = $publisher
        year             = $year
        rotation_degrees = $rotation
        rotation_type    = $null
        confidence       = $confidence
        sources          = @($source)
        notes            = $notes
        pc               = [ordered]@{
            wheel_support      = $wheelSupport
            force_feedback     = $ffb
            controller_support = $controllerSupport
        }
        platforms        = [ordered]@{
            steam = $steam
        }
    }

    $db.games | Add-Member -NotePropertyName $slug -NotePropertyValue ([PSCustomObject]$entry)
    Write-Host "  ADD: $slug ($title) appid=$appid rot=$rotation"
    $script:added++
}

Write-Host "=== New Steam game discovery batch 4 ==="

# Kart Racing Pro - realistic karting sim with native wheel/FFB support
Add-SteamGame -slug 'kart_racing_pro' -title 'Kart Racing Pro' `
    -appid 415600 -developer 'PiBoSo' -publisher 'PiBoSo' -year '2016' `
    -rotation 360 -wheelSupport 'native' -ffb 'native' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'research' `
    -sourceDesc 'Realistic karting simulator with native wheel and FFB support. 360 degrees matches real kart steering.' `
    -sourceUrl 'https://store.steampowered.com/app/415600' `
    -tags @('Racing', 'Simulation') `
    -notes 'Realistic karting sim designed as training tool for real kart drivers. PiBoSo also makes MX Bikes and World Racing Series.' `
    -pcgwUrl $null

# Trackmania (2020/current F2P version)
Add-SteamGame -slug 'trackmania' -title 'Trackmania' `
    -appid 2225070 -developer 'Nadeo' -publisher 'Ubisoft' -year '2020' `
    -rotation 360 -wheelSupport 'native' -ffb 'partial' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'reference' `
    -sourceDesc 'Nadeo TrackMania engine: consistent 360-degree wheel input across the series. Current F2P version on Steam.' `
    -sourceUrl 'https://store.steampowered.com/app/2225070' `
    -tags @('Racing', 'Free to Play') `
    -notes 'Free-to-play TrackMania with weekly player-made tracks. Same engine as earlier TrackMania titles.' `
    -pcgwUrl $null

# Forza Horizon 6 - upcoming, pre-purchase available, 540 degrees confirmed
Add-SteamGame -slug 'forza_horizon_6' -title 'Forza Horizon 6' `
    -appid 2483190 -developer 'Playground Games' -publisher 'Xbox Game Studios' -year '2025' `
    -rotation 540 -wheelSupport 'native' -ffb 'native' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'developer' `
    -sourceDesc 'Steam store page confirms up to 540 degrees of wheel rotation with updated steering animations.' `
    -sourceUrl 'https://store.steampowered.com/app/2483190' `
    -tags @('Racing', 'Open World') `
    -notes 'Set in Japan. Steam store mentions 540 degrees of wheel rotation. Forza Horizon series has excellent wheel support.' `
    -pcgwUrl $null

# iRacing Arcade - from iRacing motorsport team
Add-SteamGame -slug 'iracing_arcade' -title 'iRacing Arcade' `
    -appid 3226450 -developer 'iRacing.com Motorsport Simulations' -publisher 'iRacing.com Motorsport Simulations' -year '2025' `
    -rotation 900 -wheelSupport 'native' -ffb 'native' -controllerSupport 'full' `
    -confidence 'medium' -sourceType 'inference' `
    -sourceDesc 'Third-person racer from iRacing team, uses iRacing physics engine. 900 degrees inferred from iRacing heritage.' `
    -sourceUrl 'https://store.steampowered.com/app/3226450' `
    -tags @('Racing', 'Simulation') `
    -notes 'Arcade-style racer using iRacing physics engine. Third-person perspective with licensed cars and tracks.' `
    -pcgwUrl $null

# Screamer (2026 reboot) - Milestone arcade racer
Add-SteamGame -slug 'screamer_2026' -title 'Screamer' `
    -appid 2814990 -developer 'Milestone S.r.l.' -publisher 'Milestone S.r.l.' -year '2026' `
    -rotation 540 -wheelSupport 'unknown' -ffb 'unknown' -controllerSupport 'full' `
    -confidence 'low' -sourceType 'research' `
    -sourceDesc 'Milestone arcade racer reboot. Wheel support expected based on Milestone track record (RIDE, MotoGP, MXGP series).' `
    -sourceUrl 'https://store.steampowered.com/app/2814990' `
    -tags @('Racing', 'Arcade') `
    -notes 'Modern reimagining of 90s Screamer series with anime-inspired visuals. Releases March 2026.' `
    -pcgwUrl $null

# Gear.Club Unlimited 3
Add-SteamGame -slug 'gear_club_unlimited_3' -title 'Gear.Club Unlimited 3' `
    -appid 3659460 -developer 'Eden Games' -publisher 'Nacon' -year '2025' `
    -rotation 540 -wheelSupport 'unknown' -ffb 'unknown' -controllerSupport 'full' `
    -confidence 'low' -sourceType 'research' `
    -sourceDesc 'Racing game from Eden Games (Test Drive Unlimited). Wheel support status unknown pre-release.' `
    -sourceUrl 'https://store.steampowered.com/app/3659460' `
    -tags @('Racing', 'Simulation') `
    -notes 'Third entry in Gear.Club Unlimited series. Previously Switch/console exclusive, now multiplatform.' `
    -pcgwUrl $null

Write-Host ""
Write-Host "=== Fix NASCAR Racing notes ==="
$nascar = $db.games.PSObject.Properties['nascar_racing']
if ($nascar) {
    $old = $nascar.Value.notes
    $nascar.Value.notes = $old -replace 'Sega Chihiro hardware', 'Sega Hikaru hardware'
    Write-Host "  FIX: nascar_racing notes corrected from 'Chihiro' to 'Hikaru'"
} else {
    Write-Host "  SKIP: nascar_racing not found"
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "  Added: $added"
Write-Host "  NASCAR Racing notes fix applied"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
