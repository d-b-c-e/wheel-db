<#
.SYNOPSIS
    Migrates wheel-rotation.json from v1.x to v2.0 unified schema.

.DESCRIPTION
    One-time migration that transforms the existing arcade database to the
    unified wheel-db v2.0 schema:
    - Renames 'emulators' to 'platforms' in every game entry
    - Adds developer, publisher, pc fields (null for arcade-only entries)
    - Updates version to 2.0.0
    - Writes output to data/wheel-db.json

.PARAMETER InputPath
    Path to the existing wheel-rotation.json file.

.PARAMETER OutputPath
    Path for the migrated wheel-db.json file.
#>
param(
    [string]$InputPath = "$PSScriptRoot/../data/wheel-rotation.json",
    [string]$OutputPath = "$PSScriptRoot/../data/wheel-db.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$InputPath = Resolve-Path $InputPath
Write-Host "Reading: $InputPath"

# Read and parse
$raw = Get-Content -Raw $InputPath
$db = $raw | ConvertFrom-Json

$gameProps = @($db.games.PSObject.Properties)
$totalGames = $gameProps.Count
Write-Host "Found $totalGames game entries to migrate"

# Build new games object with transformed entries
$newGames = [ordered]@{}
$migrated = 0

foreach ($prop in $gameProps) {
    $key = $prop.Name
    $game = $prop.Value
    $gp = $game.PSObject.Properties

    # Safely read optional fields (some entries lack manufacturer, year, notes)
    $manufacturer = if ($gp['manufacturer']) { $game.manufacturer } else { $null }
    $year         = if ($gp['year']) { $game.year } else { $null }
    $notes        = if ($gp['notes']) { $game.notes } else { $null }

    # Build new entry with fields in canonical order
    $entry = [ordered]@{
        title            = $game.title
        manufacturer     = $manufacturer
        developer        = $null
        publisher        = $null
        year             = $year
        rotation_degrees = $game.rotation_degrees
        rotation_type    = $game.rotation_type
        confidence       = $game.confidence
        sources          = $game.sources
        notes            = $notes
        pc               = $null
        platforms        = $game.emulators  # Rename emulators -> platforms
    }

    $newGames[$key] = $entry
    $migrated++
}

# Build new top-level structure
$newDb = [ordered]@{
    version   = "2.0.0"
    generated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    games     = $newGames
}

# Serialize with sufficient depth
$json = $newDb | ConvertTo-Json -Depth 10 -Compress:$false

# Fix PowerShell's null serialization quirks - ensure clean JSON
# ConvertTo-Json already handles nulls correctly in PS7

# Write output
$OutputDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$json | Set-Content -Path $OutputPath -Encoding UTF8 -NoNewline
Write-Host "Migrated $migrated entries -> $OutputPath"
Write-Host "Version: 2.0.0"

# Verify round-trip
$verify = Get-Content -Raw $OutputPath | ConvertFrom-Json
$verifyCount = @($verify.games.PSObject.Properties).Count
Write-Host "Verification: $verifyCount entries in output (expected $totalGames)"

if ($verifyCount -ne $totalGames) {
    Write-Error "Entry count mismatch! Expected $totalGames, got $verifyCount"
}

# Spot-check a known entry
$outrun = $verify.games.outrun
if ($null -eq $outrun) {
    Write-Error "Missing 'outrun' entry!"
} elseif ($null -eq $outrun.platforms) {
    Write-Error "'outrun' entry missing 'platforms' field!"
} elseif ($null -ne $outrun.PSObject.Properties['emulators']) {
    Write-Error "'outrun' entry still has 'emulators' field (should be renamed to 'platforms')!"
} else {
    Write-Host "Spot-check passed: 'outrun' has platforms.mame.romname = $($outrun.platforms.mame.romname)"
}

Write-Host "`nMigration complete."
