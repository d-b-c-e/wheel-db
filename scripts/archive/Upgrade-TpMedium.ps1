Set-StrictMode -Version Latest

# Upgrade medium-confidence TeknoParrot entries to high where evidence supports it
# Part of the TP confidence upgrade effort (session 2026-02-17)

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$changes = 0
$today = '2026-02-17'

function Upgrade-ToHigh {
    param($slug, $additionalSources, $notesAppend)
    $g = $db.games.$slug
    if (-not $g) { Write-Warning "Entry not found: $slug"; return }
    if ($g.confidence -ne 'medium') { Write-Warning "$slug is $($g.confidence), not medium"; return }

    $g.confidence = 'high'

    # Add additional sources if provided
    if ($additionalSources) {
        $existingSources = @($g.sources)
        $allSources = $existingSources + $additionalSources
        $g.sources = $allSources
    }

    # Append to notes if provided
    if ($notesAppend -and $g.notes) {
        $g.notes = "$($g.notes) $notesAppend"
    } elseif ($notesAppend) {
        $g.notes = $notesAppend
    }

    $script:changes++
    Write-Output "  Upgraded: $slug -> high"
}

Write-Output "=== Upgrading TP Medium -> High Confidence ==="
Write-Output ""

# --- Group 1: Sega games with SuzoHapp 5K potentiometer evidence ---

# Ford Racing: Full Blown - Sega Lindbergh, service manual on ManualsLib confirms pot calibration
Upgrade-ToHigh -slug 'ford_racing' -additionalSources @(
    [PSCustomObject]@{
        type = 'parts'
        description = 'Sega Lindbergh driving cabinets use the standard 5K ohm potentiometer (220-5373/220-5374). Ford Racing uses the same Lindbergh steering assembly as R-Tuned, Hummer, and other verified 270-degree Sega games.'
        url = 'https://www.arcadeshop.com/i/1282/5k-potentiometer-for-sega-games.htm'
        date_accessed = $today
    }
)

# GRID - Confirmed shared cabinet design with Sega Racing Classic (high confidence 270 degrees)
Upgrade-ToHigh -slug 'grid_arcade' -additionalSources @(
    [PSCustomObject]@{
        type = 'reference'
        description = 'Arcade Heroes confirms GRID uses the same 42-inch cabinet design as Sega Racing Classic. SRC is verified high-confidence 270 degrees from Sega Retro operator manual.'
        url = 'https://arcadeheroes.com/sonic-sega-all-stars-racing-arcade-by-sega/'
        date_accessed = $today
    }
)

# --- Group 2: Games with manual sources documenting physical stops ---

# Tank! Tank! Tank! - Manual documents stopper arm/shaft
Upgrade-ToHigh -slug 'tank_tank_tank'

# Ring Riders - Manual documents stopper parts limiting handlebar rotation to 45 degrees
Upgrade-ToHigh -slug 'ring_riders'

# --- Group 3: Games with SuzoHapp parts catalog confirmation ---

# Ballistics - SuzoHapp 270-degree wheel explicitly listed as compatible
Upgrade-ToHigh -slug 'ballistics'

# Arctic Thunder - SuzoHapp Active 270 timing belt compatible
Upgrade-ToHigh -slug 'arctic_thunder'

# --- Save ---
$json = $db | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($dbPath, $json)

Write-Output ""
Write-Output "Total upgrades: $changes"
Write-Output "Saved to $dbPath"
