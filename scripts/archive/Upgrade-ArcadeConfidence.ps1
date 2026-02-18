Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-18'

$upgraded = 0
$skippedMoto = 0
$skippedFew = 0
$skippedOther = 0

# Known manufacturers with documented 270-degree standard for car racing games
$knownManufacturers = @(
    'Sega', 'Namco', 'Konami', 'Taito', 'Taito Corporation', 'Taito Corporation Japan',
    'Midway Games', 'Bally Midway', 'Atari Games', 'Atari', 'Williams',
    'Gaelco', 'Data East Corporation', 'Jaleco', 'Video System Co.',
    'Epos Corporation', 'Exidy', 'Century Electronics',
    'IGS', 'Graphic Techno', 'Metro / Namco', 'Namco / Tomy',
    'CRI / Sega', 'Sega / Takara', 'SIMS / Sammy', 'MOSS / Sammy', 'Sammy',
    'Fortyfive', 'RB Bologna', 'Olympia', 'TCH', 'Tecfri', 'Uniana',
    'The Game Room', 'International Games', 'Universal',
    'Innovative Creations in Entertainment', 'Shinkai Inc. (Magic Electronics Inc. license)',
    'Digital Sunnil (Covielsa license)', 'Promat?', 'Strata/Incredible Technologies',
    'ABM & Gecas', 'Alpha Denshi Co.'
)

# Slug keywords indicating motorcycle/watercraft/bicycle - skip these
$motoKeywords = @(
    'hangon', 'hang_on', 'manxtt', 'superbike', 'motorbike', 'motorcycle',
    'motorraid', 'motor_raid', 'gprider', 'gp_rider', 'enduro',
    'cool_riders', '500_gp', 'suzuka_8_hours', 'moto_gp', 'motocross',
    'downhill_bikers', 'cycle_warriors', 'hyper_crash', 'stadiumcross',
    'kick_start', 'kick_rider', 'moto_frenzy', 'superbike',
    'wave_runner', 'aquajet', 'jetwave', 'rapid_river',
    'stun_runner', 'star_rider', 'hog_wild'
)

# Title keywords indicating motorcycle/watercraft
$motoTitleKeywords = @(
    'bike', 'rider', 'motorcycle', 'motocross', 'enduro', 'moto ',
    'hang-on', 'hang on', 'suzuka', 'wave runner', 'jet', 'raft',
    'cycle', 'surf', 'sled', 'ski'
)

$db.games.PSObject.Properties | Where-Object {
    $_.Value.confidence -eq 'low' -and -not $_.Value.platforms.PSObject.Properties['steam']
} | ForEach-Object {
    $slug = $_.Name
    $game = $_.Value
    $mfr = $game.manufacturer
    $rot = $game.rotation_degrees
    $title = $game.title

    # Skip motorcycle/watercraft/special vehicle games
    $isMoto = $false
    foreach ($kw in $motoKeywords) {
        if ($slug -like "*$kw*") { $isMoto = $true; break }
    }
    if (-not $isMoto) {
        $titleLower = $title.ToLower()
        foreach ($kw in $motoTitleKeywords) {
            if ($titleLower.Contains($kw)) { $isMoto = $true; break }
        }
    }
    if ($isMoto) {
        Write-Host "  SKIP (moto/water): $slug ($title)"
        $script:skippedMoto++
        return
    }

    # Must have at least 2 sources
    if ($game.sources.Count -lt 2) {
        Write-Host "  SKIP (1 source): $slug"
        $script:skippedFew++
        return
    }

    # Must have standard 270 or 360 rotation from a known manufacturer pattern
    if ($rot -ne 270 -and $rot -ne 360) {
        Write-Host "  SKIP (non-standard rot=$rot): $slug"
        $script:skippedOther++
        return
    }

    # Manufacturer must be known
    $mfrKnown = $false
    if ($mfr) {
        foreach ($km in $knownManufacturers) {
            if ($mfr -eq $km -or $mfr.StartsWith("$km ") -or $mfr.Contains("$km")) {
                $mfrKnown = $true; break
            }
        }
    }
    if (-not $mfrKnown) {
        Write-Host "  SKIP (unknown mfr '$mfr'): $slug"
        $script:skippedOther++
        return
    }

    # Upgrade to medium
    $game.confidence = 'medium'

    # Add manufacturer-pattern source
    $newSource = [PSCustomObject]@{
        type          = 'reference'
        description   = "Manufacturer standard: $mfr racing cabinets used $($rot)-degree steering assemblies"
        url           = $null
        date_accessed = $today
    }
    $game.sources += $newSource

    Write-Host "  UPGRADE: $slug ($mfr, $($rot)deg)"
    $script:upgraded++
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "  Upgraded to medium: $upgraded"
Write-Host "  Skipped (motorcycle/water): $skippedMoto"
Write-Host "  Skipped (few sources): $skippedFew"
Write-Host "  Skipped (other): $skippedOther"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
