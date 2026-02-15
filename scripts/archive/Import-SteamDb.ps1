<#
.SYNOPSIS
    Imports Steam wheel support data into the unified wheel-db.

.DESCRIPTION
    One-time import that reads the steam-wheel-support-db database and merges
    its entries into the unified wheel-db.json. Cross-platform games (same
    title in both databases) get their Steam platform data merged into the
    existing arcade entry. Steam-only games get new entries.

.PARAMETER SteamDbPath
    Path to the steam-wheel-support-db JSON file.

.PARAMETER WheelDbPath
    Path to the unified wheel-db.json file (will be modified in-place).
#>
param(
    [string]$SteamDbPath = "E:\Source\steam-wheel-support-db\data\steam-wheel-support.json",
    [string]$WheelDbPath = "$PSScriptRoot/../data/wheel-db.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Helper: Generate slug from title ---
function ConvertTo-Slug {
    param([string]$Title)
    $slug = $Title.ToLower()
    # Replace common special chars
    $slug = $slug -replace '&', 'and'
    $slug = $slug -replace "'", ''
    $slug = $slug -replace '[^a-z0-9\s]', ''
    $slug = $slug -replace '\s+', '_'
    $slug = $slug -replace '_+', '_'
    $slug = $slug.Trim('_')
    return $slug
}

# --- Load databases ---
$WheelDbPath = Resolve-Path $WheelDbPath
Write-Host "Loading wheel-db: $WheelDbPath"
$wheelDb = Get-Content -Raw $WheelDbPath | ConvertFrom-Json

Write-Host "Loading steam-db: $SteamDbPath"
$steamDb = Get-Content -Raw $SteamDbPath | ConvertFrom-Json

$steamProps = @($steamDb.games.PSObject.Properties)
Write-Host "Steam entries to import: $($steamProps.Count)"

# --- Build title->key lookup for arcade entries ---
$arcadeTitleMap = @{}
foreach ($p in $wheelDb.games.PSObject.Properties) {
    $arcadeTitleMap[$p.Value.title.ToLower().Trim()] = $p.Name
}

# --- Build slug collision set ---
$existingSlugs = @{}
foreach ($p in $wheelDb.games.PSObject.Properties) {
    $existingSlugs[$p.Name] = $true
}

# --- Process Steam entries ---
$merged = 0
$added = 0
$skipped = 0
$slugCollisions = @()

foreach ($steamProp in $steamProps) {
    $appid = $steamProp.Name
    $steam = $steamProp.Value
    $sp = $steam.PSObject.Properties

    $steamTitle = $steam.title.ToLower().Trim()

    # Build Steam platform sub-entry
    $steamPlatform = [ordered]@{
        appid           = $steam.steam_appid
        tags            = if ($sp['steam_tags'] -and $null -ne $steam.steam_tags) { $steam.steam_tags } else { $null }
        store_url       = if ($sp['steam_url']) { $steam.steam_url } else { $null }
        pcgamingwiki_url = if ($sp['pcgamingwiki_url']) { $steam.pcgamingwiki_url } else { $null }
        popularity_rank = if ($sp['popularity_rank']) { $steam.popularity_rank } else { $null }
        owners_estimate = if ($sp['owners_estimate']) { $steam.owners_estimate } else { $null }
    }

    # Build PC metadata sub-entry
    $pcMeta = [ordered]@{
        wheel_support      = $steam.wheel_support
        force_feedback     = $steam.force_feedback
        controller_support = if ($sp['controller_support']) { $steam.controller_support } else { $null }
    }

    # Check for cross-platform overlap (exact title match)
    if ($arcadeTitleMap.ContainsKey($steamTitle)) {
        $arcadeKey = $arcadeTitleMap[$steamTitle]
        $existing = $wheelDb.games.$arcadeKey

        # Merge: add Steam platform and PC metadata to existing entry
        $existing | Add-Member -NotePropertyName 'pc' -NotePropertyValue ([PSCustomObject]$pcMeta) -Force

        # Add steam to platforms
        $existing.platforms | Add-Member -NotePropertyName 'steam' -NotePropertyValue ([PSCustomObject]$steamPlatform) -Force

        # Fill in developer/publisher if arcade entry doesn't have them
        if (-not $existing.developer -and $sp['developer'] -and $steam.developer) {
            $existing.developer = $steam.developer
        }
        if (-not $existing.publisher -and $sp['publisher'] -and $steam.publisher) {
            $existing.publisher = $steam.publisher
        }

        Write-Host "  MERGED: Steam $appid '$($steam.title)' -> arcade key '$arcadeKey'"
        $merged++
        continue
    }

    # New entry: generate slug
    $slug = ConvertTo-Slug -Title $steam.title

    # Handle slug collisions
    if ($existingSlugs.ContainsKey($slug)) {
        $originalSlug = $slug
        $slug = "${slug}_steam"
        $slugCollisions += "$originalSlug -> $slug ($($steam.title))"
    }

    # Map rotation
    $rotDeg = if ($sp['recommended_rotation_degrees'] -and $null -ne $steam.recommended_rotation_degrees) {
        $steam.recommended_rotation_degrees
    } else { $null }

    # Build new entry
    $entry = [ordered]@{
        title            = $steam.title
        manufacturer     = $null
        developer        = if ($sp['developer']) { $steam.developer } else { $null }
        publisher        = if ($sp['publisher']) { $steam.publisher } else { $null }
        year             = if ($sp['release_year']) { $steam.release_year } else { $null }
        rotation_degrees = $rotDeg
        rotation_type    = $null  # PC games have no physical rotation mechanism
        confidence       = $steam.confidence
        sources          = $steam.sources
        notes            = if ($sp['notes']) { $steam.notes } else { $null }
        pc               = [PSCustomObject]$pcMeta
        platforms        = [PSCustomObject][ordered]@{
            steam = [PSCustomObject]$steamPlatform
        }
    }

    $wheelDb.games | Add-Member -NotePropertyName $slug -NotePropertyValue ([PSCustomObject]$entry) -Force
    $existingSlugs[$slug] = $true
    $added++
}

# --- Update version and timestamp ---
$wheelDb.version = "2.1.0"
$wheelDb.generated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# --- Serialize and write ---
$json = $wheelDb | ConvertTo-Json -Depth 10
$json | Set-Content -Path $WheelDbPath -Encoding UTF8 -NoNewline

# --- Summary ---
$totalNow = @($wheelDb.games.PSObject.Properties).Count
Write-Host "`n--- Import Summary ---"
Write-Host "Steam entries processed: $($steamProps.Count)"
Write-Host "  Merged (cross-platform): $merged"
Write-Host "  Added (Steam-only):      $added"
Write-Host "  Skipped:                  $skipped"
Write-Host "Total entries now:          $totalNow"
Write-Host "Version:                    $($wheelDb.version)"

if ($slugCollisions.Count -gt 0) {
    Write-Host "`nSlug collisions resolved:"
    foreach ($c in $slugCollisions) { Write-Host "  $c" }
}

# --- Verification ---
$verify = Get-Content -Raw $WheelDbPath | ConvertFrom-Json
$verifyCount = @($verify.games.PSObject.Properties).Count
Write-Host "`nVerification: $verifyCount entries in output"

# Spot-check a merged entry
$ct = $verify.games.crazytaxi
if ($ct -and $ct.platforms.steam) {
    Write-Host "Spot-check: 'crazytaxi' has steam appid=$($ct.platforms.steam.appid), pc.wheel_support=$($ct.pc.wheel_support)"
} else {
    Write-Host "WARNING: 'crazytaxi' merge check failed"
}

# Spot-check a Steam-only entry
$ac = $verify.games.assetto_corsa
if ($ac -and $ac.platforms.steam) {
    Write-Host "Spot-check: 'assetto_corsa' has steam appid=$($ac.platforms.steam.appid), rotation=$($ac.rotation_degrees)"
} else {
    Write-Host "WARNING: 'assetto_corsa' check failed"
}

Write-Host "`nImport complete."
