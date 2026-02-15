<#
.SYNOPSIS
    Applies rotation research findings to the wheel-db database.
.DESCRIPTION
    One-time script to add rotation_degrees values for 40 Steam games
    that had wheel support but missing rotation recommendations.
#>
param(
    [string]$DatabasePath = "$PSScriptRoot/../data/wheel-db.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DatabasePath = Resolve-Path $DatabasePath
$db = Get-Content -Raw $DatabasePath | ConvertFrom-Json

# Build title -> slug lookup
$titleToSlug = @{}
foreach ($prop in $db.games.PSObject.Properties) {
    $titleToSlug[$prop.Value.title.ToLower()] = $prop.Name
}

# Research findings: title -> { rotation, confidence, source_type, note }
$findings = @(
    # Agent A: Native wheel support games
    @{ title = "Apex Point"; rotation = 540; confidence = "low"; source_type = "inference"; note = "Sim-cade drift/street racer. 540 inferred from drift genre standard." }
    @{ title = "Crash Time 2"; rotation = 360; confidence = "low"; source_type = "inference"; note = "Arcade police chase game. 360 inferred for fast-paced arcade driving." }
    @{ title = "Drive Megapolis"; rotation = 900; confidence = "low"; source_type = "inference"; note = "Driving school simulator. 900 inferred from driving education sim genre." }
    @{ title = "Peak Angle: Drift Online"; rotation = 540; confidence = "medium"; source_type = "steam_community"; note = "Online drift MMO with native wheel support. 540 matches drift sim genre and real drift car setups." }
    @{ title = "Project Torque"; rotation = 540; confidence = "medium"; source_type = "steam_community"; note = "F2P MMO racer with Arcade and Simulation modes. Official guide recommends matching hardware rotation." }
    @{ title = "Star Trucker"; rotation = 360; confidence = "medium"; source_type = "developer"; note = "Space trucking game. Official Peripherals Guide recommends reduced wheel travel for spacecraft control." }
    @{ title = "The Long Drive"; rotation = 900; confidence = "medium"; source_type = "steam_community"; note = "Open-world survival driving. Community uses 900 for realistic road car behavior." }
    @{ title = "Torque Drift"; rotation = 540; confidence = "low"; source_type = "inference"; note = "Competitive drift racing with FFB. 540 inferred from drift genre standard." }
    @{ title = "Victory: The Age of Racing"; rotation = 240; confidence = "high"; source_type = "steam_community"; note = "Hard-coded steering lock of ~240 degrees confirmed by multiple Steam discussions." }

    # Agent B: Major partial support games
    @{ title = "Grand Theft Auto V"; rotation = 540; confidence = "medium"; source_type = "steam_community"; note = "Requires Manual Transmission mod for proper wheel support. Community consensus is 540 degrees." }
    @{ title = "Grand Theft Auto V Enhanced"; rotation = 540; confidence = "low"; source_type = "inference"; note = "Same driving model as GTA V Legacy. 540 recommended with Manual Transmission mod." }
    @{ title = "Grand Theft Auto: Episodes from Liberty City"; rotation = 270; confidence = "low"; source_type = "steam_community"; note = "No native wheel support, requires x360ce. 270 minimizes dead zone." }
    @{ title = "Grand Theft Auto: San Andreas"; rotation = 270; confidence = "medium"; source_type = "steam_community"; note = "Basic DirectInput wheel support. SAAC mod improves support. 270 recommended for arcade handling." }
    @{ title = "Need for Speed (2016)"; rotation = 270; confidence = "medium"; source_type = "steam_community"; note = "Native wheel support for select wheels. 270 works best for arcade handling; 900 too slow." }
    @{ title = "Need for Speed Rivals"; rotation = 270; confidence = "low"; source_type = "steam_community"; note = "No official wheel support. Workaround via x360ce. 270 minimizes dead zone." }
    @{ title = "Need for Speed Undercover"; rotation = 270; confidence = "medium"; source_type = "steam_community"; note = "Basic wheel support via control type switch. Lower rotation works best for arcade handling." }
    @{ title = "Need For Speed: Hot Pursuit"; rotation = 180; confidence = "high"; source_type = "steam_community"; note = "Multiple sources confirm 180 degrees minimizes the significant center dead zone." }
    @{ title = "Burnout Paradise Remastered"; rotation = 180; confidence = "medium"; source_type = "steam_community"; note = "No official wheel support. Community guide for G29/G920 recommends 180-degree range." }
    @{ title = "Burnout Paradise: The Ultimate Box"; rotation = 360; confidence = "medium"; source_type = "steam_community"; note = "Basic wheel support with dead zone issues. Community recommends 360 in hardware driver." }
    @{ title = "Mafia II (Classic)"; rotation = 270; confidence = "low"; source_type = "steam_community"; note = "No native wheel support, requires x360ce. 270 recommended for analog stick emulation." }
    @{ title = "Farming Simulator 15"; rotation = 900; confidence = "high"; source_type = "developer"; note = "Official wheel support. Saitek Farming Simulator Wheel designed for 900 degrees." }
    @{ title = "Rocket League"; rotation = 180; confidence = "medium"; source_type = "steam_community"; note = "Natively compatible but not designed for wheel. Low rotation universally recommended." }
    @{ title = "Mad Max"; rotation = 270; confidence = "low"; source_type = "steam_community"; note = "No native wheel support, requires x360ce. 270 for arcade combat driving." }
    @{ title = "Driver: Parallel Lines"; rotation = 270; confidence = "low"; source_type = "steam_community"; note = "No native wheel support, requires x360ce. 270 for arcade open-world driving." }

    # Agent C: Remaining partial support games
    @{ title = "Absolute Drift"; rotation = 270; confidence = "medium"; source_type = "steam_community"; note = "Top-down minimalist drift game. 900 unworkable; 270 recommended for responsive drift control." }
    @{ title = "Distance"; rotation = 270; confidence = "low"; source_type = "inference"; note = "Survival racing/platformer with flying. Low rotation needed for quick directional changes." }
    @{ title = "Drift Streets Japan"; rotation = 540; confidence = "medium"; source_type = "steam_community"; note = "Dedicated drift game with in-game steering lock tuning. Developer posted wheel setup guide." }
    @{ title = "Drift Type C"; rotation = 540; confidence = "low"; source_type = "inference"; note = "Physics-based multi-discipline driving. 540 balances drift responsiveness with racing precision." }
    @{ title = "FlatOut 3: Chaos & Destruction"; rotation = 360; confidence = "medium"; source_type = "steam_community"; note = "FlatOut series community documents G29 settings at 360 degrees." }
    @{ title = "Garfield Kart"; rotation = 270; confidence = "low"; source_type = "inference"; note = "Arcade kart racer. 270 is the kart-style genre standard for minimal steering travel." }
    @{ title = "High Octane Drift"; rotation = 540; confidence = "low"; source_type = "inference"; note = "Drift racing game. 540 is drift genre standard." }
    @{ title = "Initial Drift Online"; rotation = 540; confidence = "low"; source_type = "inference"; note = "F2P multiplayer touge drift racing. Real Initial D arcade cabinets use 540." }
    @{ title = "Midnight Club 2"; rotation = 270; confidence = "low"; source_type = "inference"; note = "Arcade street racer with snappy physics. 270 matches twitchy arcade handling." }
    @{ title = "Nash Racing"; rotation = 360; confidence = "low"; source_type = "inference"; note = "Small indie Unreal Engine racer. 360 is safe middle-ground default." }
    @{ title = "Project Drift"; rotation = 540; confidence = "low"; source_type = "inference"; note = "Manga-style JDM drift game. 540 aligns with JDM drift genre standard." }
    @{ title = "Re-Volt"; rotation = 180; confidence = "medium"; source_type = "steam_community"; note = "RC car racer. RVGL community mod improves support. RC cars have extremely quick twitchy steering." }
    @{ title = "Ridge Racer Unbounded"; rotation = 270; confidence = "medium"; source_type = "steam_community"; note = "Arcade destruction racer. Ridge Racer arcade cabinets use 270; matches franchise standard." }
    @{ title = "Split/Second"; rotation = 270; confidence = "low"; source_type = "inference"; note = "Arcade action racer. No native wheel support; requires x360ce. 270 matches arcade handling." }
    @{ title = "STAR WARS Episode I Racer"; rotation = 270; confidence = "medium"; source_type = "steam_community"; note = "Pod racing (1999/2018 re-release). Supports DirectX FFB. 270 matches era standard." }
    @{ title = "Street Racing Syndicate"; rotation = 180; confidence = "medium"; source_type = "steam_community"; note = "Unchangeable built-in deadzone makes it unplayable above 200 degrees." }
)

$updated = 0
$notFound = 0
$skipped = 0

foreach ($f in $findings) {
    $slug = $titleToSlug[$f.title.ToLower()]
    if (-not $slug) {
        Write-Host "  NOT FOUND: $($f.title)" -ForegroundColor Red
        $notFound++
        continue
    }

    $game = $db.games.$slug
    if ($null -ne $game.rotation_degrees) {
        Write-Host "  SKIP (already has rotation): $($f.title) = $($game.rotation_degrees)" -ForegroundColor Yellow
        $skipped++
        continue
    }

    # Set rotation
    $game.rotation_degrees = $f.rotation

    # Upgrade confidence if research found higher
    $confOrder = @{ 'unknown' = 0; 'low' = 1; 'medium' = 2; 'high' = 3; 'verified' = 4 }
    $currentConf = $confOrder[$game.confidence]
    $newConf = $confOrder[$f.confidence]
    if ($newConf -gt $currentConf) {
        $game.confidence = $f.confidence
    }

    # Add source
    $newSource = [PSCustomObject]@{
        type          = $f.source_type
        description   = $f.note
        url           = $null
        date_accessed = "2026-02-14"
    }
    $game.sources += $newSource

    Write-Host "  UPDATED: $($f.title) -> $($f.rotation) deg ($($f.confidence))" -ForegroundColor Green
    $updated++
}

Write-Host "`n=== Summary ==="
Write-Host "Updated: $updated"
Write-Host "Skipped (already had rotation): $skipped"
Write-Host "Not found: $notFound"

# Bump version
$db.version = "2.2.0"
$db.generated = "2026-02-14T00:00:00Z"

# Write back
$json = $db | ConvertTo-Json -Depth 10
# Normalize line endings
$json = $json -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($DatabasePath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host "`nDatabase updated to v2.2.0"
Write-Host "File: $DatabasePath"
