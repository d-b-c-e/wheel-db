Set-StrictMode -Version Latest

# Triage MAME paddle/dial games to identify driving vs non-driving
# 2026-02-16

$cachePath = 'E:\Source\wheel-rotation-db\sources\cache\mame-games.json'
$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$outputPath = 'E:\Source\wheel-rotation-db\sources\cache\paddle-dial-triage.json'

if (-not (Test-Path $cachePath)) {
    Write-Host "ERROR: MAME cache not found at $cachePath" -ForegroundColor Red
    Write-Host "Run Get-MameGames.ps1 first."
    exit 1
}

$cache = Get-Content -Raw $cachePath | ConvertFrom-Json
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

# Get all slugs and MAME romnames already in the database
$dbSlugs = [System.Collections.Generic.HashSet[string]]::new()
$dbRoms = [System.Collections.Generic.HashSet[string]]::new()
$db.games.PSObject.Properties | ForEach-Object {
    [void]$dbSlugs.Add($_.Name)
    $plats = $_.Value.platforms
    if ($plats.PSObject.Properties['mame']) {
        $m = $plats.mame
        if ($m.PSObject.Properties['romname'] -and $m.romname) {
            [void]$dbRoms.Add($m.romname)
        }
        if ($m.PSObject.Properties['romnames'] -and $m.romnames) {
            $m.romnames | ForEach-Object { [void]$dbRoms.Add($_) }
        }
    }
}

# Filter MAME cache: parent games with paddle/dial NOT in database
$pending = @($cache.games | Where-Object {
    -not $_.is_clone -and
    ($_.input_types -contains 'paddle' -or $_.input_types -contains 'dial') -and
    -not $dbRoms.Contains($_.romname)
})

Write-Host "Pending paddle/dial parent games not in database: $($pending.Count)"

# Separate by category
$withCategory = @($pending | Where-Object { $_.category -and $_.category -match 'Driving|Racing' })
$noCategory = @($pending | Where-Object { -not $_.category -or $_.category -notmatch 'Driving|Racing' })

Write-Host "  With driving category: $($withCategory.Count)"
Write-Host "  Without driving category (need triage): $($noCategory.Count)"

# Classify no-category games by title/description patterns
$nonDrivingPatterns = @(
    'arkanoid', 'breakout', 'brick', 'block',                    # block breakers
    'pong', 'tennis', 'paddle',                                   # pong/paddle
    'beatmania', 'bm\d', 'keyboardmania', 'pop.n.music',         # music games
    'tempest', 'blasteroids', 'asteroids',                        # space shooters
    'cameltry', 'puzzle', 'loop', 'pop',                          # puzzles
    'pachinko', 'slot', 'poker', 'mahjong', 'hanafuda',          # gambling
    'bowling', 'golf', 'boxing', 'fishing', 'darts',             # sports
    'submarine', 'torpedo', 'destroyer', 'wolfpack', 'shark',     # naval
    'a400', 'a800', 'coleco', 'xegs', 'microvsn', 'cm32', 'tt030', 'bit90',  # hardware
    'tron', 'spinner', 'rotary',                                  # spinner games
    'cocktail', 'tabletop'                                        # cabinet types
)
$nonDrivingRegex = ($nonDrivingPatterns | ForEach-Object { "($_)" }) -join '|'

$driving = [System.Collections.ArrayList]::new()
$nonDriving = [System.Collections.ArrayList]::new()
$uncertain = [System.Collections.ArrayList]::new()

# Known driving game romnames/titles that might not have category
$knownDriving = @('18w', 'acedrvrw', 'raveracw', 'victlapw', 'strgchmp', 'magtruck', 'surfplnt')

foreach ($game in $noCategory) {
    $title = $game.title.ToLower()
    $rom = $game.romname.ToLower()

    if ($rom -in $knownDriving) {
        [void]$driving.Add([PSCustomObject]@{
            romname  = $game.romname
            title    = $game.title
            category = $game.category
            reason   = 'known_driving'
        })
    } elseif ($title -match $nonDrivingRegex -or $rom -match $nonDrivingRegex) {
        [void]$nonDriving.Add([PSCustomObject]@{
            romname  = $game.romname
            title    = $game.title
            category = $game.category
            reason   = 'pattern_match'
        })
    } else {
        [void]$uncertain.Add([PSCustomObject]@{
            romname  = $game.romname
            title    = $game.title
            category = $game.category
            reason   = 'needs_review'
        })
    }
}

Write-Host ""
Write-Host "=== Triage Results ==="
Write-Host "  Driving (keep):        $($driving.Count)"
Write-Host "  Non-driving (exclude): $($nonDriving.Count)"
Write-Host "  Uncertain (review):    $($uncertain.Count)"

# Build output
$output = [ordered]@{
    generated     = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
    summary       = [ordered]@{
        total_pending         = $pending.Count
        with_driving_category = $withCategory.Count
        without_category      = $noCategory.Count
        triage_driving        = $driving.Count
        triage_non_driving    = $nonDriving.Count
        triage_uncertain      = $uncertain.Count
    }
    driving_category_games = @($withCategory | ForEach-Object {
        [ordered]@{
            romname  = $_.romname
            title    = $_.title
            category = $_.category
        }
    })
    triage_driving = @($driving | ForEach-Object {
        [ordered]@{
            romname = $_.romname
            title   = $_.title
            reason  = $_.reason
        }
    })
    triage_non_driving = @($nonDriving | ForEach-Object {
        [ordered]@{
            romname = $_.romname
            title   = $_.title
            reason  = $_.reason
        }
    })
    triage_uncertain = @($uncertain | ForEach-Object {
        [ordered]@{
            romname = $_.romname
            title   = $_.title
        }
    })
}

$json = $output | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($outputPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Host ""
Write-Host "Output written to: $outputPath"

# Print uncertain list for manual review
if ($uncertain.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Uncertain games (need manual review) ==="
    $uncertain | ForEach-Object {
        Write-Host "  $($_.romname): $($_.title)"
    }
}
