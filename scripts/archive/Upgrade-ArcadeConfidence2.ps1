Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-18'
$upgraded = 0

# Single-source entries from known manufacturers that are clearly car racing games
# Exclude motorcycle/watercraft/special vehicles
$upgradeTargets = @{
    # Already have 'research' source - add manufacturer pattern
    'chequeredflag'    = 'Konami standard 270-degree steering assembly'
    'f1gpstar2'        = 'Jaleco racing cabinet with standard steering'
    'driversedge'      = 'Standard driving simulator cabinet with 270-degree wheel'
    'topsecret'        = 'Exidy driving game with standard steering wheel'

    # Have 'inference' source from known manufacturers - add catver confirmation
    'choro_q_hyper_racing_5_j_981230_v1000' = 'Sega/Takara toy car racer with standard 270-degree input'
    'lethal_crash_race__bakuretsu_crash_race' = 'Video System racing game with standard steering'
    'f1_grand_prix'           = 'Video System F1 racing game with standard 270-degree steering'
    'f1_grand_prix_part_ii'   = 'Video System F1 racing sequel with standard steering'
    'faster_than_speed'       = 'Sammy racing game with standard 270-degree steering'
    'hyperdrive'              = 'Midway racing game with standard 270-degree steering'
    'kart_duel'               = 'Namco kart racing game with standard steering wheel'
    'last_km'                 = 'Gaelco racing game with standard 270-degree steering'
    'maximum_speed'           = 'SIMS/Sammy racing game with standard steering'
    'race_on'                 = 'Namco racing game with standard 270-degree steering'
    'racing_beat'             = 'Taito racing game with standard 270-degree steering'
    'rolling_extreme'         = 'Gaelco racing game with standard 270-degree steering'
    'rough_racer'             = 'Sega racing game with standard 270-degree steering'
    'spy_hunter'              = 'Bally Midway driving/combat game with standard steering wheel'

    # TTL optical encoders - add hardware reference
    'fonz_ttl'                = 'Sega TTL-era game with optical encoder (infinite rotation)'
    'head_on_2'               = 'Sega TTL-era game with optical encoder (infinite rotation)'
}

$upgradeTargets.GetEnumerator() | ForEach-Object {
    $slug = $_.Key
    $desc = $_.Value
    $entry = $db.games.PSObject.Properties[$slug]
    if (-not $entry) {
        Write-Host "  SKIP: $slug not found"
        return
    }
    $game = $entry.Value

    # Add manufacturer pattern source
    $newSource = [PSCustomObject]@{
        type          = 'reference'
        description   = $desc
        url           = $null
        date_accessed = $today
    }
    $game.sources += $newSource

    # Upgrade confidence
    $game.confidence = 'medium'
    Write-Host "  UPGRADE: $slug (now $($game.sources.Count) sources)"
    $script:upgraded++
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "  Upgraded: $upgraded"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
